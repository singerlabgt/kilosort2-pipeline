% Kilosort 2 Pipeline
% Singer Lab - July 2019
%
% This pipeline creates .BIN files for Kilosort2 clustering, saves
% sorted spike structure output, and applies automatic curation metrics.
%
% ALP 7/01/19

clear; close all;

%% Set parameters

%input animal info and project settings
[params, dirs, th] = userProfiles_K2pipeline('Steph', 'UpdateTask');

animals = [20];
days = [210510:210521];

%get the animal info based on the inputs
allindexT = selectindextable(dirs.spreadsheetdir, 'animal', animals, 'datesincluded', days);
allindex = allindexT{:,{'Animal', 'Date','Recording'}};
[sessions, ind] = unique(allindex(:,1:2), 'rows'); %define session as one date

%% Set run options
%First, run the preCuration step. 
%After manually curation the Kilosort2 output, run the postCuration step. 

run.preCuration = 1;            %write specificed files to .bin for Kilosort
run.kilosortScript = 1;         %run kilosort spike sorting using main_kilosort script
run.kilosortGUI = 0;            %run kilosort spike sorting using the gui
run.transferPrecuratedData = 1; %automatically transfer precurated data to server, removes locally
run.postCuration = 0;           %get single unit times, get waveforms, and apply quality metrics

%% Set rewriting options
% set these options to force the code to rewrite the files specified below.
% Otherwise, the pipeline will load up previously stored files if they
% exist.
rewrite.eeg = 0;
rewrite.wf = 1;
rewrite.qualitymetrics = 1;

%% Run Kilosort Pipeline
for d = 1:numel(sessions)
    %% get the animal/day info
    sessionInfo = allindex(ismember(allindex(:,1:2), sessions(d,:), 'rows'),:);
    params.files = sessionInfo(:,3);
    params.animal = sessionInfo(1,1);
    params.day =  sessionInfo(1,2);
    params.brainReg = allindexT{allindexT.Date == params.day & allindexT.Recording == params.files(1),{'RegAB','RegCD'}};
    
    %% write raw recording files to BIN for kilosort2
    if run.preCuration
        anrawdatadir = [dirs.rawdatadir, params.animalID, num2str(params.animal), '_', num2str(params.day), '\'];
        tempfiledir = [dirs.processeddatadir, params.animalID, num2str(params.animal), '_', num2str(params.day), '\'];
        anclusterdir = [dirs.localclusterdir, params.animalID, num2str(params.animal), '_', num2str(params.day), '\'];
        
        if ~exist(anclusterdir, 'dir'); mkdir(anclusterdir); end
        converttoBIN_K2(anrawdatadir, anclusterdir, params.files, params.probeChannels, params.brainReg, dirs.clusfolder)
    end
    
    %% run kilosort algorithm
    if run.kilosortGUI
        kilosort
        pause
    end
    
    if run.kilosortScript
        for br = 1:length(params.brainReg)
            %run kilosort algorithm on data
            anid = [params.animalID, num2str(params.animal), '_', num2str(params.day)];
            anclusterdir = fullfile(dirs.localclusterdir, anid, params.brainReg{br}, dirs.clusfolder, 'kilosort', filesep);
            channels = max(params.probeChannels{br})-min(params.probeChannels{br})+1;
            main_kilosort(anclusterdir, dirs, params, channels)
            
            %transfer precurated data
            if run.transferPrecuratedData
                fullclusterdir = fullfile(dirs.localclusterdir, anid, params.brainReg{br}, filesep); %only the top folder
                transferKilosortPrecuratedData(fullclusterdir, dirs);
            end
        end
    end
    
    %% curate the data manually
    % run the following lines in a GitBash or Anaconda terminal
    % Note: the exact path is the output of 'anclusterdir' in matlab
    % Note: if the files have been transferred to the server, you will likely
    % want to transfer them back to the local computer before curating

    % cd "C:\Users\YourGTID\Desktop\TempKilosort\YourSessionID\YourBrainRegion\sorted\kilosort\"
    % conda activate phy2
    % phy template-gui params.py
    
    %% get single unit times, waveforms, cluster properties, and apply quality metrics

    if run.postCuration
        for br = 1:length(params.brainReg)
            recinfo.iden = params.animalID;
            recinfo.index = [params.animal params.day];
            recinfo.files = params.files;
            recinfo.brainReg = params.brainReg{br};
            
            anprocesseddatadir = [dirs.processeddatadir, params.animalID, num2str(params.animal), '_', num2str(params.day), '\', params.brainReg{br}, '\'];
            anclusterdir = fullfile(dirs.localclusterdir, [params.animalID, num2str(params.animal), '_', num2str(params.day)], params.brainReg{br}, dirs.clusfolder, '\');
            figdir = fullfile(anclusterdir, 'figs');
            
            %get information about the curated units from the kilsort and
            %phy files
            makeClusterStructure(anclusterdir, recinfo, dirs.clusfolder, params, br)
            
            %get waveforms and other metrics about each cluster
            getWaveForms_K2(anprocesseddatadir, anclusterdir, recinfo, figdir, rewrite)
            
            %apply quality metrics to all clusters and create outputs
            %structures
            applyQualityMetrics(anclusterdir, recinfo, rewrite.qualitymetrics, th)
        end
    end
end





