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
id = fopen(binFile, 'w'); %clear all preexisting content to overwrite
fclose(id);
clear id

recLength = zeros(length(fileNums),1);

for f = 1:length(fileNums) %loop around desired files
    ind = strfind({fileNames.name}, strcat('recording', num2str(fileNums(f)),'_')); %added underscore(_) bc the number 1 appears in recordings 1, 10, 11, etc.
    ind = find(~cellfun(@isempty,ind)); %find index of correct rec file
    data = [];
    if ~isempty(ind)
        disp(['Extracting file ', num2str(f), ' of ', num2str(length(fileNums)) ' - file: ' num2str(fileNums(f))])
        rawdatafile = [rawdatadir, fileNames(ind).name];
        
        splits = strsplit(fileNames(ind).name, '.');
        configFileName = [rawdatadir, splits{1}, '.trodesconf'];
        if (~isfile(configFileName)) %check if session-specific config file exists, if not use default
            configInfo = readTrodesFileConfig(rawdatafile);%read configInfo directly from .rec file
        else
            configInfo = readTrodesFileConfig(configFileName);
        end
        
        headerSize = str2double(configInfo.headerSize);
        numChannels = str2double(configInfo.numChannels);
        sampRate = str2double(configInfo.samplingRate);
        
        %import channels
        data = importChannels(rawdatafile, numChannels, channels,...
            sampRate, headerSize); %import channels func from Trodes code
        
    else
        error(['File ', num2str(fileNums(f)), ' not found.'])
    end
    
    %write to allrecordings.bin
    fid = fopen(binFile, 'a');
    fwrite(fid, data.', dtype);
    fclose(fid);
    
    recLength(f) = size(data,1);
    clear data
    
end

props.recLength = recLength;
props.sampRate = sampRate;
props.fileNames = fileNames;

%save properties for fixing spike times after sorting
save([targetdir, 'sortingprops.mat'], 'props')
end
