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

params.animal = 20;
params.day = 210512;

%get the animal info based on
allindexT = selectindextable(dirs.spreadsheetdir, 'animal', params.animal, 'datesincluded', params.day);
allindex = allindexT{:,{'Animal', 'Date','Recording'}};
params.files = {allindex(:,3)};

[sessions, ind] = unique(allindex(:,1:2), 'rows'); %define session as one date
params.brainReg = allindexT{ind,{'RegAB','RegCD'}};

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

%% write raw recording files to BIN for kilosort2

if run.preCuration
    for d = 1:length(params.day)
        anrawdatadir = [dirs.rawdatadir, params.animalID, num2str(params.animal(d)), '_', num2str(params.day(d)), '\'];
        tempfiledir = [dirs.processeddatadir, params.animalID, num2str(params.animal(d)), '_', num2str(params.day(d)), '\'];
        anclusterdir = [dirs.localclusterdir, params.animalID, num2str(params.animal(d)), '_', num2str(params.day(d)), '\'];
        
        if ~exist(anclusterdir, 'dir'); mkdir(anclusterdir); end
        converttoBIN_K2(anrawdatadir, anclusterdir, params.files{d}, params.probeChannels, params.brainReg, dirs.clusfolder)
    end
end


%% run kilosort algorithm
if run.kilosortScript
    for d = 1:length(params.day)
        for br = 1:length(params.brainReg)
            %run kilosort algorithm on data
            anid = [params.animalID, num2str(params.animal(d)), '_', num2str(params.day(d))];
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
elseif run.kilosortGUI
    kilosort
    pause
end

%% get single unit times, waveforms, cluster properties, and apply quality metrics

if run.postCuration
    for d = 1:length(params.day)
        for br = 1:length(params.brainReg)
            recinfo.iden = params.animalID; 
            recinfo.index = [params.animal(d) params.day(d)]; 
            recinfo.files = params.files{d}; 
            recinfo.brainReg = params.brainReg{br}; 
            
            anprocesseddatadir = [dirs.processeddatadir, params.animalID, num2str(params.animal(d)), '_', num2str(params.day(d)), '\', params.brainReg{br}, '\'];
            anclusterdir = fullfile(dirs.localclusterdir, [params.animalID, num2str(params.animal(d)), '_', num2str(params.day(d))], params.brainReg{br}, dirs.clusfolder, '\');
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
