function makeClusterStructure(clusterdir, files, brainReg, clusfolder)
% makeClusterStructure Make post curation data structure for Kilosort2.
%   ALP 7/14/19

for br = 1:length(brainReg) %could move this loop outside of the function for consistency?
    anclusterdir = fullfile(clusterdir, brainReg{br}, clusfolder);

    %read clustered information
    spikeInds = readNPY([anclusterdir, 'spike_times.npy']); %in indices
    spikeID = readNPY([anclusterdir, 'spike_clusters.npy']);
    
    if isfile(fullfile(anclusterdir, 'cluster_groups.csv'))
        [clusterID, clusterGroup] = readClusterGroupsCSV([anclusterdir, 'cluster_groups.csv']);
    elseif isfile(fullfile(anclusterdir, 'cluster_group.tsv')) %dev files are saved in .tsv
        [clusterID, clusterGroup] = readClusterGroupsCSV([anclusterdir, 'cluster_group.tsv']); 
    end

    templates = readNPY([anclusterdir, 'templates.npy']);
    spikeTemplates = readNPY([anclusterdir, 'spike_templates.npy']);
    channelMap = readNPY([anclusterdir, 'channel_map.npy']);
    params = loadParamsPy([anclusterdir, 'params.py']);
    load([anclusterdir, 'sortingprops.mat'], 'props')

    %only units classified as "good"
    goodUnits = clusterID(clusterGroup == 2);
    
    %get templates for each cluster
    tempPerUnit = findTempForEachClu(spikeID, spikeTemplates);
    
    %get max channel per cluster based on max template amplitude
    [~,max_site] = max(max(abs(templates),[],2),[],3);
    templateMaxChan = channelMap(max_site); %0 based, template 0 is at ind 1
    unitMaxChan = templateMaxChan(tempPerUnit(~isnan(tempPerUnit))+1);
    unitMaxChan = double(unitMaxChan(clusterGroup == 2)); %only good units
    
    %create structure
    clusters = struct('ID', num2cell(goodUnits), ...
        'spikeInds', repmat({[]}, 1, length(goodUnits)),...
        'sampRate', num2cell(props.sampRate*ones(1, length(goodUnits))), ...
        'maxChan', num2cell(unitMaxChan'), 'info', repmat({'pre quality control metrics'}, 1, length(goodUnits)));
    
    %loop over recordings - this could be improved - how does Lu do it?
    elapsedLength = 0;
    for f = 1:length(files)
        for clu = 1:length(goodUnits)
            if f == 1
                tempSpikeInds{clu} = spikeInds(spikeID == goodUnits(clu));
                tempSpikeInds{clu} = double(tempSpikeInds{clu});
            else
                tempSpikeInds{clu} = tempSpikeInds{clu} - elapsedLength; 
                clusters(clu).spikeInds = [];
            end
            
            clusters(clu).spikeInds = tempSpikeInds{clu}(tempSpikeInds{clu} <= props.recLength(f));
            
            if f < length(files)
                tempSpikeInds{clu} = tempSpikeInds{clu}(tempSpikeInds{clu} > props.recLength(f));
            end
            clusters(clu).file = files(f);
        end
        elapsedLength = elapsedLength+props.recLength(f);
        
        save([anclusterdir, 'tempclusters', num2str(files(f)), '.mat'], 'clusters')
    end
end
end

