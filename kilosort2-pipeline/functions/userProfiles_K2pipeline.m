function [params, dirs] = userProfiles_K2pipeline(user, project)
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

%% Directories


%% User Profiles

%%%%%%%%%%%%%%%%% ----- Abby ----- %%%%%%%%%%%%%%
if strcmp(user, 'Abby')
    if strcmp(project, 'ChronicFlicker_CA1')
        params.probeChannels = {65:128}; %should be the 1 based indices of the channels in the data structure totalCh x samples
        params.brainReg = {'CA1'}; 
        params.animalID = 'A';
        params.numShanks = 2;
        
        dirs.rawdatadir = '\\neuro-cloud\labs\singer\RawData\Flicker_Chronic_VR\';
        %dirs.clusterdir = 'C:\Users\apaulson3\Desktop\TempKilosort\'; %this may be the same as processeddatadir
        dirs.clusterdir = '\\neuro-cloud\labs\singer\ProcessedData\Flicker_7Day_VR\'; %rerunning post proc bc bug in stable tiems      
        dirs.processeddatadir = '\\neuro-cloud\labs\singer\ProcessedData\Flicker_7Day_VR\'; %may be the same as above  
        dirs.clusfolder = 'sorted\'; %subfolder that finished files will save into
        dirs.spreadsheetdir = '\\neuro-cloud.ad.gatech.edu\labs\singer\Abby\experimentspreadsheets\chronicflicker_annulartrack_ephys.xls';

    end
    
    %%%%%%%%%%%%%%%%% ----- Abby ----- %%%%%%%%%%%%%%
if strcmp(user, 'Abby')
    if strcmp(project, 'ChronicFlicker_CA3')
        params.probeChannels = {1:64}; %should be the 1 based indices of the channels in the data structure totalCh x samples
        params.brainReg = {'CA3'};
        params.animalID = 'A';
        params.numShanks = 2;
        
        dirs.rawdatadir = '\\neuro-cloud\labs\singer\RawData\Flicker_Chronic_VR\';
        dirs.clusterdir = 'C:\Users\apaulson3\Desktop\TempKilosort_CA3\'; %this may be the same as processeddatadir
        %dirs.clusterdir = '\\neuro-cloud\labs\singer\Abby\kilosort\exampleData\kilosortFiles\'; 
        dirs.processeddatadir = '\\neuro-cloud\labs\singer\ProcessedData\Flicker_7Day_VR\'; %may be the same as above  
        dirs.clusfolder = 'sorted\'; %subfolder that finished files will save into
        dirs.spreadsheetdir = '\\neuro-cloud.ad.gatech.edu\labs\singer\Abby\experimentspreadsheets\chronicflicker_annulartrack_ephys.xls';
    end
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

