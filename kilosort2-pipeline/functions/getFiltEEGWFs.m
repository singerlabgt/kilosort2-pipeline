function getFiltEEGWFs(recinfo, f, hpFilt, anprocesseddatadir, WFchannel, samprate, rewrite)
%getFiltEEGWFs filter EEG for waveforms for Kilosort 2
%   For Kilosort2 metrics or cell type classification
%       Adapted from loadwaveforms.m SMP
%   ALP 7/24/19

    
if ~isfile([anprocesseddatadir, num2str(WFchannel), '\eegWFs', num2str(recinfo.files(f)), '.mat']) || rewrite
    
    tempload = load([anprocesseddatadir, num2str(WFchannel), '\raweeg',...
    num2str(samprate/1000), 'k', num2str(recinfo.files(f)), '.mat'], ['raweeg', num2str(samprate/1000), 'k']);
    rawdat = tempload.(['raweeg', num2str(samprate/1000), 'k']){recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.data;
    eegWFs{recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.data = filtfilt(hpFilt, rawdat);
    eegWFs{recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.samprate = samprate;
    eegWFs{recinfo.index(1)}{recinfo.index(2)}{recinfo.files(f)}.filter = hpFilt;
    
    save([anprocesseddatadir, num2str(WFchannel), '\eegWFs', num2str(recinfo.files(f)), '.mat'], 'eegWFs')
    
end
end

