function main_kilosort(anclusterdir, dirs, params, channels)

% setup parameters
addpath(genpath(dirs.kilosortdir)) % path to kilosort folder
addpath(dirs.npymatlabdir) % for converting to Phy
rootZ = anclusterdir; % the raw data binary file is in this folder

run(dirs.configfile)
ops.fproc = fullfile(rootZ, 'temp_wh.dat'); % proc file on a fast SSD
ops.NchanTOT = channels; % total number of channels in your recording
ops.chanMap = dirs.channelmapfile;

%% this block runs all the steps of the algorithm
fprintf('Looking for data inside %s \n', rootZ)

% find the binary file
fs          = [dir(fullfile(rootZ, '*.bin')) dir(fullfile(rootZ, '*.dat'))];
ops.fbinary = fullfile(rootZ, fs(1).name);

% preprocess data to create temp_wh.dat
rez = preprocessDataSub(ops);

% time-reordering as a function of drift
rez = clusterSingleBatches(rez);

% saving here is a good idea, because the rest can be resumed after loading rez
save(fullfile(rootZ, 'rez.mat'), 'rez', '-v7.3');

% main tracking and template matching algorithm
rez = learnAndSolve8b(rez);

% OPTIONAL: remove double-counted spikes - solves issue in which individual spikes are assigned to multiple templates.
% See issue 29: https://github.com/MouseLand/Kilosort2/issues/29
%rez = remove_ks2_duplicate_spikes(rez);

% final merges
rez = find_merges(rez, 1);

% final splits by SVD
rez = splitAllClusters(rez, 1);

% final splits by amplitudes
rez = splitAllClusters(rez, 0);

% decide on cutoff
rez = set_cutoff(rez);

fprintf('found %d good units \n', sum(rez.good>0))

% write to Phy
fprintf('Saving results to Phy  \n')
rezToPhy(rez, rootZ);

