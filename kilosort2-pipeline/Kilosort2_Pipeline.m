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
params.animal = [22];
params.day = [200202];
params.files = {1:3};


%% Set run options
% writeToBin - first step, run to get .bin for Kilosort2
% getSingleUnitTimes - run after manual curation in Phy2

writeToBIN = 1; 
getSingleUnitTimes = 0; 
getWFstruct = 0;
qualityMetrics = 0; 

%% set rewriting options
% set these options to force the code to rewrite the files specified below.
% Otherwise, the pipeline will load up previously stored files if they
% exist.

rewrite.eeg = 0;
rewrite.wf = 1;
rewrite.qualitymetrics = 0;


%% write raw recording files to BIN for kilosort2

if writeToBIN
    for d = 1:length(params.day)
        anrawdatadir = [dirs.rawdatadir, params.animalID{d}, num2str(params.animal(d)), '_', num2str(params.day(d)), '\'];
        tempfiledir = [dirs.processeddatadir, params.animalID{d}, num2str(params.animal(d)), '_', num2str(params.day(d)), '\'];
        anclusterdir = [dirs.clusterdir, params.animalID{d}, num2str(params.animal(d)), '_', num2str(params.day(d)), '\'];
        
        if ~exist(anclusterdir, 'dir'); mkdir(anclusterdir); end
        converttoBIN_K2(anrawdatadir, anclusterdir, params.files{d}, params.probeChannels, params.brainReg, dirs.clusfolder)
    end
end

%% get single unit information and times

if getSingleUnitTimes

    for d = 1:length(params.day(d))
        anrawdatadir = [dirs.rawdatadir, params.animalID{d}, num2str(params.animal(d)), '_', num2str(params.day(d)), '\'];
        anclusterdir = [dirs.clusterdir, params.animalID{d}, num2str(params.animal(d)), '_', num2str(params.day(d)), '\'];
        
        makeClusterStructure(anclusterdir, params.files{d}, params.brainReg, clusfolder, numShanks)

    end
end


%% get waveforms and cluster properties

if getWFstruct
    for d = 1:length(params.day(d))
        for br = 1:length(params.brainReg)
            anprocesseddatadir = [dirs.processeddatadir, params.animalID{d}, num2str(params.animal(d)), '_', num2str(params.day(d)), '\', params.brainReg{br}, '\'];
            anclusterdir = [dirs.clusterdir, params.animalID{d}, num2str(params.animal(d)), '_', num2str(params.day(d)), '\' params.brainReg{br}, '\', clusfolder];
            figdir = fullfile(anclusterdir, 'figs');
            
            recinfo.iden = params.animalID{d}; 
            recinfo.index = [params.animal(d) params.day(d)]; 
            recinfo.files = params.files{d}; 
            recinfo.brainReg = params.brainReg{br}; 

            
            getWaveForms_K2(anprocesseddatadir, anclusterdir, recinfo, figdir, rewrite)
        end
    end
end

%% apply quality metrics and make final clusters structure
% Things I know I can do: SNR, ISI
% Things I want to do: isolation against other units

th.SNR =  1;                    % >= 1 SNR
th.ISI = 0.008;                % <= 0.8% refractory period violations
th.refractoryPeriod = 0.001;    % 1ms refractory period duration
th.info = '>= th.SNR, <= th.ISI (frac violations/allISI), th.refractoryPeriod in s';
% th.noiseOverlap
% th.isolation

if qualityMetrics
    for d = 1:length(params.day(d))
        for br = 1:length(params.brainReg)
            anclusterdir = fullfile(dirs.clusterdir, [params.animalID{d}, num2str(params.animal(d)), '_', num2str(params.day(d))], params.brainReg{br}, clusfolder);
            
            recinfo.iden = params.animalID{d}; 
            recinfo.index = [params.animal(d) params.day(d)]; 
            recinfo.files = params.files{d}; 
            recinfo.brainReg = params.brainReg{br}; 
            
            applyQualityMetrics(anclusterdir, recinfo, rewrite.qualitymetrics, th)
        end
    end
end
