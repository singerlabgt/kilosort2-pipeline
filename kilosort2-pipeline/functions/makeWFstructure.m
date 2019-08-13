function metrics = makeWFstructure(anprocesseddatadir, allfiles, clu, recinfo,...
    tAroundSpike, samprate, figdir)
%makeWFstructure Get mean waveform and some properties about it for
%curation and cell type classification.
%   ALP 7/25/19

spikeCount = 1;
recLength = 0;
isi = [];
for f = 1:length(recinfo.files)
    %load WF filtered EEG
    load([anprocesseddatadir, num2str(allfiles{f}.rawclusters(clu).maxChan),...
        '\eegWFs', num2str(recinfo.files(f)), '.mat'], 'eegWFs')
    filtdat = eegWFs{recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.data;
    
    for spikeIdx = 1:length(allfiles{f}.rawclusters(clu).spikeInds)
        if allfiles{f}.rawclusters(clu).spikeInds(spikeIdx)/samprate < 1.0 %eliminate spikes less than 1s in to rec file
            tempWFs(spikeCount, :) = NaN(1, sum(tAroundSpike)+1);
        elseif (allfiles{f}.rawclusters(clu).spikeInds(spikeIdx) + tAroundSpike(2)) > length(filtdat)
            tempWFs(spikeCount, :) = NaN(1, sum(tAroundSpike)+1);
        else
            waveforminds = round(allfiles{f}.rawclusters(clu).spikeInds(spikeIdx)-tAroundSpike(1)):round(allfiles{f}.rawclusters(clu).spikeInds(spikeIdx)+tAroundSpike(2));
            tempWFs(spikeCount, :) = filtdat(waveforminds);
        end
        spikeCount = spikeCount+1;
        if spikeIdx > 1
            diffinds = allfiles{f}.rawclusters(clu).spikeInds(spikeIdx) - allfiles{f}.rawclusters(clu).spikeInds(spikeIdx-1);
            isi = [isi diffinds];
        end
    end
    recLength = recLength+length(filtdat);
    clear filtdat
end

recLength = recLength./samprate; %in s
metrics.ID = allfiles{1}.rawclusters(clu).ID;
metrics.WF.mn = mean(tempWFs, 1, 'omitnan');
metrics.WF.std = std(tempWFs, 0, 1, 'omitnan');
metrics.snr = (max(metrics.WF.mn) - min(metrics.WF.mn))/mean(metrics.WF.std);
metrics.WF.info = '1ms before and 2ms after';
% metrics.peak2trough_ms = calcSpikewidth_K2(metrics.WF.mn, recinfo, allfiles{f}.rawclusters(clu).ID, samprate, figdir);
metrics.firingrate = spikeCount/recLength; %in Hz
metrics.isi.all_ms = isi./(samprate/1000); %in ms
metrics.isi_h = histc(metrics.isi.all_ms, 0:0.1:10);
metrics.isi.edges_ms = 0:0.1:10; 
metrics.numspikes = spikeIdx; 
metrics.files = recinfo.files; 
metrics.samprate = samprate; 
%incorporate get stabletimes here
%metrics.stabletimes = 
end

