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
for f = 1:length(fileNums)
    if ~isfolder(fullfile(rawdatadir, ['recording' num2str(fileNums(f)) '.raw']))
        extractSpikeGadgetsBinaryFiles(['recording' num2str(fileNums(f))])
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
    ind = strfind({fileNames.name}, strcat('recording', num2str(fileNums(f))));
    ind = find(~cellfun(@isempty,ind)); %find index of correct rec file

    if ~isempty(ind)
        disp(['Extracting file ', num2str(f), ' of ', num2str(length(fileNums))])
        rawdatafile = [rawdatadir, fileNames(ind).name];
        [filepath, name, ~] = fileparts(rawdatafile);
        numbers = sscanf(name, 'recording%d_%d_%d');
        
        configFileName = fullfile(filepath, [name '.trodesconf']);
        if (~isfile(configFileName)) %check if session-specific config file exists, if not use default
            configInfo = readTrodesFileConfig(rawdatafile);%read configInfo directly from .rec file
        else
            configInfo = readTrodesFileConfig(configFileName);
        end
        
        numChannels = length(channels);
        sampRate = str2double(configInfo.samplingRate);
        
        %save use-defined hardware channel # in the order of nTrode ID (0-based)
        S = [configInfo.nTrodes.('channelInfo')];
        hwChan = [S.hw_chan]';
        
        %create data structure for Kilosort: nChannels x nTimePoints
        for chanID = 1:numChannels
            nTrode = channels(chanID);
            cd (fullfile(rawdatadir, ['recording' num2str(numbers(1)) '.raw'])) %navigate into rec files
            temp = readTrodesExtractedDataFile(['recording' num2str(numbers(1)) '.raw_nt' num2str(nTrode) 'ch1.dat']);
            temp = temp.fields.data .* temp.voltage_scaling; %apply scaling factor to convert to uV
            
            data(chanID,:) = temp;
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
props.numChan = numChannels;
props.hw_chan = hwChan(channels);

%save properties for fixing spike times after sorting
save([targetdir, 'sortingprops.mat'], 'props')
end
