function applyQualityMetrics(anclusterdir, recinfo, rewrite, th)
%applyQualityMetrics Apply quality metrics to temp clusters structure from
%Phy
%   ALP 7/31/19

load([anclusterdir, '\kilosort\sortingprops.mat'], 'props')
load([anclusterdir, 'clustermetrics.mat'], 'clustermetrics')

%% get good cells
good_snr = [clustermetrics.snr] >= th.SNR;
snrexcl = sum(double(good_snr) == 0);
disp([num2str(snrexcl), ' of ', num2str(length(clustermetrics)), ' excluded for SNR < ', num2str(th.SNR)])

isibins = clustermetrics(1).isi.edges_ms < th.refractoryPeriod*1000;
temp = reshape([clustermetrics.isi_h], [length(isibins), length(clustermetrics)])';
temp = sum(temp(:,isibins),2);
temp = temp'./[clustermetrics.numspikes];
good_isi = temp <= th.ISI;
isiexcl = sum(double(good_isi) == 0);
disp([num2str(isiexcl), ' of ', num2str(length(clustermetrics)), ' excluded for > ' num2str(th.ISI*100),'% refractory violations'])
temp = zeros(1, length(clustermetrics));
temp((good_snr & good_isi)) = 1; %fixed bug when two logical values are equally zero, it gets included as a good unit when it shouldn't: NJ 19.09.06
good_final = temp;
totalexcl = sum(double(good_final) == 0);
totalincl = sum(double(good_final) == 1);
disp([num2str(totalexcl), ' of ', num2str(length(clustermetrics)), ' clusters excluded.'])
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
                %clusters{recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.data(clu).stableTimes = clustermetrics(clu).stabletimes(f,:);
                numgood = numgood+1; 
            end
        end
        
        %save
        save([anclusterdir, 'clusters', num2str(recinfo.files(f)), '.mat'], 'clusters')
    end
end
end

