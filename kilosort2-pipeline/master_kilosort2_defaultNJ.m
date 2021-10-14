addpath(genpath('C:\Users\njeong9\Documents\Kilosort2')) % path to kilosort folder
addpath('C:\Users\njeong9\OneDrive - Emory University\Documents\npy-matlab')
pathToYourConfigFile = '\\ad.gatech.edu\bme\labs\singer\Nuri\Code\kilosort2-pipeline\kilosort2-pipeline';
% pathToYourConfigFile = 'C:\Users\njeong9\OneDrive - Emory University\Documents\Kilosort2';

% badChans = flags.badChans;

%% %%%%%%%%%%%%%%%%%%% to change here %%%%%%%%%%%%%%%%%%%%
username = 'Nuri';
projectname = 'VR_Novelty';
animals = [45];
datesincl = [];
datesexcl = [];


%% get all session indices and user-specific params
[params, dirs] = userProfiles_K2pipeline(username, projectname);
[allindex, ~] = getallindex_basic(dirs.processeddatadir,...
    dirs.spreadsheetdir, 'rewritefileinfo', 0);
allindex = allindex(ismember(allindex(:,1), animals),:);
if ~isempty(datesincl)
    allindex = allindex(ismember(allindex(:,2),datesincl),:);
end
if ~isempty(datesexcl)
    allindex = allindex(~ismember(allindex(:,2),datesexcl),:);
end
brainReg = params.brainReg{1}; %CA3
iden = params.animalIdenLetter;


%% for each unique recording day, run master Kilosort2 script
recDays = unique(allindex(:,2));
for d = 1:length(recDays)
    index = allindex(allindex(:,2) == recDays(d),:);
    index = unique(index(:,1:2));
    % the binary file is in this folder
    rootBIN = fullfile(dirs.processeddatadir, [iden, num2str(index(1)) '_' num2str(index(2))], brainReg, 'sorted','kilosort');
    load(fullfile(rootBIN,'sortingprops.mat'))
    
    
    % determine channel map based on ephys system used
    if ~isempty(dir(fullfile(fullfile(dirs.rawdatadir, [iden, num2str(index(1)) '_' num2str(index(2))]), '*.rhd')))
        ops.chanMap = fullfile(pathToYourConfigFile, 'Takahashi_Intan_um_kilosortChanMap.mat');
    elseif ~isempty(dir(fullfile(fullfile(dirs.rawdatadir, [iden, num2str(index(1)) '_' num2str(index(2))]), '*.rec')))
        ops.chanMap = fullfile(pathToYourConfigFile, 'A64Poly5_SpikeGadgetsChanMap_200213.mat');
    end
    
    %% master-kilosort
    run(fullfile(pathToYourConfigFile, 'configFileNuri.m'))
    ops.fproc       = fullfile(rootBIN, 'temp_wh.dat');    
    ops.trange = [0 Inf]; % time range to sort
    ops.NchanTOT    = 64; % total number of channels in your recording
    
    %% this block runs all the steps of the algorithm
    fprintf('Looking for data inside %s \n', rootBIN)
    
    % is there a channel map file in this folder?
    fs = dir(fullfile(pathToYourConfigFile, '*.mat'));
    if ~isempty(fs)
        ops.chanMap = fullfile(pathToYourConfigFile, fs(1).name);
    end
    
    % find the binary file
    binFiles    = dir(fullfile(rootBIN, '*.bin'));
    fs          = [dir(fullfile(rootBIN, '*.bin')) dir(fullfile(rootBIN, '*.dat'))];
    %     fs          = [binFiles(contains({binFiles.name}, 'CAR')) dir(fullfile(rootBIN, '*.dat'))];
    ops.fbinary = fullfile(rootBIN, fs(1).name);
    
    % preprocess data to create temp_wh.dat
    rez = preprocessDataSub(ops);
    
    % time-reordering as a function of drift
    rez = clusterSingleBatches(rez);
    save(fullfile(rootBIN, 'rez.mat'), 'rez', '-v7.3');
    
    % main tracking and template matching algorithm
    rez = learnAndSolve8b(rez);
    
    % final merges
    rez = find_merges(rez, 1);
    
    % final splits by SVD
    rez = splitAllClusters(rez, 1);
    
    % final splits by amplitudes
    rez = splitAllClusters(rez, 0);
    
    % decide on cutoff
    rez = set_cutoff(rez);
    
    fprintf('found %d good units \n', sum(rez.good>0))
    
    % write to Phy
    fprintf('Saving results to Phy  \n')
    rezToPhy(rez, rootBIN);
    
    %% if you want to save the results to a Matlab file...
    
    % discard features in final rez file (too slow to save)
    rez.cProj = [];
    rez.cProjPC = [];
    
    % save final results as rez2
    fprintf('Saving final results in rez2  \n')
    fname = fullfile(rootBIN, 'rez2.mat');
    save(fname, 'rez', '-v7.3');
    
end
