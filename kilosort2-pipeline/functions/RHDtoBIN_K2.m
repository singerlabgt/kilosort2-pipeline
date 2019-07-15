function RHDtoBIN_K2(datapath, targetpath, dtype, filenum, probechannels)
% RHDTOBIN_K2   Convert intan .rhd files to .bin for Kilosort2
%
% Read an RHD file and write it in binary form to a new file
% Count number of 'Recording#_*.rhd' files and concatenate onto the output
% file for each one; This is the form required for Kilosort2 analysis
%
%       datafolder: full path to the recording files of interest, including last backslash
%       targetpath: full path to cluster directory
%       filenum: 1xN array that corresponds to recording # (e.g. recording1_...)
%
%       Put all desired rhd files to extract from in the datafolder directory;
%       temporal continuity must correspond to filename alphabetical
%       ordering
%
% ALP 7/12/19

numRecs = length(filenum);
datafolder = cell(1,numRecs);
for i = 1:numRecs
    datafolder{i} = datapath;
end

% Save all as one big file
for j = 1:numRecs
    % Map the directory
    files=dir(datafolder{j});
    indrightfile=[];
    for f=1:length(files)
        if strfind(files(f).name, strcat('recording', num2str(filenum(j))))
            indrightfile=[indrightfile; f]; % get inds ofdesired files
        end
    end
    numfiles=length(indrightfile);
    targetfile = [targetpath 'allrecordings.bin'];  
    recLength = zeros(1,numRecs); 
    
    for i=1:numfiles
        %------send files to intan code to be processed---------
        fprintf('Loading RHD data from file %d of %d...\n',i,numfiles)
        
        % Get data from modified Intan code
        data = get_Intan_RHD2000_file_K2(datafolder{j}, ...
            files(indrightfile(i)).name,1,0, probechannels);
        
        % Return the channel and frequency parameters from the first file
        % Data should be 32 x N, where N is number of samples, each row a
        % channel
        if(i==1) && (j==1)
            f1 = fopen(targetfile,'w');
        else
            f1 = fopen(targetfile,'a');
        end

        probedata = data{1};
        fwrite(f1,probedata,dtype);
        fclose(f1);    
        
        recLength(j) = recLength(j)+size(data{1},2); 
        clear probedata
    end
end

props.recLength = recLength;
props.sampRate = 20000;
props.fileNums = filenum;

%save properties for fixing spike times after sorting
save([targetpath, 'sortingprops.mat'], 'props')
end