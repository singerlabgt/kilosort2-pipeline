function RECtoBIN_K2(rawdatadir, targetdir, dtype, fileNames, fileNums, channels)
%RECTOBIN_K2 Convert spike gadgets .rec file to .bin for Kilosort2
%   Inputs:
%       rawdatadir: full path to raw .rec files
%       targetdir: directory for cluster files
%       dtype: datatype for Kilosort ('int16')
%       fileNames: from converttoBIN
%       fileNums: desired files to cluster
%   ALP 7/13/19

% NJ last updated 02.28.20 - use of new export functions from SG, data
% organization updates

cd (rawdatadir)
%% Extract .rec into .dat files, if not done already
if ~isfolder(fullfile(rawdatadir, 'recording1.LFP'))
    parfor f = 1:length(fileNums)
        extractUnfilteredLFPBinaryFiles(['recording' num2str(f)])
    end
end

%% Write channel data to bin, stich multiple rec files
fclose('all');

binFile = fullfile(targetdir, 'allrecordings.bin');
if isfile(binFile)
    delete(binFile)
end

recLength = zeros(length(fileNums),1);

for f = 1:length(fileNums) %loop around desired files
    ind = strfind({fileNames.name}, strcat('recording', num2str(fileNums(f)),'_')); %added underscore(_) bc the number 1 appears in recordings 1, 10, 11, etc.
    ind = find(~cellfun(@isempty,ind)); %find index of correct rec file

    if ~isempty(ind)
        disp(['Extracting file ', num2str(f), ' of ', num2str(length(fileNums))])
        rawdatafile = [rawdatadir, fileNames(ind).name];
        [filepath, name, ~] = fileparts(rawdatafile);
        configFileName = fullfile(filepath, [name '.trodesconf']);
        if (~isfile(configFileName)) %check if session-specific config file exists, if not use default
            configInfo = readTrodesFileConfig(rawdatafile);%read configInfo directly from .rec file
        else
            configInfo = readTrodesFileConfig(configFileName);
        end
        
        numChannels = str2double(configInfo.numChannels);
        sampRate = str2double(configInfo.samplingRate);
        
        %save use-defined hardware channel # in the order of nTrode ID (0-based)
        S = [configInfo.nTrodes.('channelInfo')];
        hwChan = [S.hw_chan]';
        
        %create data structure for Kilosort: nChannels x nTimePoints
        for nTrode = 1:numChannels
            cd (fullfile(rawdatadir, ['recording' num2str(ind) '.LFP'])) %navigate into rec files
            temp = readTrodesExtractedDataFile(['recording' num2str(ind) '.LFP_nt' num2str(nTrode) 'ch1.dat']);
            temp = temp.fields.data .* temp.voltage_scaling; %apply scaling factor to convert to uV
            
            data(nTrode,:) = temp;
            clear temp
        end
        
    else
        error(['File ', num2str(fileNums(f)), ' not found.'])
    end
    
    data = int16(data);
    
    %write to allrecordings.bin
    fid = fopen(binFile, 'a');
    if fid > 0
        count = fwrite(fid, data, dtype);
        fclose(fid);
        
        recLength(f) = size(data,2);
        disp(['File ' num2str(f) ': ' num2str(count./size(data,1)) ' timepoints, ' num2str(count./size(data,1)./sampRate./60) ' minutes of data']) %testing file count
        clear data
    else
        disp('Invalid file identifier (fid < 0).')
    end
    props.fileNames(f) = fileNames(ind);
end

props.recLength = recLength;
props.sampRate = sampRate;

props.hw_chan = hwChan;

%save properties for fixing spike times after sorting
save([targetdir, 'sortingprops.mat'], 'props')
end
