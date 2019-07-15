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
probeChannels = {1:32}; 
brainReg = {''}; 
animalID = '';
rawdatadir = 'C:\Users\apaulson3\Desktop\KilosortTesting\Spike Gadgets\'; 
clusterdir = 'C:\Users\apaulson3\Desktop\KilosortTesting\Spike Gadgets\';
clusfolder = 'sorted\';

%% Set run options

writeToBIN = 0;
getSingleUnitTimes = 1;

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
        
        makeClusterStructure(anrawdatadir, anclusterdir, files{d}, probeChannels, brainReg, clusfolder)
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
