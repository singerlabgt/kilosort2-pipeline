function fr = calcAutocorr_K2 
%this function calculates the autocorrelogram of clusters from a recording
%SP 4.16.18
%modified for Kilosort2 NJ 08/13/19

%input: clusterdir
%output: spiketrain, autocorrelogram, center of mass for each unit


%load sample props as an example
load('Y:\singer\Nuri\Clustering\N8_190716\CA3\sorted\kilosort\sortingprops.mat');

for f = 1:length(props.recLength)
    load(['Y:\singer\Nuri\Clustering\N8_190716\CA3\sorted\rawclusters' num2str(f)]);
    for unit = 1:size(rawclusters,2)
        if f == 1
            fr.totalspikes{unit,1} = rawclusters(unit).spikeInds;
        else
            fr.totalspikes{unit,1} = [fr.totalspikes{unit,1}; rawclusters(unit).spikeInds];
        end
    end
end

%total length of recording day, same for all units
totalsamples = sum(props.recLength);

for unit = 1:size(fr.totalspikes,1)
    %make the spike train - using indices instead of times
    stepsize = 5 * props.sampRate / 1000; %number of samples for 5ms binsize
    spiketrainedges = 0:stepsize:totalsamples; %5ms bins
    fr.spiketrain{unit,1} = histc(fr.totalspikes{unit,1}, spiketrainedges);
    
    %get the autocorr
    lag_num = 50 * props.sampRate / 1000; %number of samples for 50ms
    lag = lag_num/stepsize; %in bins
    fr.autocorr{unit,1} = xcorr(fr.spiketrain{unit,1},lag);
    fr.autocorr{unit,1}(lag+1) = 0;
    
    %eliminate ones with not enough spikes
    if max(fr.autocorr{unit,1}) < 10
        fr.autocorr{unit,1} = nan(1,length(fr.autocorr{unit,1}));
    end
end

%% get the first moment of the autocorr
sampN = stepsize:stepsize:lag_num;
for unit = 1:length(fr.autocorr)
    fr.centerofmass{unit,1} = (sum(fr.autocorr{unit,1}(lag+2:end).*sampN)/sum(fr.autocorr{unit,1}(lag+2:end)))/stepsize;
end