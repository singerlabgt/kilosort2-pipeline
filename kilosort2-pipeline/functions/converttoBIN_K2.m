function converttoBIN_K2(rawdatadir, clusterdir, fnums, probes, brainreg, clusfolder)
%CONVERTTOBIN_K2 Convert raw recording files to .bin. 
%   Inputs:
%       rawdatadir: location of raw recording files
%       clusterdir: desired output for clustering
%       fnums: desired files to cluster
%       probes: cell array of channels, separated by brain region
%       brainreg: brainregions, should correspond to probes order
%   Output:
%       M x N .bin file; M channels, N datapoints. All recordings from full
%       recording session concatenated. Saved in clusterdir. 
%
%   Add new else statements for new recording types.
%   ALP 7/12/19

files.nums = fnums;
files.intan = dir([rawdatadir, '*.rhd']);
files.spikegadgets = dir([rawdatadir, '*.rec']);

for p = 1:length(probes)
    
    if ~isempty(files.intan)
        disp('Intan files detected.')
        perRegDir = fullfile(clusterdir, brainreg{p}, clusfolder);
        if ~exist(perRegDir, 'dir'); mkdir(perRegDir); end
        RHDtoBIN_K2(rawdatadir, perRegDir, 'int16', ...
            files.nums, probes{p})
    elseif ~isempty(files.spikegadgets)
        disp('Spike Gadgets files detected.')
        perRegDir = fullfile(clusterdir, brainreg{p}, clusfolder);
        if ~exist(perRegDir, 'dir'); mkdir(perRegDir); end
        RECtoBIN_K2(rawdatadir, perRegDir, 'int16', files.spikegadgets,...
            files.nums, probes{p})
    else
        disp('No files found')
    end
end

end

