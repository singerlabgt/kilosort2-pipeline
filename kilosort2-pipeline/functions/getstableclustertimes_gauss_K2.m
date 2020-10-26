function [stabletimes, meanFR, peakFR] = getstableclustertimes_gauss_K2(recinfo, allfiles, unit, props, figdir, windowsize,...
    mintimestable, plotexamples)
%getstableclustertimes_gauss_K2
%Inputs:   index - matrix of indices per depth/day
%           clusterdatadir - directory of recording#.mat files
%           windowsize - size of FR hist windows in minutes
%           mintimestable - minimum time cell must be stable for inclusion
%                           (min)
%           plotexamples - 1 to plot stability, 0 not
%
%Output:
%           
%           stabletimes - matrix of start/end stability times in
%                                  s for each recording file
%Other: {fr structure}
%           fr.incltimes - times from fr histogram of thresholded (stable)
%                          fr [ms]
%           fr.totalspiketimes - spike times over entire recording depth/day [s]
%           fr.gaussfr - firing rate over the entire recording day
%               10ms bins, so 100 Hz sampling
%           meanFR - mean firing rate during stable times [Hz]
%           peakFR - peak firing rate during stable times [Hz]
%
%ALP 3/30/18
% Updated for Kilosort 2 pipeline ALP 8/6/19
% updating to run one unit at a time 12/17/19 ALP
% updating to add some comments and to output meanFR and peakFR for cell
% type classification 01/14/19

totaltime = 0;

