function makeClusterStructure(clusterdir, recinfo, brainReg, clusfolder, numShanks)
% makeClusterStructure Make post curation data structure for Kilosort2.
%   ALP 7/14/19


files = recinfo.files; 


ankilosortdir = fullfile(clusterdir, 'kilosort\');
anclusterdir = fullfile(clusterdir, '\');

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
channelMap = readNPY([ankilosortdir, 'channel_map.npy']); %0-based
params = loadParamsPy([ankilosortdir, 'params.py']);
load([ankilosortdir, 'sortingprops.mat'], 'props')

%only units classified as "good"
goodUnits = clusterID(clusterGroup == 2);

%get templates for each cluster - noise, mua, and good
tempPerUnit = findTempForEachClu(spikeID, spikeTemplates);

%check length of tempPerUnit and spikeID are equal
if ~isequal(length(tempPerUnit)-1, clusterID(end))
    error('Length of templates and identified clusters do not match')
end

%get max channel per cluster based on max template amplitude
[~,max_site] = max(max(abs(templates),[],2),[],3);
templateMaxChan = channelMap(max_site); %0 based, template 0 is at ind 1 - max channel of each template
unitMaxChan = templateMaxChan(tempPerUnit(~isnan(tempPerUnit))+1); %only valid templates, +1 because template is 0 based 
%unitMaxChan = templateMaxChan(tempPerUnit+1); % +1 because template is 0 based 
unitMaxChan = double(unitMaxChan(clusterGroup == 2)); %only good units

%for SpikeGadgets, use hardware channel numbers for maxChan - NJ 03.10.2020
if isfield(props, 'hw_chan')
    channelMap = props.hw_chan; %0-based hwChan numbers (folder names)
    unitMaxChan = channelMap(unitMaxChan + 1); %have to add 1 to unitMaxChan to use as indices
end

%loop over recordings - this could be improved - how does Lu do it?
for f = 1:length(files)
    %create structure
    rawclusters = struct('ID', num2cell(goodUnits), ...
        'spikeInds', repmat({[]}, 1, length(goodUnits)),...
        'sampRate', num2cell(props.sampRate*ones(1, length(goodUnits))), ...
        'maxChan', num2cell(unitMaxChan'), 'info', repmat({'pre quality control metrics'}, 1, length(goodUnits)),...
        'numShanks',num2cell(numShanks*ones(1, length(goodUnits))), 'brainReg', repmat({brainReg}, 1, length(goodUnits)), ...
        'numChan', num2cell(props.numChan*ones(1,length(goodUnits))));
    
    [rawclusters(1:length(goodUnits)).index] = deal(recinfo.index); 
    [rawclusters(1:length(goodUnits)).files] = deal(recinfo.files); 
    
    for clu = 1:length(goodUnits)
        if f == 1
            tempSpikeInds{clu} = spikeInds(spikeID == goodUnits(clu));
            tempSpikeInds{clu} = double(tempSpikeInds{clu});
        else
            tempSpikeInds{clu} = tempSpikeInds{clu} - props.recLength(f-1); %align to start time of this recording
            rawclusters(clu).spikeInds = [];
        end
        
        rawclusters(clu).spikeInds = tempSpikeInds{clu}(tempSpikeInds{clu} <= props.recLength(f));
        
        if f < length(files)
            tempSpikeInds{clu} = tempSpikeInds{clu}(tempSpikeInds{clu} > props.recLength(f));
        end
        rawclusters(clu).file = files(f);
    end
    save([anclusterdir, 'rawclusters', num2str(files(f)), '.mat'], 'rawclusters')
end

%make structure will all spike times from all recordings
rawclusters_allrec = struct('ID', num2cell(goodUnits), ...
    'spikeInds', repmat({[]}, 1, length(goodUnits)),...
    'sampRate', num2cell(props.sampRate*ones(1, length(goodUnits))), ...
    'maxChan', num2cell(unitMaxChan'), 'info', repmat({'all files. pre quality control metrics'}, 1, length(goodUnits)), ...
    'numShanks',num2cell(numShanks*ones(1, length(goodUnits))), 'brainReg', repmat({brainReg}, 1, length(goodUnits)), ...
    'numChan', num2cell(props.numChan*ones(1,length(goodUnits))));
[rawclusters_allrec(1:length(goodUnits)).index] = deal(recinfo.index); 
[rawclusters_allrec(1:length(goodUnits)).files] = deal(recinfo.files); 

for clu = 1:length(goodUnits)
    tempSpikeInds{clu} = spikeInds(spikeID == goodUnits(clu));
    tempSpikeInds{clu} = double(tempSpikeInds{clu});
    
    rawclusters_allrec(clu).spikeInds = tempSpikeInds{clu};
    rawclusters(clu).file = files;
end

save([anclusterdir, 'rawclusters_allrec.mat'], 'rawclusters_allrec')
end

