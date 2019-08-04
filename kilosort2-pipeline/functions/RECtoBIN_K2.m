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
    ind = strfind({fileNames.name}, strcat('recording', num2str(fileNums(f)),'_')); %added underscore(_) bc the number 1 appears in recordings 1, 10, 11, etc.
    ind = find(~cellfun(@isempty,ind)); %find index of correct rec file 
    if ~isempty(ind)
        rawdatafile = [rawdatadir, fileNames(ind).name];
<<<<<<< Updated upstream
        
        splits = strsplit(fileNames(ind).name, '.');
        configFileName = [rawdatadir, splits{1}, '.trodesconf'];
        if (~isfile(configFileName)) %check if session-specific config file exists, if not use default 
            configInfo = readTrodesFileConfig(rawdatafile);%read configInfo directly from .rec file
        else 
            configInfo = readTrodesFileConfig(configFileName);
=======
        splits = strsplit(fileNames(ind).name, '.');
        configFileName = [rawdatadir, splits{1}, '.trodesconf'];
        if isfile(configFileName)
            configInfo = readTrodesFileConfig(configFileName); %get some Trodes info
            headerSize = str2double(configInfo.headerSize);
        else
            configInfo = readTrodesFileConfig(rawdatafile);
            headerSize = str2double(configInfo.headerSize); %use default if config file doesn't exist
>>>>>>> Stashed changes
        end
        headerSize = str2double(configInfo.headerSize);
        numChannels = str2double(configInfo.numChannels);
        sampRate = str2double(configInfo.samplingRate);        
         
        %import channels
        data = importChannels(rawdatafile, numChannels, channels,...
            sampRate, headerSize); %import channels func from Trodes code 
        
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
props.sampRate = configInfo.samplingRate;
props.fileNames = fileNames;

%save properties for fixing spike times after sorting
save([targetdir, 'sortingprops.mat'], 'props')
end

