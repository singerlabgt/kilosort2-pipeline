function metrics = makeWFstructure(anprocesseddatadir, allfiles, clu, recinfo,...
    tAroundSpike, props, figdir)
%makeWFstructure Get mean waveform and some properties about it for
%curation and cell type classification.
%   Based on loadwaveforms.m SMP
%   ALP 7/25/19

spikeCount = 1;
recLength = [];
isi = [];
tempWFs = [];
samprate = props.sampRate;

for f = 1:length(recinfo.files)
    %load WF filtered EEG
    load([anprocesseddatadir, num2str(allfiles{f}.rawclusters(clu).maxChan),...
        '\eegWFs', num2str(recinfo.files(f)), '.mat'], 'eegWFs')
    filtdat = eegWFs{recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.data;
    
    %pre-allocation for speed
    tempWFs = [tempWFs; NaN(length(allfiles{f}.rawclusters(clu).spikeInds), sum(tAroundSpike)+1)];
    
    for spikeIdx = 1:length(allfiles{f}.rawclusters(clu).spikeInds)
        currentIdx = allfiles{f}.rawclusters(clu).spikeInds(spikeIdx);
        
        %eliminate spikes less than 1s into rec file && index  + 2ms after
        %spike does not go over the filtdat boundary
        if (currentIdx/samprate > 1.0) && ((currentIdx + tAroundSpike(2)) < length(filtdat))
            %look for minimum amplitude +/- 0.2ms around the K2 spikeIdx
            nSamps = round(0.2 / (1/samprate *1000));
            a = currentIdx - nSamps : currentIdx + nSamps; 
            b = filtdat(a) == min(filtdat(a));
            minIdx = a(b); %index of minimum waveform amplitude
            waveforminds = round(minIdx-tAroundSpike(1)):round(minIdx+tAroundSpike(2));
            if max(waveforminds) < length(filtdat) %added ALP 8/4/21 bc sometimes stuff was making it through the if statement above
                tempWFs(spikeCount, :) = filtdat(waveforminds);
            end
        end
        spikeCount = spikeCount+1;       
    end
    isi = [isi diff(allfiles{f}.rawclusters(clu).spikeInds)']; %faster
    recLength(f) = length(filtdat);
    clear filtdat
end

recLengthAll = sum(recLength)./samprate; %in s
metrics.ID = allfiles{1}.rawclusters(clu).ID;
metrics.WF.mn = mean(tempWFs, 1, 'omitnan');
metrics.WF.std = std(tempWFs, 0, 1, 'omitnan');
metrics.snr = (max(metrics.WF.mn) - min(metrics.WF.mn))/mean(metrics.WF.std);
metrics.WF.info = '1ms before and 2ms after minimum amplitude';
metrics.firingrate = spikeCount/recLengthAll; %in Hz
metrics.isi.all_ms = isi./(samprate/1000); %in ms
metrics.isi_h = histc(metrics.isi.all_ms, 0:0.1:10);
metrics.isi.edges_ms = 0:0.1:10; 
metrics.numspikes = spikeCount-1; %minus 1 bc last index added one automatically
metrics.files = recinfo.files; 
metrics.index = recinfo.index;
metrics.maxChan = allfiles{1}.rawclusters(clu).maxChan; 
metrics.samprate = samprate; 
[metrics.stable.times, metrics.stable.meanFR, metrics.stable.peakFR] = getstableclustertimes_gauss_K2(recinfo,...
    allfiles, clu, props, figdir, 10, 5, 1);
metrics.stable.info = 'times in [s], meanFR and peakFR from stable period over all recordings, in [Hz], idx in samprate';
end

