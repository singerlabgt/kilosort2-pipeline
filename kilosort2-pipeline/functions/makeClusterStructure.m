function makeClusterStructure(clusterdir, files, brainReg, clusfolder)
% makeClusterStructure Make post curation data structure for Kilosort2.
%   ALP 7/14/19

for br = 1:length(brainReg) %could move this loop outside of the function for consistency?
    ankilosortdir = fullfile(clusterdir, brainReg{br}, clusfolder, 'kilosort\');
    anclusterdir = fullfile(clusterdir, brainReg{br}, clusfolder);
    
    %read clustered information
    spikeInds = readNPY([ankilosortdir, 'spike_times.npy']); %in indices
    spikeID = readNPY([ankilosortdir, 'spike_clusters.npy']);
    
    if isfile(fullfile(ankilosortdir, 'cluster_groups.csv'))
        [clusterID, clusterGroup] = readClusterGroupsCSV([ankilosortdir, 'cluster_groups.csv']);
    elseif isfile(fullfile(ankilosortdir, 'cluster_group.tsv')) %dev files are saved in .tsv
        [clusterID, clusterGroup] = readClusterGroupsCSV([ankilosortdir, 'cluster_group.tsv']);
    end
    
    templates = readNPY([ankilosortdir, 'templates.npy']);
    spikeTemplates = readNPY([ankilosortdir, 'spike_templates.npy']);
    channelMap = readNPY([ankilosortdir, 'channel_map.npy']);
    params = loadParamsPy([ankilosortdir, 'params.py']);
    load([ankilosortdir, 'sortingprops.mat'], 'props')
    
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
    rawclusters = struct('ID', num2cell(goodUnits), ...
        'spikeInds', repmat({[]}, 1, length(goodUnits)),...
        'sampRate', num2cell(props.sampRate*ones(1, length(goodUnits))), ...
        'maxChan', num2cell(unitMaxChan'), 'info', repmat({'pre quality control metrics'}, 1, length(goodUnits)));
    
    %get all spike indices for entire recording
    for clu = 1:length(goodUnits)
        tempSpikeInds{clu} = spikeInds(spikeID == goodUnits(clu));
        tempSpikeInds{clu} = double(tempSpikeInds{clu});
    end
    
    %separate indicies into appropriate files
    %newSpikeInds: row is clusterIdx, column is file number
    elapsedLength = 0;
    for f = 1:length(files)
        for clu = 1:length(goodUnits)
            spikesI = tempSpikeInds{clu};
            newSpikeInds{clu,f} = spikesI(spikesI > elapsedLength & spikesI<props.recLength(f) + elapsedLength);
        end
        elapsedLength = elapsedLength + props.recLength(f);
    end
    
    %save cluster structure per file
    for f = 1:length(files)
        for clu = 1:length(goodUnits)
            rawclusters(clu).spikeInds = newSpikeInds{clu,f};
            rawclusters(clu).file = files(f);
            save([anclusterdir, 'rawclusters', num2str(files(f)), '.mat'], 'rawclusters')
        end
    end
end
