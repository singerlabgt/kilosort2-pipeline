function spikewidth = calcSpikewidth_K2(WF, recinfo, clusID, samprate, figdir)
%this function calculates spikewidth via peak2trough where the trough is
%the first time the differential is 0 or is closest to 0
%SP 4.27.18
% modified for Kilosort2 ALP 7/25/19

%input: waveform, raw eeg sampling (20kHz)
%output: spikewidth, peakIdx, troughIdx, resampledWF

%% calculate peak to trough
resamplefactor = round(16/(samprate/10000)); %8 for 20kHz, 5 for 30kHz (rounding 5.333), should optimize ALP 7/25
waveformresampled = resample(WF,resamplefactor,1);
% waveformresampled = waveformresampled((resamplefactor*15):(60*resamplefactor)); %what do these numbers mean?? 
waveformresampled = waveformresampled(round((0.75/1000)*resamplefactor*samprate):round(((3/1000)*resamplefactor*samprate))); %for variable samprate
temp = (waveformresampled - mean(waveformresampled));
waveformresampled = temp/abs(min(temp));

%find peak2trough
peakIdx = find(waveformresampled == min(waveformresampled));
offsetIdx = peakIdx + 2; %don't start looking until 3 samples away from peak 
negslope = find(diff(waveformresampled(offsetIdx:end))<0);
diffWF = diff(waveformresampled(offsetIdx:end));
if isempty(negslope)
    negslope = find(diffWF == min(diffWF));
end
troughIdx = negslope(1)+offsetIdx;
sw = 1000*((abs(troughIdx-peakIdx)/(resamplefactor*samprate))); %1000 to convert to msec, resamp*samprate to correct for sampling
waveform = waveformresampled;

%store the info
spikewidth.ID =clusID;
spikewidth.peak2troughDiff = sw;
spikewidth.peakIdxDiff = peakIdx;
spikewidth.troughIdxDiff = troughIdx;
spikewidth.fullWFDiff = waveform;

%% make sure peak2trough values are correct
hold on; 
plot(waveform);
plot(peakIdx, waveform(peakIdx),'rs');
plot(troughIdx, waveform(troughIdx),'ks');
title(['Waveform ', recinfo.iden, ' ', num2str(recinfo.index(1)), ' ', num2str(recinfo.index(2)),...
    ' Cluster - ', num2str(clusID)]);

%% save figures 
datadir = fullfile(figdir, 'figsWaveforms\');
figname = ['Cluster' num2str(clusID) '_peak2troughDiff'];
% if ~exist([datadir filename iden num2str(dayindex(1)) '_' num2str(dayindex(2)) '.fig'])
%     pause
% end
savefigSP(recinfo.index, datadir, figname, recinfo.iden);
clf
end
