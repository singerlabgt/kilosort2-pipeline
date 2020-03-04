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


%Test - Nuri Spike GAdgets
animal = 11;             
probeChannels = {1:64}; 
brainReg = {'CA3'}; 
rawdatadir = '\\neuro-cloud\labs\singer\RawData\VR_Novelty\'; 
clusterdir = 'C:\Users\njeong9\Documents\TEST\';
processeddatadir = 'C:\Users\njeong9\Documents\TEST\';
spreadsheetdir = '\\neuro-cloud\labs\singer\Nuri\Spreadsheets\VR_NoveltySpreadsheet.xlsx';
clusfolder = 'sorted\';

[allindex, ~] = getallindex_SpikeGadgetsNJ(processeddatadir,...
    spreadsheetdir,'CA3', 1);
allindex = allindex(ismember(allindex(:,1), animal) & allindex(:,4) ~= 0, :);
day = unique(allindex(:,2)); %recording days
day = day(day<200203);

animalID = repmat({'N'}, 1, length(day));

%% Set run options
% writeToBin - first step, run to get .bin for Kilosort2
% getSingleUnitTimes - run after manual curation in Phy2

writeToBIN = 0; 
getSingleUnitTimes = 1; 
getWFstruct = 1;
qualityMetrics = 1; 

%% set rewriting options
% set these options to force the code to rewrite the files specified below. 
% Otherwise, the pipeline will load up previously stored files if they 
% exist. 

rewrite.eeg = 1;
rewrite.wf = 1;
rewrite.qualitymetrics = 1;


%% write raw recording files to BIN for kilosort2

if writeToBIN
    for d = 1:length(day)
        files = allindex(ismember(allindex(:,2), day(d)), 3);
        animal = unique(allindex(ismember(allindex(:,2), day(d)), 1));
        anrawdatadir = [rawdatadir, animalID{d}, num2str(animal), '_', num2str(day(d)), '\'];
        anclusterdir = [clusterdir, animalID{d}, num2str(animal), '_', num2str(day(d)), '\'];
        
        if ~exist(anclusterdir, 'dir'); mkdir(anclusterdir); end
        converttoBIN_K2(anrawdatadir, anclusterdir, files, probeChannels, brainReg, clusfolder)
    end
end

%% get single unit information and times

if getSingleUnitTimes
    for d = 1:length(day)
         files = allindex(ismember(allindex(:,2), day(d)), 3);
         animal = unique(allindex(ismember(allindex(:,2), day(d)), 1));
        anrawdatadir = [rawdatadir, animalID{d}, num2str(animal), '_', num2str(day(d)), '\'];
        anclusterdir = [clusterdir, animalID{d}, num2str(animal), '_', num2str(day(d)), '\'];
        
        makeClusterStructure(anclusterdir, files, brainReg, clusfolder)
    end
end


%% get waveforms and cluster properties

if getWFstruct
    for d = 1:length(day)
        for br = 1:length(brainReg)
            files = allindex(ismember(allindex(:,2), day(d)), 3);
            animal = unique(allindex(ismember(allindex(:,2), day(d)), 1));
            anprocesseddatadir = [processeddatadir, animalID(d), num2str(animal), '_', num2str(day(d)), '\', brainReg{br}, '\'];
            anclusterdir = [clusterdir, animalID{d}, num2str(animal), '_', num2str(day(d)), '\' brainReg{br}, '\',clusfolder];
            figdir = fullfile(anclusterdir, 'figs');
            
            recinfo.iden = animalID(d);
            recinfo.index = [animal day(d)];
            recinfo.files = files;
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