%% get spikes and recording file durations
for i = 1:size(recinfo.files,2)
    if i == 1
        fr.totalspiketimes = [];
        fr.totalspiketimes = allfiles{i}.rawclusters(unit).spikeInds'./(props.sampRate/1000); %put into ms
    else
        fr.totalspiketimes = [fr.totalspiketimes (allfiles{i}.rawclusters(unit).spikeInds'./(props.sampRate/1000)+totaltime)]; %all spike times
    end
    
    totaltime = totaltime + props.recLength(i)/props.sampRate*1000; %Total time at this depth in ms
    
    if i == 1
        switchdur = [0 props.recLength(i)/props.sampRate*1000];
    else
        switchdur = [switchdur; (switchdur(end,2)+1) (switchdur(end,2)+1+props.recLength(i)/props.sampRate*1000)]; %switch location of recordings
    end
end

%% gauss FR
spiketrainedges = 0:10:totaltime; %10 ms bins
fr.spiketrain = histc(fr.totalspiketimes, spiketrainedges);
fr.gaussw = gausswin(windowsize*100*60)*100./(sum(gausswin(windowsize*100*60))); %area is 100 to get to Hz
fr.gaussfr = conv(fr.spiketrain, fr.gaussw, 'same');

groups = kmeans(fr.gaussfr', 2, 'MaxIter', 1000); %assume FR bimodal, get kmeans %changed MaxIter to 1000 from default ALP 11/28

[amean, id] = min([mean(fr.gaussfr(groups==1)), mean(fr.gaussfr(groups==2))]); %low mean
bmean = max([mean(fr.gaussfr(groups==1)), mean(fr.gaussfr(groups==2))]); %high mean
astd = std(fr.gaussfr(groups==id));

%% apply kmeans thresholding if the FR drops to 10% of high FR mean
if min(fr.gaussfr(100*60:end-100*60)) < 0.1*bmean %to try and help with edge effects
    findtimes = find(fr.gaussfr >= 2*astd+amean); %threshold is 2std above low mean
    if length(findtimes) > 1 && sum(diff(findtimes) == 1) > 0
        temptimes = contiguous(diff(findtimes),1);
        temptimes = temptimes{2};
        tempdiff = temptimes(:,2) - temptimes(:,1);
        binid = find(tempdiff == max(tempdiff)); %max duration above threshold
        
        %GaussFR
        fr.incltimes = [spiketrainedges(findtimes(temptimes(binid,1))) spiketrainedges(findtimes(temptimes(binid,2)+1))]; %in ms
        findfilesmat = [isExcluded(switchdur(:,1),fr.incltimes) isExcluded(switchdur(:,2),fr.incltimes)];
        
        if (fr.incltimes(2) - fr.incltimes(1))/(1000*60) >= mintimestable
            for file = 1:size(findfilesmat,1)
                if sum(findfilesmat(file,:)) > 0
                    fr.stabletimes(file,:) = [max(fr.incltimes(1), switchdur(file,1)) min(fr.incltimes(2), switchdur(file,2))];
                    fr.stabletimes(file,:) = fr.stabletimes(file,:) - switchdur(file,1)*ones(1,2);
                    %added ALP 4/10/18
                elseif sum(findfilesmat(:,1)) == 0 && sum(findfilesmat(:,2)) == 0
                    temponerec_1 = isExcluded(fr.incltimes(1), switchdur(file,:));
                    temponerec_2 = isExcluded(fr.incltimes(2), switchdur(file,:));
                    
                    %if the stable time only falls into one recording
                    %and if that recording is this file, then make
                    %stable times, otherwise set to 0 for this file
                    if isequal(temponerec_1, temponerec_2) && sum(temponerec_1+temponerec_2) > 0
                        fr.stabletimes(file,:) = [max(fr.incltimes(1), switchdur(file,1)) min(fr.incltimes(2), switchdur(file,2))];
                        fr.stabletimes(file,:) = fr.stabletimes(file,:) - switchdur(file,1)*ones(1,2);
                    else
                        fr.stabletimes(file,:) = [0 0];
                    end
                    %ALP 4/10 end
                else
                    fr.stabletimes(file,:) = [0 0];
                end
            end
        else
            fr.stabletimes = zeros(size(findfilesmat,1),2);
            fr.incltimes = [0 0];
        end
    else
        fr.stabletimes = zeros(size(findfilesmat,1),2);
        fr.incltimes = [0 0];
    end
    
    
    if plotexamples
        plottime = spiketrainedges./1000/60;
        %patch for plotting
        patchindsx = [fr.incltimes(1)./(1000*60) fr.incltimes(1)/(1000*60) fr.incltimes( 2)/(1000*60) fr.incltimes(2)/(1000*60)];
        patchindsy = [0 (max(fr.gaussfr)+0.1*max(fr.gaussfr)) (max(fr.gaussfr)+0.1*max(fr.gaussfr)) 0];
        
        figure
        patch(patchindsx, patchindsy, [0.6 0.8 1.0])
        hold on
        alpha(0.1)
        ylim([0 (max(fr.gaussfr)+0.1*max(fr.gaussfr))])
        plot(plottime, fr.gaussfr, 'k', 'LineWidth', 1.5)
        hold on
        plot(plottime, (amean+2*astd)*ones(1,length(fr.gaussfr)), 'r--', 'LineWidth', 1.5)
        plot(plottime, 0.1*bmean*ones(1,length(fr.gaussfr)), 'b--', 'LineWidth', 1.5)
        legend('Included', 'FR', '2std', '10% High')
        ylabel('Firing Rate (Hz)')
        xlabel('Time (min)')
        xlim([0 totaltime/(1000*60)])
    end
    
else %else whole time stable
    for file = 1:size(recinfo.files,2)
        fr.incltimes = [0 totaltime];
        fr.stabletimes(file,:) = [0 (switchdur(file,2)-switchdur(file,1))];
    end
    
    if plotexamples
        plottime = spiketrainedges./1000/60;
        
        figure
        hold on
        plot(plottime, fr.gaussfr, 'k')
        hold on
        plot(plottime, 0.1*bmean*ones(1,length(fr.gaussfr)), 'b--')
        legend('Firing Rate', '10% High FR')
        ylabel('FR (Hz)')
        xlabel('Time (min)')
        xlim([0 totaltime/(1000*60)])
    end
end

fr.stabletimes = fr.stabletimes./1000; %ms to s
stabletimes = fr.stabletimes;

%% get mean and peak FR
stableidx = fr.incltimes/10; %fr.incltimes in ms, fr.gausswin in ms/10 (10ms bins)

%round to integers to get indices
stableidx = round(stableidx);
if stableidx(1) == 0
    stableidx(1) = 1;
end

%calc mean/peak FR
if stableidx(2) ~= 0 %accounts for cluster with no stable times
    stableFR = fr.gaussfr(stableidx(1):stableidx(2));
    peakFR = max(stableFR);
    meanFR= mean(stableFR);
else
    peakFR = nan;
    meanFR = nan;
end

%% save figure
title(['Stable Times - ', recinfo.iden, num2str(recinfo.index(1)), ' ', num2str(recinfo.index(2)), ' - Cluster ', num2str(allfiles{1}.rawclusters(unit).ID)])

datadir = fullfile(figdir, 'stability\');
if ~exist(datadir, 'dir')
    mkdir(datadir);
end
figname = ['cluster', num2str(allfiles{1}.rawclusters(unit).ID), '_stabletimes_'];
filename = fullfile(datadir, [figname recinfo.iden num2str(recinfo.index(1)) '_' num2str(recinfo.index(2))]);
saveas(gcf,filename,'png');
clf

end

