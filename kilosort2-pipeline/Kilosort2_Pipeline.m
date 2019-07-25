% Kilosort 2 Pipeline
% Singer Lab - July 2019
%
% This pipeline creates .BIN files for Kilosort2 clustering, saves
% sorted spike structure output, and applies automatic curation metrics. 
%
% ALP 7/01/19

clear; close all;

%% Set parameters
% Animal and day should be 1xN vect of same length. Files
% should be cell array with each element containing vect of desired files.
% probe channels should be cell array of same length as brainReg, with each
% element containing channels of desired region. brainreg can be {''} if
% desired. 
%
% NOTE: multiple brainReg only debugged for INTAN, need to implement for
% spike gadgets ALP 7/14/19

animal = 7;             
day = 190214;
files = {1};  
probeChannels = {33:64}; 
brainReg = {'CA1'}; 
animalID = {'A'};
rawdatadir = 'Y:\singer\RawData\Flicker_CA1CA3\'; 
clusterdir = 'C:\Users\apaulson3\Desktop\KilosortTesting\Spike Gadgets\';
processeddatadir = 'Y:\singer\ProcessedData\Flicker_7Day_CA1CA3\';
clusfolder = 'sorted\';

%% Set run options
% writeToBin - first step, run to get .bin for Kilosort2
% getSingleUnitTimes - run after manual curation in Phy2

writeToBIN = 0; 
getSingleUnitTimes = 0; 
getWFstruct = 1;
applyQualityMetrics = 0; 

%% set rewriting options
% set these options to force the code to rewrite the filtered EEG files, or
% the waveform files. Otherwise, the pipeline will load up previously
% stored files if they exist. 

rewrite.eeg = 0;
rewrite.wf = 1;

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
        anrawdatadir = [rawdatadir, animalID{d}, num2str(animal(d)), '_', num2str(day(d)), '\'];
        anclusterdir = [clusterdir, animalID{d}, num2str(animal(d)), '_', num2str(day(d)), '\'];
        
        makeClusterStructure(anclusterdir, files{d}, brainReg, clusfolder)
    end
end

%% get waveforms and cluster properties

if getWFstruct
    for d = 1:length(day)
        for br = 1:length(brainReg)
            anprocesseddatadir = [processeddatadir, animalID{d}, num2str(animal(d)), '_', num2str(day(d)), '\', brainReg{br}, '\'];
            anclusterdir = fullfile(clusterdir, [animalID{d}, num2str(animal(d)), '_', num2str(day(d))], brainReg{br}, clusfolder);
            figdir = fullfile(anclusterdir, 'figs');
            
            recinfo.iden = animalID{d}; 
            recinfo.index = [animal(d) day(d)]; 
            recinfo.files = files{d}; 
            recinfo.brainReg = brainReg{br}; 
            
            getWaveForms_K2(anprocesseddatadir, anclusterdir, recinfo, figdir, rewrite)
        end
    end
end

%% apply quality metrics and make final clusters structure

if applyQualityMetrics 
end
