% Kilosort 2 Pipeline
% Singer Lab - July 2019
%
% This pipeline creates .BIN files for Kilosort2 clustering, saves
% sorted spike structure output, and applies automatic curation metrics.
%
% ALP 7/01/19

clear; close all;

%% Set parameters
% NOTE: multiple brainReg only debugged for INTAN, need to implement for
% spike gadgets ALP 7/14/19

[params, dirs] = userProfiles_K2pipeline('Abby', 'ChronicFlicker');
[allindex, ~] = getallindexALP(dirs.processeddatadir, dirs.spreadsheetdir, 0);

allindex = allindex(allindex(:,1) == 45 | allindex(:,1) == 46,:); 
dayindex = unique(allindex(:,1:2), 'rows');

params.animal = dayindex(:,1);
params.day = dayindex(:,2);
params.files = arrayfun(@(x) {allindex(allindex(:,2) == dayindex(x,2),3)}, 1:size(dayindex,1));

%% Set run options
%First, run the preCuration step. 
%After manually curation the Kilosort2 output, run the postCuration step. 

run.preCuration = 1; %write specificed files to .bin for Kilosort
run.postCuration = 0; %get single unit times, get waveforms, and apply quality metrics

%% Set rewriting options
% set these options to force the code to rewrite the files specified below.
% Otherwise, the pipeline will load up previously stored files if they
% exist.

rewrite.eeg = 1;
rewrite.wf = 1;
rewrite.qualitymetrics = 1;

%% Quality control thresholds
% !!!!!! Do not change without notifying all users !!!!!!

th.SNR =  1;                    % >= 1 SNR
th.ISI = 0.008;                 % <= 0.8% refractory period violations
th.refractoryPeriod = 0.001;    % 1ms refractory period duration
th.info = '>= th.SNR, <= th.ISI (frac violations/allISI), th.refractoryPeriod in s';
% th.noiseOverlap
% th.isolation

%% write raw recording files to BIN for kilosort2

if run.preCuration
    for d = 1:length(params.day)
        anrawdatadir = [dirs.rawdatadir, params.animalID, num2str(params.animal(d)), '_', num2str(params.day(d)), '\'];
        tempfiledir = [dirs.processeddatadir, params.animalID, num2str(params.animal(d)), '_', num2str(params.day(d)), '\'];
        anclusterdir = [dirs.clusterdir, params.animalID, num2str(params.animal(d)), '_', num2str(params.day(d)), '\'];
        
        if ~exist(anclusterdir, 'dir'); mkdir(anclusterdir); end
        converttoBIN_K2(anrawdatadir, anclusterdir, params.files{d}, params.probeChannels, params.brainReg, dirs.clusfolder)
    end
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
            anclusterdir = fullfile(dirs.clusterdir, [params.animalID, num2str(params.animal(d)), '_', num2str(params.day(d))], params.brainReg{br}, dirs.clusfolder, '\');
            figdir = fullfile(anclusterdir, 'figs');
            
            %get information about the curated units from the kilsort and
            %phy files
            makeClusterStructure(anclusterdir, recinfo, params.brainReg{br}, dirs.clusfolder, params.numShanks)
            
            %get waveforms and other metrics about each cluster
            getWaveForms_K2(anprocesseddatadir, anclusterdir, recinfo, figdir, rewrite)
            
            %apply quality metrics to all clusters and create outputs
            %structures
            applyQualityMetrics(anclusterdir, recinfo, rewrite.qualitymetrics, th)
        end
    end
end
