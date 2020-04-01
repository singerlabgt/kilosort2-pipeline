function [params, dirs] = userProfiles_K2pipeline(user, project)
%userProfiles_K2pipeline
%
%ALP 2/19/20

%% Defaults
% animal and day: 1xN vect of same length 
% files: cell array with each element containing 1xN vect of desired files
% probeChannels: cell array with each element containing 1xN vect of 
%   channels of desired region. channels should be 1 based. 
% brainReg: cell array of brain regions with same length as probeChannels. 
%    can be {''} if desired
% animalID: cell array of ID letters with same length as brainReg

%% User Profiles

%%%%%%%%%%%%%%%%% ----- Abby ----- %%%%%%%%%%%%%%
if strcmp(user, 'Abby')
    if strcmp(project, 'ChronicFlicker')
        params.probeChannels = {1:64, 65:128}; %should be the indices of the channels in the data structure totalCh x samples
        params.portLetter = {'A', 'B', 'C', 'D'};
        params.brainReg = {'CA3', 'CA1'};
        params.animalID = {'A'};
        params.numShanks = 2;
        
        dirs.rawdatadir = '\\neuro-cloud\labs\singer\RawData\Flicker_Chronic_VR\';
        dirs.clusterdir = 'C:\Users\apaulson3\Desktop\TempKilosort\'; %this may be the same as processeddatadir
        dirs.processeddatadir = 'Y:\singer\ProcessedData\Flicker_7Day_VR\'; %may be the same as above  
        dirs.clusfolder = 'sorted\'; %subfolder that finished files will save into
    end
end

%%%%%%%%%%%%%%%%% ----- Nuri ----- %%%%%%%%%%%%%%%

end

