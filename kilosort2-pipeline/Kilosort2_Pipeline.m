% Kilosort 2 Pipeline
% Singer Lab - July 2019
%
% This pipeline creates .BIN files for Kilosort2 clustering, saves
% sorted spike structure output, and applies automatic curation metrics. 
%
% ALP 7/01/19

clear; close all;

%% Set parameters
% animal and day: 1xN vect of same length 
% files: cell array with each element containing 1xN vect of desired files
% probeChannels: cell array with each element containing 1xN vect of 
%   channels of desired region. channels should be 0 based. 
% brainReg: cell array of brain regions with same length as probeChannels. 
%    can be {''} if desired
% animalID: cell array of ID letters with same length as brainReg
%
% NOTE: multiple brainReg only debugged for INTAN, need to implement for
% spike gadgets ALP 7/14/19

%Nuri
% animal = 9;             
% day = 190804;
% files = {1:8};  
% probeChannels = {1:32}; 
% brainReg = {'CA3'}; 
% animalID = 'N';
% rawdatadir = '\\neuro-cloud\labs\singer\RawData\RigB_SpikeGadgets\'; 
% clusterdir = '\\neuro-cloud\labs\singer\Nuri\Clustering\';
% processeddatadir = '\\neuro-cloud\labs\singer\ProcessedData\VR_Novelty\';

%Test - Abby Intan
% animal = 7;             
% day = 190214;
% files = {1:2};  
% probeChannels = {33:64}; 
% brainReg = {'CA1'}; 
% animalID = {'A'};
% rawdatadir = 'Y:\singer\RawData\Flicker_CA1CA3\'; 
% clusterdir = 'C:\Users\apaulson3\Desktop\KilosortTesting\Spike Gadgets\'; %this may be the same as processeddatadir
% processeddatadir = 'Y:\singer\ProcessedData\Flicker_7Day_CA1CA3\'; %may be the same as above



% recinfo = struct('animal', animal

%Test - Nuri Spike GAdgets
animal = 11;             
<<<<<<< Updated upstream
<<<<<<< Updated upstream
day = 200130;
files = {1:9};  
=======
day = 200131;
files = {1:7};  
>>>>>>> Stashed changes
probeChannels = {1:64}; 
brainReg = {'CA3'}; 
animalID = {'N'};
=======
day = 200131;
files = {1:7};  
probeChannels = {1:64}; 
brainReg = {'CA3'}; 
animalID = 'N';
>>>>>>> Stashed changes
rawdatadir = '\\neuro-cloud\labs\singer\RawData\VR_Novelty\'; 
clusterdir = '\\neuro-cloud\labs\singer\ProcessedData\VR_Novelty\';
processeddatadir = '\\neuro-cloud\labs\singer\ProcessedData\VR_Novelty\';
clusfolder = 'sorted\';
%% Set run options
% writeToBin - first step, run to get .bin for Kilosort2
% getSingleUnitTimes - run after manual curation in Phy2

<<<<<<< Updated upstream
<<<<<<< Updated upstream
writeToBIN = 1; 
getSingleUnitTimes = 0; 
getWFstruct = 0;
qualityMetrics = 0; 
=======
=======
>>>>>>> Stashed changes
writeToBIN = 0; 
getSingleUnitTimes = 1; 
getWFstruct = 1;
qualityMetrics = 1; 
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

%% set rewriting options
% set these options to force the code to rewrite the files specified below. 
% Otherwise, the pipeline will load up previously stored files if they 
% exist. 

rewrite.eeg = 0;
rewrite.wf = 0;
rewrite.qualitymetrics = 0;


%% write raw recording files to BIN for kilosort2

if writeToBIN
    for d = 1:length(day)
        anrawdatadir = [rawdatadir, animalID{d}, num2str(animal(d)), '_', num2str(day(d)), '\'];
        anclusterdir = [clusterdir, animalID{d}, num2str(animal(d)), '_', num2str(day(d)), '\'];
        
        if ~exist(anclusterdir, 'dir'); mkdir(anclusterdir); end
        converttoBIN_K2(anrawdatadir, anclusterdir, files{d}, probeChannels, brainReg, clusfolder)
    end
end

%% get single unit information and times

if getSingleUnitTimes
    for d = 1:length(day)
        anrawdatadir = [rawdatadir, animalID(d), num2str(animal(d)), '_', num2str(day(d)), '\'];
        anclusterdir = [clusterdir, animalID(d), num2str(animal(d)), '_', num2str(day(d)), '\'];
        
        makeClusterStructure(anclusterdir, files{d}, brainReg, clusfolder)
    end
end


%% get waveforms and cluster properties

if getWFstruct
    for d = 1:length(day)
        for br = 1:length(brainReg)
            anprocesseddatadir = [processeddatadir, animalID(d), num2str(animal(d)), '_', num2str(day(d)), '\', brainReg{br}, '\'];
            anclusterdir = [clusterdir, animalID(d), num2str(animal(d)), '_', num2str(day(d)), '\' brainReg{br}, '\',clusfolder];
            figdir = fullfile(anclusterdir, 'figs');
            
            recinfo.iden = animalID(d);
            recinfo.index = [animal(d) day(d)];
            recinfo.files = files{d};
            recinfo.brainReg = brainReg{br};
            
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
    for d = 1:length(day)
        for br = 1:length(brainReg)
            anclusterdir = fullfile(clusterdir, [animalID(d), num2str(animal(d)), '_', num2str(day(d))], brainReg{br}, clusfolder);
            
            recinfo.iden = animalID(d); 
            recinfo.index = [animal(d) day(d)]; 
            recinfo.files = files{d}; 
            recinfo.brainReg = brainReg{br}; 
            
            applyQualityMetrics(anclusterdir, recinfo, rewrite.qualitymetrics, th)
        end
    end
end
