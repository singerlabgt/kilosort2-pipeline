<<<<<<< Updated upstream
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

animal = 9;             
day = 190804;
files = {1:8};  
probeChannels = {1:32}; 
brainReg = {'CA3'}; 
animalID = 'N';
rawdatadir = 'Y:\singer\RawData\RigB_SpikeGadgets\'; 
clusterdir = 'Y:\singer\Nuri\Clustering\';
clusfolder = 'sorted\';

%% Set run options

writeToBIN = 0;
getSingleUnitTimes = 1;
getWFstruct = 0;

%% write raw recording files to BIN for kilosort2

if writeToBIN
    for d = 1:length(day)
        anrawdatadir = [rawdatadir, animalID, num2str(animal(d)), '_', num2str(day(d)), '\'];
        anclusterdir = [clusterdir, animalID, num2str(animal(d)), '_', num2str(day(d)), '\'];
        
        if ~exist(anclusterdir, 'dir'); mkdir(anclusterdir); end
        converttoBIN_K2(anrawdatadir, anclusterdir, files{d}, probeChannels, brainReg, clusfolder)
    end
end

%% get single unit information and times

if getSingleUnitTimes
    for d = 1:length(day)
        anrawdatadir = [rawdatadir, animalID, num2str(animal(d)), '_', num2str(day(d)), '\'];
        anclusterdir = [clusterdir, animalID, num2str(animal(d)), '_', num2str(day(d)), '\'];
        
        makeClusterStructure(anclusterdir, files{d}, brainReg, clusfolder)
    end
end

%% get waveforms - will be incorporated

% params.dataDir = anclusterdir;
% params.fileName = 'allrecordings.bin'; 
% params.dataType = 'int16';
% params.nCh = 32;
% params.wfWin = [-40 40]; 
% params.nWf = 2000;
% params.spikeTimes = spiketimes(spikeID==2);
% params.spikeClusters = 2*ones(1,length(params.spikeTimes));
% params.samprate = 20000; 

% wf = getWaveForms(params); 

if getWFstruct
    for d = 1:length(day)
        anrawdatadir = [rawdatadir, animalID, num2str(animal(d)), '_', num2str(day(d)), '\'];
        anclusterdir = [clusterdir, animalID, num2str(animal(d)), '_', num2str(day(d)), '\'];
        
        getWaveForms_K2(anrawdatadir, anclusterdir, files{d}, probeChannels, brainReg, clusfolder)
    end
end

%% apply quality metrics - will be incorporated

% %getSNR
% datPars.nCh = 32;
% datPars.dataType = 'int16';
% datPars.wfWin = [-30 30];
% datPars.Fs = 20000;
% datPars.makePlots = true;
% datPars.nSpikesToUse = 5000;
% datPars.filename = [anclusterdir, 'allrecordings.bin']; 
% datPars.chanMap = readNPY(fullfile(anclusterdir, 'channel_map.npy'))+1;
% 
% snr = trueSpikeSNR(datPars, spiketimes(spikeID==2)); 
=======
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
probeChannels = {1:32}; 
brainReg = {'CA3'}; 
animalID = 'N';
rawdatadir = 'Y:\singer\RawData\RigB_SpikeGadgets\'; 
clusterdir = 'Y:\singer\Nuri\Clustering\';
processeddatadir = 'Y:\singer\ProcessedData\VR_Novelty\';
spreadsheetdir = 'Y:\singer\Nuri\Spreadsheets\VR_NoveltySpreadsheet.xlsx';

% Get all indices
[allindex, ~] = getallindex_SpikeGadgetsNJ(processeddatadir,...
    spreadsheetdir,'ca3', 1);
allindex = allindex(allindex(:,2) >190624,:);
allindex = allindex(allindex(:,2) ~= 190719,:);
allindex = allindex(allindex(:,2) ~= 190806,:);

day = unique(allindex(:,2));

%Test - Abby Intan
% animal = 7;             
% day = 190214;
% files = {1};  
% probeChannels = {33:64}; 
% brainReg = {'CA1'}; 
% animalID = {'A'};
% rawdatadir = 'Y:\singer\RawData\Flicker_CA1CA3\'; 
% clusterdir = 'C:\Users\apaulson3\Desktop\KilosortTesting\Spike Gadgets\';
% processeddatadir = 'Y:\singer\ProcessedData\Flicker_7Day_CA1CA3\';

clusfolder = 'sorted\';

%Test - Nuri Spike GAdgets
% animal = 1;             
% day = 190619;
% files = {1};  
% probeChannels = {1:32}; 
% brainReg = {''}; 
% animalID = {'N'};
% rawdatadir = 'C:\Users\apaulson3\Desktop\KilosortTesting\Spike Gadgets\CA3\'; 
% clusterdir = 'C:\Users\apaulson3\Desktop\KilosortTesting\Spike Gadgets\CA3\';
% % processeddatadir = 'Y:\singer\ProcessedData\Flicker_7Day_CA1CA3\';
% clusfolder = '';

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
rewrite.wf = 0;

%% write raw recording files to BIN for kilosort2

if writeToBIN
    for d = 1:length(day)
        animal = unique(allindex(allindex(:,2) == day(d),1));
        files = unique(allindex(allindex(:,2) == day(d),3));
        
        anrawdatadir = [rawdatadir, animalID, num2str(animal), '_', num2str(day(d)), '\'];
        anclusterdir = [clusterdir, animalID, num2str(animal), '_', num2str(day(d)), '\'];
        
        if ~exist(anclusterdir, 'dir'); mkdir(anclusterdir); end
        converttoBIN_K2(anrawdatadir, anclusterdir, files(d), probeChannels, brainReg, clusfolder)
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
            anprocesseddatadir = [processeddatadir, animalID(d), num2str(animal(d)), '_', num2str(day(d)), '\', brainReg{br}, '\'];
            anclusterdir = fullfile(clusterdir, [animalID(d), num2str(animal(d)), '_', num2str(day(d))], brainReg{br}, clusfolder);
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
th.ISI = 0.0001;                % <= 0.01% refractory period violations
th.refractoryPeriod = 0.001;    % 1ms refractory period duration
th.noiseOverlap
th.isolation

if qualityMetrics 
    for d = 1:length(day)
        for br = 1:length(brainReg)
            
        end
    end
end
>>>>>>> Stashed changes
