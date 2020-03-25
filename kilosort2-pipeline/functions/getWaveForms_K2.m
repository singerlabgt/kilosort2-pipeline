function getWaveForms_K2(anprocesseddatadir, anclusterdir, recinfo, figdir, rewrite)
%getWaveForms_K2 get waveforms of Kilosort2 and phy output.
%   Based on loadwaveforms.m from Steph Prince, SNR from Clarissa Whitmire,
%   stableclustertimes ALP
%ALP 7/15/19

load([anclusterdir, 'kilosort\sortingprops.mat'], 'props')
props = props; 
samprate = props.sampRate;
tAroundSpike = [0.001*samprate .002*samprate]; %1ms before and 2ms after

hpFilt = designfilt('highpassiir', 'StopbandFrequency', 100, ...
    'PassbandFrequency', 500, 'StopbandAttenuation', 60, ...
    'PassbandRipple', 1, 'SampleRate', samprate, 'DesignMethod', 'butter');

for f = 1:length(recinfo.files)
    disp(['Filtering raweeg for file ', num2str(f), ' of ', num2str(length(recinfo.files))])
    
    % load cluster structure
    allfiles{f} = load([anclusterdir, 'rawclusters', num2str(recinfo.files(f)), '.mat'], 'rawclusters');
    WFchannels = [allfiles{f}.rawclusters.maxChan];
    WFchannels = unique(WFchannels);
    
    %filter rawdata
    parfor ch = 1:length(WFchannels)
        getFiltEEGWFs(recinfo, f, hpFilt, ...
            anprocesseddatadir, WFchannels(ch), samprate, rewrite.eeg)
    end
end

% get waveforms from filtered eeg
if ~isfile([anclusterdir, 'clustermetrics.mat']) || rewrite.wf
    disp('Getting cluster metrics')
    parfor clu = 1:length(allfiles{1}.rawclusters) %should be same length all files
        clustermetrics(clu) = makeWFstructure(anprocesseddatadir, allfiles, clu, recinfo,...
            tAroundSpike, props, figdir);
    end
end
save([anclusterdir, 'clustermetrics.mat'], 'clustermetrics')
end

