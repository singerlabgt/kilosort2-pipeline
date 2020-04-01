function applyQualityMetrics(anclusterdir, recinfo, rewrite, th)
%applyQualityMetrics Apply quality metrics to temp clusters structure from
%Phy
%   ALP 7/31/19

load([anclusterdir, '\kilosort\sortingprops.mat'], 'props')
load([anclusterdir, 'rawclustermetrics.mat'], 'rawclustermetrics')
load([anclusterdir, 'rawclusters_allrec.mat'], 'rawclusters_allrec')

%% get good cells
%SNR
good_snr = [rawclustermetrics.snr] >= th.SNR;
snrexcl = sum(double(good_snr) == 0);
disp([num2str(snrexcl), ' of ', num2str(length(rawclustermetrics)), ' excluded for SNR < ', num2str(th.SNR)])

%refractory period violations
isibins = rawclustermetrics(1).isi.edges_ms < th.refractoryPeriod*1000; %can use the first ind bc all edges the same
temp = reshape([rawclustermetrics.isi_h], [length(isibins), length(rawclustermetrics)])'; %get matrix of isi hist of all clusters
temp = sum(temp(:,isibins),2); %get the number of spikes in the refractory period for each cluster
temp = temp'./[rawclustermetrics.numspikes]; %normalize by total spike count for each cluster
good_isi = temp <= th.ISI;
isiexcl = sum(double(good_isi) == 0);
disp([num2str(isiexcl), ' of ', num2str(length(rawclustermetrics)), ' excluded for > ' num2str(th.ISI*100),'% refractory violations'])

%combine all metrics
temp = zeros(1, length(rawclustermetrics));
temp((good_snr & good_isi)) = 1; %fixed bug when two logical values are equally zero, it gets included as a good unit when it shouldn't: NJ 19.09.06
good_final = temp; %vector of 0 and 1s, 1x(#cells), 0 = excluded cell, 1 = included cell

%display information about how many cells survived the quality metrics into
%the command line
totalexcl = sum(double(good_final) == 0);
totalincl = sum(double(good_final) == 1);
disp([num2str(totalexcl), ' of ', num2str(length(rawclustermetrics)), ' clusters excluded.'])
disp([num2str(totalincl), ' clusters survived.'])

%% make good clusters structure
for f = 1:length(recinfo.files)
    if ~exist([anclusterdir, 'clusters', num2str(recinfo.files(f)), '.mat']) || rewrite
        
        %load rawclusters
        load([anclusterdir, 'rawclusters', num2str(recinfo.files(f)), '.mat'], 'rawclusters')
        
        %populate structure
        clusters = [];
        clusters{recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.samprate = props.sampRate;
        clusters{recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.th = th;
        clusters{recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.info = 'single units in .data struct. spikeInds is spike index with samprate denoted by field .samprate. maxChan is 0 based.';
        clusters{recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.index = [recinfo.index recinfo.files(f)];
        numgood = 1;
        
        for clu = 1:length(good_final)
            if good_final(clu)
                clusters{recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.data(numgood).ID = rawclusters(clu).ID;
                clusters{recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.data(numgood).maxChan = rawclusters(clu).maxChan;
                clusters{recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.data(numgood).spikeInds = rawclusters(clu).spikeInds;
                numgood = numgood+1; 
            end
        end
        
        %save
        save([anclusterdir, 'clusters', num2str(recinfo.files(f)), '.mat'], 'clusters')
    end
end

%% make good cluster metrics structure
clustermetrics = rawclustermetrics(logical(good_final)); 
save([anclusterdir, 'clustermetrics.mat'], 'clustermetrics')

%% make good clusters structure for all recordings 
clusters_allrec = rawclusters_allrec(logical(good_final)); 
[clusters_allrec.info] = deal({'all files. post quality control metrics'});
[clusters_allrec(1:sum(good_final)).index] = deal(recinfo.index); 
[clusters_allrec(1:sum(good_final)).files] = deal(recinfo.files); 
save([anclusterdir, 'clusters_allrec.mat'], 'clusters_allrec')

end

