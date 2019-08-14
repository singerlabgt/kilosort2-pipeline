function fr = getstableclustertimes_gauss_K2(recinfo, samprate, windowsize,...
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
%           {fr structure}
%           fr.stabletimes{unit} - matrix of start/end stability times in
%                                  s for each recording file
%           fr.bigedges - histogram edges for firing rate
%           fr.incltimes - times from fr histogram of thresholded (stable)
%                          fr
%           fr.depth - firing rate over entire recording depth/day
%           fr.totaltimes - spike times over entire recording depth/day
%
%ALP 3/30/18
% Updated for Kilosort 2 pipeline ALP 8/6/19

totaltime = 0;
%Get firing rate

for i = 1:size(recinfo.files,1)    
    for unit = 1:length(allfiles{f}.rawclusters)
        if i == 1
            fr.totaltimes{unit} = [];
            fr.totaltimes{unit} = Neuron(unit).TS*1000;
        else
            fr.totaltimes{unit} = [fr.totaltimes{unit} (Neuron(unit).TS*1000+totaltime)];
        end
    end
    
    totaltime = totaltime + DurationT*1000; %Total time at this depth
    if i == 1
        switchdur = [0 DurationT*1000];
    else
        switchdur = [switchdur; (switchdur(end,2)+1) (switchdur(end,2)+1+DurationT*1000)]; %switch location of recordings
    end
end

for unit = 1:length(Neuron)
    %fr.bigedges = 0:windowsize*60*1000:totaltime; %in ms
    
    %gauss FR
    spiketrainedges = 0:10:totaltime; 
    fr.spiketrain{unit} = histc(fr.totaltimes{unit}, spiketrainedges); 
    fr.gaussw = gausswin(windowsize*100*60)*100./(sum(gausswin(windowsize*100*60))); %area is 100 to get to Hz
    fr.gaussfr{unit} = conv(fr.spiketrain{unit}, fr.gaussw, 'same'); 

%     fr.depth{unit} = histc(fr.totaltimes{unit}, fr.bigedges)./(1000*60*windowsize)*1000; %get FR
%     fr.depth{unit} = fr.depth{unit}(1:end-1)'; %for edge effects
    
    groups = kmeans(fr.gaussfr{unit}',2, 'MaxIter', 1000); %assume FR bimodal, get kmeans %changed MaxIter to 1000 from default ALP 11/28
    
    [amean, id] = min([mean(fr.gaussfr{unit}(groups==1)), mean(fr.gaussfr{unit}(groups==2))]); %low mean
    bmean = max([mean(fr.gaussfr{unit}(groups==1)), mean(fr.gaussfr{unit}(groups==2))]); %high mean
    astd = std(fr.gaussfr{unit}(groups==id));
    
    %apply kmeans thresholding if the FR drops to 10% of high FR mean
    if min(fr.gaussfr{unit}(100*60:end-100*60)) < 0.1*bmean %to try and help with edge effects
        findtimes = find(fr.gaussfr{unit} >= 2*astd+amean); %threshold is 2std above low mean
        if length(findtimes) > 1 && sum(diff(findtimes) == 1) > 0
            temptimes = contiguous(diff(findtimes),1);
            temptimes = temptimes{2};
            tempdiff = temptimes(:,2) - temptimes(:,1);
            binid = find(tempdiff == max(tempdiff)); %max duration above threshold
%             fr.incltimes{unit} = [fr.bigedges(findtimes(temptimes(binid,1))) fr.bigedges(findtimes(temptimes(binid,2)+1)+1)];
            %GaussFR
            fr.incltimes{unit} = [spiketrainedges(findtimes(temptimes(binid,1))) spiketrainedges(findtimes(temptimes(binid,2)+1))]; 
            findfilesmat = [isExcluded(switchdur(:,1),fr.incltimes{unit}) isExcluded(switchdur(:,2),fr.incltimes{unit})];
            
            if (fr.incltimes{unit}(2) - fr.incltimes{unit}(1))/(1000*60) >= mintimestable
                for file = 1:size(findfilesmat,1)
                    if sum(findfilesmat(file,:)) > 0 
                        fr.stabletimes{unit}(file,:) = [max(fr.incltimes{unit}(1), switchdur(file,1)) min(fr.incltimes{unit}(2), switchdur(file,2))];
                        fr.stabletimes{unit}(file,:) = fr.stabletimes{unit}(file,:) - switchdur(file,1)*ones(1,2);
                    %added ALP 4/10/18    
                    elseif sum(findfilesmat(:,1)) == 0 && sum(findfilesmat(:,2)) == 0
                        temponerec_1 = isExcluded(fr.incltimes{unit}(1), switchdur(file,:)); 
                        temponerec_2 = isExcluded(fr.incltimes{unit}(2), switchdur(file,:));
                        
                        %if the stable time only falls into one recording
                        %and if that recording is this file, then make
                        %stable times, otherwise set to 0 for this file
                        if isequal(temponerec_1, temponerec_2) && sum(temponerec_1+temponerec_2) > 0
                           fr.stabletimes{unit}(file,:) = [max(fr.incltimes{unit}(1), switchdur(file,1)) min(fr.incltimes{unit}(2), switchdur(file,2))];
                           fr.stabletimes{unit}(file,:) = fr.stabletimes{unit}(file,:) - switchdur(file,1)*ones(1,2); 
                        else
                            fr.stabletimes{unit}(file,:) = [0 0];
                        end
                     %ALP 4/10 end
                    else
                        fr.stabletimes{unit}(file,:) = [0 0];
                    end
                end
            else
                fr.stabletimes{unit} = zeros(size(findfilesmat,1),2);
                fr.incltimes{unit} = [0 0];
            end
        else
            fr.stabletimes{unit} = zeros(size(findfilesmat,1),2);
            fr.incltimes{unit} = [0 0];
        end
        
        
        if plotexamples
%             plottime = (fr.bigedges./1000)./60;
%             plottime = plottime(1:end-1);
            
            plottime = spiketrainedges./1000/60; 
            %patch for plotting
            patchindsx = [fr.incltimes{unit}(1)./(1000*60) fr.incltimes{unit}(1)/(1000*60) fr.incltimes{unit}( 2)/(1000*60) fr.incltimes{unit}(2)/(1000*60)];
            patchindsy = [0 (max(fr.gaussfr{unit})+0.1*max(fr.gaussfr{unit})) (max(fr.gaussfr{unit})+0.1*max(fr.gaussfr{unit})) 0];
            
            figure
            patch(patchindsx, patchindsy, [0.6 0.8 1.0])
            hold on
            alpha(0.1)
            ylim([0 (max(fr.gaussfr{unit})+0.1*max(fr.gaussfr{unit}))])
            plot(plottime, fr.gaussfr{unit}, 'k', 'LineWidth', 1.5)
            hold on
            plot(plottime, (amean+2*astd)*ones(1,length(fr.gaussfr{unit})), 'r--', 'LineWidth', 1.5)
            plot(plottime, 0.1*bmean*ones(1,length(fr.gaussfr{unit})), 'b--', 'LineWidth', 1.5)
            legend('Included', 'FR', '2std', '10% High')
            ylabel('Firing Rate (Hz)')
            xlabel('Time (min)')
            xlim([0 totaltime/(1000*60)])
        end
        
    else %else whole time stable
        for file = 1:size(index,1)
            fr.incltimes{unit} = [0 totaltime];
            fr.stabletimes{unit}(file,:) = [0 (switchdur(file,2)-switchdur(file,1))];
        end
        
        if plotexamples
            plottime = spiketrainedges./1000/60; 
            
            figure
            hold on
            plot(plottime, fr.gaussfr{unit}, 'k')
            hold on
            plot(plottime, 0.1*bmean*ones(1,length(fr.gaussfr{unit})), 'b--')
            legend('Firing Rate', '10% High FR')
            ylabel('FR (Hz)')
            xlabel('Time (min)')
            xlim([0 totaltime/(1000*60)])
        end
    end
    
    if plotexamples
%         pause
    end
    
    fr.stabletimes{unit} = fr.stabletimes{unit}./1000; %ms to s
    fr.index = index; 
end
end

