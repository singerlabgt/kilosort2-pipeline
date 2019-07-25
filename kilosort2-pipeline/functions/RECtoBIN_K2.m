function RECtoBIN_K2(rawdatadir, targetdir, dtype, fileNames, fileNums, channels)
%RECTOBIN_K2 Convert spike gadgets .rec file to .bin for Kilosort2
%   Inputs:
%       rawdatadir: full path to raw .rec files
%       targetdir: directory for cluster files
%       dtype: datatype
%       fileNames: from converttoBIN
%       fileNums: desired files to cluster
%   ALP 7/13/19


binFile = [targetdir, 'allrecordings.bin'];
recLength = zeros(1,length(fileNums));
for f = 1:length(fileNums) %loop around desired files
    ind = strfind({fileNames.name}, strcat('recording', num2str(fileNums(f)),'_'));
    ind = cell2mat(ind);
    if ~isempty(ind)
        rawdatafile = [rawdatadir, fileNames(ind).name];        
        splits = strsplit(fileNames(ind).name, '.');
        configFileName = [rawdatadir, splits{1}, '.trodesconf'];
        if isfile(configFileName)
            configInfo = readTrodesFileConfig(configFileName); %get some Trodes info
            headerSize = str2double(configInfo.headerSize);
        else 
            cd('Y:\singer\RawData\RigB_SpikeGadgets')
            configInfo = readTrodesFileConfig('Nuri_32ch_052719.trodesconf'); %use default config file if not overwriting
            headerSize = str2double(configInfo.headerSize); 
        end
        %import channels
        data = importChannels(rawdatafile, length(channels), channels,...
            30000, headerSize); %import channels func from Trodes code
        
        %write to allrecordings.bin
        if f > 1
            fid = fopen(binFile, 'a');
            fwrite(fid, data', dtype);
        else
            fid = fopen(binFile, 'w');
            fwrite(fid, data', dtype);
        end
        
        fclose(fid);
        recLength(f) = size(data,1);
        clear data
    else
        error(['File ', num2str(fileNums(f)), ' not found.'])
    end
end

props.recLength = recLength;
props.sampRate = 30000;
props.fileNames = fileNames;

%save properties for fixing spike times after sorting
save([targetdir, 'sortingprops.mat'], 'props')
end

