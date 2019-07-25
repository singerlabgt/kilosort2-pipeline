function getFiltEEGWFs(index, file, hpFilt, anprocesseddatadir, WFchannel, samprate, rewrite)
%getFiltEEGWFs filter EEG for waveforms for Kilosort 2
%   For Kilosort2 metrics or cell type classification
%   ALP 7/24/19

if ~isfile([anprocesseddatadir, num2str(WFchannel), '\eegWFs', num2str(file), '.mat']) || rewrite
    
    tempload = load([anprocesseddatadir, num2str(WFchannel), '\raweeg',...
        num2str(samprate/1000), 'k', num2str(file), '.mat'], ['raweeg', num2str(samprate/1000), 'k']);
    rawdat = tempload.(['raweeg', num2str(samprate/1000), 'k']){index(1)}{index(2)}{file}.data;
    eegWFs{index(1)}{index(2)}{file}.data = filtfilt(hpFilt, rawdat);
    eegWFs{index(1)}{index(2)}{file}.samprate = samprate;
    eegWFs{index(1)}{index(2)}{file}.filter = hpFilt;
    
    save([anprocesseddatadir, num2str(WFchannel), '\eegWFs', num2str(file), '.mat'], 'eegWFs')
    
end
end

