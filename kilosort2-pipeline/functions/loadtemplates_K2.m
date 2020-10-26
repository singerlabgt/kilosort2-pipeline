function templates = loadtemplates_K2(kilosortdir, clusterIDs)
%loadtemplates_K2
% loads templates for a desired set of clusters and outputs them with 
% channel order 0:nChannels
% template of clusterID(1) on channel0 = templates(1,:,1)
%
% inputs: 
%       clusterIDs - [nClusters, 1], vector of clusterIDs as defined by
%           Kilosort output. 0 based (as it came from Kilosort and is
%           defined in clusters struct)
% outputs: 
%       templates - [nClusters, nTimepoints, nChannels], where nClusters is 
%           in order of clusterIDs, and nChannels is in order 0:nChannels as 
%           defined by the user's channel map. 
%
% example call: 
%       wfsToPlot = loadtemplates_K2(ankilosortdir, [clusters.ID]); 
%
% ALP 4/14/2020

%load up stuff we need from the kilosort output directory 
temp = readNPY([kilosortdir, 'templates.npy']); %[nTemplates, nTimepoints, nChannels] where nChannels is defined by the kilosort channel map
load([kilosortdir, 'sortingprops.mat'], 'props') %load sorting props
spikeTemplates = readNPY([kilosortdir, 'spike_templates.npy']);
channelMap = readNPY([kilosortdir, 'channel_map.npy']); %0-based
spikeID = readNPY([kilosortdir, 'spike_clusters.npy']);

%get templates for each cluster - noise, mua, and good
%tempAllUnits is 1:max(spikeID) where tempAllUnit(clusterID) = templateID 
%of clusterID. NaNs are clusters that don't exist. 
tempAllUnits = findTempForEachClu(spikeID, spikeTemplates); %0 based, templateID starts at 0

%get template IDs of the clusters indicated in clusterIDs
tempGoodUnits = tempAllUnits(clusterIDs+1); %0 based templateID, 0 based clusterID
tempGoodUnits1base = tempGoodUnits + 1; %1 based for indexing 

%get templates of clusters indicated in clusterIDs
templates = temp(tempGoodUnits1base,:,:); 

%rearrange templates by channel map
[~, channelMapSortI] = sort(channelMap); %get the indices to sort by 0:nChannels
templates = templates(:,:,channelMapSortI); 

%plot to check 

end

