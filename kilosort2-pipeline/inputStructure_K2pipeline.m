% Make Inputs for KiloSort2 Pipeline
%
% ALP 8/05/19

%% defaults

%% Abby

params.animal = [22];             
params.day = [200130];
params.files = {1};  
params.probeChannels = {65:128}; %should be the indices of the channels in the data structure totalCh x samples
params.brainReg = {'CA1'}; 
params.animalID = {'A'};
params.numShanks = 2;

dirs.rawdatadir = '\\neuro-cloud\labs\singer\RawData\Flicker_Chronic_VR\'; 
dirs.clusterdir = 'C:\Users\apaulson3\Desktop\Temp Kilosort\'; %this may be the same as processeddatadir
dirs.processeddatadir = 'Y:\singer\ProcessedData\Flicker_7Day_VR\'; %may be the same as above

