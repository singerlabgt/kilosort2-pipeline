function [params, dirs, th] = userProfiles_K2pipeline(user, project)
%userProfiles_K2pipeline
%
%ALP 2/19/20

%% Parameters
% animal and day: 1xN vect of same length 
% files: cell array with each element containing 1xN vect of desired files
% probeChannels: cell array with each element containing 1xN vect of 
%   channels of desired region. channels should be 1 based. 
% brainReg: cell array of brain regions with same length as probeChannels. 
%    can be {''} if desired
% animalID: ID letter

%% Quality control thresholds
% !!!!!! Do not change without notifying all users !!!!!!

th.SNR =  1;                    % >= 1 SNR
th.ISI = 0.008;                 % <= 0.8% refractory period violations
th.refractoryPeriod = 0.001;    % 1ms refractory period duration
th.info = '>= th.SNR, <= th.ISI (frac violations/allISI), th.refractoryPeriod in s';
% th.noiseOverlap
% th.isolation

%% User Profiles

%%%%%%%%%%%%%%%%% ----- Abby ----- %%%%%%%%%%%%%%
if strcmp(user, 'Abby')
    if strcmp(project, 'ChronicFlicker')
        params.probeChannels = {65:128}; %should be the 1 based indices of the channels in the data structure totalCh x samples
        params.brainReg = {'CA1'};
        params.animalID = 'A';
        params.numShanks = 2;
        
        dirs.rawdatadir = '\\neuro-cloud\labs\singer\RawData\Flicker_Chronic_VR\';
        dirs.localclusterdir = 'C:\Users\apaulson3\Desktop\TempKilosort\'; %this may be the same as processeddatadir
        dirs.remoteclusterdir = '\\neuro-cloud\labs\singer\ProcessedData\Flicker_7Day_VR\';
        dirs.processeddatadir = '\\neuro-cloud\labs\singer\ProcessedData\Flicker_7Day_VR\'; %may be the same as above  
        dirs.clusfolder = 'sorted\'; %subfolder that finished files will save into
        dirs.spreadsheetdir = '\\neuro-cloud.ad.gatech.edu\labs\singer\Abby\experimentspreadsheets\chronicflicker_annulartrack_ephys.xls';

    end
end

%%%%%%%%%%%%%%%%% ----- Steph ----- %%%%%%%%%%%%%%
if strcmp(user, 'Steph')
    if strcmp(project, 'UpdateTask')
        params.animalID = 'S';
        params.numShanks = 2;
        params.probeChannels = {1:64,65:128}; %should be the 1 based indices of the channels in the data structure totalCh x samples
        
        %files for saving/loading data
        dirs.rawdatadir = '\\neuro-cloud\labs\singer\RawData\UpdateTask\';
        dirs.localclusterdir = 'C:\Users\sprince7\Desktop\TempKilosort\'; %this may be the same as processeddatadir
        dirs.remoteclusterdir = '\\neuro-cloud\labs\singer\ProcessedData\UpdateTask\';
        dirs.processeddatadir = '\\neuro-cloud\labs\singer\ProcessedData\UpdateTask\'; %may be the same as above  
        dirs.clusfolder = 'sorted\'; %subfolder that finished files will save into
        dirs.spreadsheetdir = '\\neuro-cloud.ad.gatech.edu\labs\singer\Steph\Code\update-project\doc\VRUpdateTaskEphysSummary.xlsx';
        dirs.remoteprecurationdir = '\\neuro-cloud\labs\singer\KilosortData\update-project\'; %folder for transferring data between computers, storing precurated data
        
        %files to add to path for kilosort sorting
        dirs.kilosortdir = 'C:\Users\sprince7\Documents\Kilosort-2.0';
        dirs.npymatlabdir = 'C:\Users\sprince7\Documents\npy-matlab-master\npy-matlab';
        dirs.configfile = '\\neuro-cloud.ad.gatech.edu\labs\singer\Steph\Code\kilosort2-pipeline\kilosort2-pipeline\configFiles\StephUpdateTaskConfig.m';
        dirs.channelmapfile = '\\neuro-cloud.ad.gatech.edu\labs\singer\Steph\Code\kilosort2-pipeline\kilosort2-pipeline\channelMaps\A64Poly5_SpikeGadgets_RigC_kilosortChanMap.mat';
    end
end

%%%%%%%%%%%%%%%%% ----- New User ----- %%%%%%%%%%%%%%%

if strcmp(user, 'NewUser')
  if strcmp(project, 'NewProject')
        params.probeChannels = {1:32}; %should be the indices of the channels in the data structure totalCh x samples
        params.brainReg = {'CA1'}; %your brain region here 
        params.animalID = 'A'; %sub your animal prefix here
        params.numShanks = 1; % how many shanks does your probe have? 
        
        dirs.rawdatadir = ''; %the location of your raw data files
        dirs.clusterdir = ''; %where you want your cluster files to end up
        dirs.processeddatadir = ''; %where the processed data for your experiment is
        dirs.clusfolder = 'sorted\'; %subfolder that finished files will save into 
  end
end

end

