function fr = calcAutocorr_K2(clusterdir, recinfo, unitIDs)
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

%NJ updated 03.12.20 to get good units by default, if not all pre-quality
%units

%load sorting props
load(fullfile(clusterdir, 'kilosort', 'sortingprops.mat'))

%use only post-quality check units if exists, and rawclusters if not
if isfile(fullfile(clusterdir, 'goodclusters_allrec.mat'))
    load(fullfile(clusterdir, 'goodclusters_allrec.mat'))
    clusters = goodclusters_allrec;
else
    load(fullfile(clusterdir, 'rawclusters_allrec.mat')) %edit from rawclusters(recNum) bc indices all restart from 1: NJ 09.06.19
    clusters = rawclusters_allrec;
end
    
%total length of recording day, same for all units
totalsamples = sum(props.recLength);


fr = struct('ID', repmat({[]}, 1, length(unitIDs)), ...
    'autocorr', repmat({[]}, 1, length(unitIDs)),...
    'centerofmass', repmat({[]}, 1, length(unitIDs))); 

for unit = 1:length(unitIDs)
    
    fr(unit).ID = unitIDs(unit);
    
    totalspikes = clusters(unit).spikeInds; %change vertical to horizontal structure
    %make the spike train - using indices instead of times
    stepsize = 5 * props.sampRate / 1000; %number of samples for 5ms binsize
    spiketrainedges = 0:stepsize:totalsamples; %5ms bins
    spiketrain = histcounts(totalspikes, spiketrainedges);
    
    %get the autocorr
    lag_num = 50 * props.sampRate / 1000; %number of samples for 50ms
    lag = lag_num/stepsize; %in bins
    autocorr{unit} = xcorr(spiketrain,lag);
    autocorr{unit}(lag+1) = 0;
    
    %eliminate ones with not enough spikes
    if max(autocorr{unit}) < 10
        autocorr{unit} = nan(1,length(autocorr{unit}));
    end
    
    fr(unit).autocorr = autocorr{unit};
    
    %get the first moment of the autocorr
    sampN = stepsize:stepsize:lag_num;
    
    centerofmass{unit} = (sum(autocorr{unit}(lag+2:end).*sampN)/sum(autocorr{unit}(lag+2:end)))/stepsize;
    fr(unit).centerofmass = centerofmass{unit};
end

%save structure
save(fullfile(clusterdir, 'autocorr.mat'), 'fr')

