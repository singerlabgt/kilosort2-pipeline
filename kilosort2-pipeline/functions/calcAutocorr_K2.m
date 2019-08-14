function fr = calcAutocorr_K2(clusterdir)
%this function calculates the autocorrelogram of clusters from a recording
%SP 4.16.18
%modified to use spike indicies to calculate the autocorrelograms and not
%spiketimes NJ 08.14.19

%INPUT
    %clusterdir: directory to rawclusters.mat files

%OUTPUT (for each cluster)
    %spiketrain
    %autocorrelogram
    %center of mass
    %cell ID 

%load sorting props 
load(fullfile(clusterdir, 'kilosort', 'sortingprops.mat'))

for f = 1:length(props.recLength)
    load(fullfile(clusterdir, ['rawclusters' num2str(f)]))
    for unit = 1:size(rawclusters,2)
        if f == 1
            fr.totalspikes{unit} = rawclusters(unit).spikeInds'; %change vertical to horizontal structure
        else
            fr.totalspikes{unit} = [fr.totalspikes{unit} rawclusters(unit).spikeInds'];
        end
    end
end

%total length of recording day, same for all units
totalsamples = sum(props.recLength);

for unit = 1:size(fr.totalspikes,2)
    %make the spike train - using indices instead of times
    stepsize = 5 * props.sampRate / 1000; %number of samples for 5ms binsize
    spiketrainedges = 0:stepsize:totalsamples; %5ms bins
    fr.spiketrain{unit} = histc(fr.totalspikes{unit}, spiketrainedges);
    
    %get the autocorr
    lag_num = 50 * props.sampRate / 1000; %number of samples for 50ms
    lag = lag_num/stepsize; %in bins
    fr.autocorr{unit} = xcorr(fr.spiketrain{unit},lag);
    fr.autocorr{unit}(lag+1) = 0;
    
    %eliminate ones with not enough spikes
    if max(fr.autocorr{unit}) < 10
        fr.autocorr{unit} = nan(1,length(fr.autocorr{unit}));
    end
end

%get the first moment of the autocorr
sampN = stepsize:stepsize:lag_num;
for unit = 1:length(fr.autocorr)
    fr.centerofmass{unit} = (sum(fr.autocorr{unit}(lag+2:end).*sampN)/sum(fr.autocorr{unit}(lag+2:end)))/stepsize;
end

%add raw cluster ID for autocorr info 
fr.clusterID = {rawclusters.ID}; 

%save structure
save([clusterdir, 'autocorr.mat'], 'fr')

