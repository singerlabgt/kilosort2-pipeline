function getWaveForms_K2(anprocesseddatadir, anclusterdir, recinfo, figdir, rewrite)
%getWaveForms_K2 get waveforms of Kilosort2 and phy output.
%   Based on loadwaveforms.m from Steph Prince, SNR from Clarissa Whitmire,
%   stableclustertimes from Abigail Paulson
%ALP 7/15/19

load([anclusterdir, 'sortingprops.mat'], 'props')
samprate = props.sampRate;
tAroundSpike = [0.001*samprate .002*samprate]; %1ms before and 2ms after

hpFilt = designfilt('highpassiir', 'StopbandFrequency', 100, ...
    'PassbandFrequency', 500, 'StopbandAttenuation', 60, ...
    'PassbandRipple', 1, 'SampleRate', samprate, 'DesignMethod', 'butter');

for f = 1:length(recinfo.files)
    disp(['Filtering raweeg for file ', num2str(f), ' of ', num2str(length(recinfo.files))])
    
    % load cluster structure
    allfiles{f} = load([anclusterdir, 'clusters', num2str(recinfo.files(f)), '.mat'], 'clusters');
    WFchannels = [allfiles{f}.clusters.maxChan];
    WFchannels = unique(WFchannels);
    
    %filter rawdata
    parfor ch = 1:length(WFchannels)
        getFiltEEGWFs(recinfo.index, recinfo.files(f), hpFilt, ...
            anprocesseddatadir, WFchannels(ch), samprate, rewrite.eeg)
    end
    
end

% get eeg waveforms
if ~isfile([anclusterdir, 'waveformstats.mat']) || rewrite.WF
    for clu = 1:length(allfiles{1}.clusters)
        WF(clu) = makeWFstructure(anprocesseddatadir, allfiles, clu, recinfo,...
            tAroundSpike, samprate, figdir);
    end
end
save([anclusterdir, 'waveforms.mat'], 'WF')


% get stable times



end

