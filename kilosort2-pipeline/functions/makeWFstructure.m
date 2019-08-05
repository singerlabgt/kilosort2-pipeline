function WF = makeWFstructure(anprocesseddatadir, allfiles, clu, recinfo,...
    tAroundSpike, samprate, figdir)
%makeWFstructure Get mean waveform and some properties about it for
%curation and cell type classification.
%   ALP 7/25/19

spikeCount = 1;
recLength = 0;
for f = 1:length(recinfo.files)
    %load WF filtered EEG
    load([anprocesseddatadir, num2str(allfiles{f}.clusters(clu).maxChan),...
        '\eegWFs', num2str(recinfo.files(f)), '.mat'], 'eegWFs')
    filtdat = eegWFs{recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.data;
    
    for spikeIdx = 1:length(allfiles{f}.clusters(clu).spikeInds)
        if allfiles{f}.clusters(clu).spikeInds(spikeIdx)/samprate < 1.0 %eliminate spikes less than 1s in to rec file
            tempWFs(spikeCount, :) = NaN(1, sum(tAroundSpike)+1);
        elseif (allfiles{f}.clusters(clu).spikeInds(spikeIdx) + tAroundSpike(2)) > length(filtdat)
            tempWFs(spikeCount, :) = NaN(1, sum(tAroundSpike)+1);
        else
            waveforminds = round(allfiles{f}.clusters(clu).spikeInds(spikeIdx)-tAroundSpike(1)):round(allfiles{f}.clusters(clu).spikeInds(spikeIdx)+tAroundSpike(2));
            tempWFs(spikeCount, :) = filtdat(waveforminds);
        end
        spikeCount = spikeCount+1;
    end
    recLength = recLength+length(filtdat);
    clear filtdat
end

recLength = recLength./samprate; %in s

WF.mn = mean(tempWFs, 1, 'omitnan');
WF.std = std(tempWFs, 0, 1, 'omitnan');
WF.snr = (max(WF.mn) - min(WF.mn))/mean(WF.std);
WF.peak2trough = calcSpikewidth_K2(WF.mn, recinfo, allfiles{f}.clusters(clu).ID, samprate, figdir);
WF.firingrate = spikeCount/recLength; %in Hz
end

