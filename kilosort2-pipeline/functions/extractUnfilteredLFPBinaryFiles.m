function extractUnfilteredLFPBinaryFiles(fileNameMask, useRefs)
%
%extractLFPBinaryFiles(fileNameMask)
%extractLFPBinaryFiles(fileNameMask, useRefs)
%
%Extracts and saves LFP information from a .rec file. The extracted files
%are saved in a new subfolder in the same directory as the .rec file.
%
%fileNameMask:  this is the name of the rec file without the .rec
%extention (example: 'myfile' for myfile.rec). If multiple .rec files need
%to be stitched together, you can use the part of the filename that all
%files have in common, assuming the first part is the same (example:
%'myfile' for myfile_part1.rec and myfile_part2.rec).  The files will be
%stiched together sorted by the time when the files were created. 
%
%useRefs (default 0): this determines whether or not the saved files are
%utilizing the digital reference settings in the .rec file.  A value of 1
%turns referencing on.

if (nargin < 2)
    useRefs = 0;
elseif (useRefs > 1) || (useRefs < 0)
    error('useRefs argument must be either 0 or 1');
end

recFiles = dir([fileNameMask,'*.rec']);

recFileString = [];
recFileDates = [];
for i=1:length(recFiles)
    recFileDates = [recFileDates;recFiles(i).datenum];
end
[s, sind] = sort(recFileDates);
for i=1:length(sind)
    recFileString = [recFileString ' -rec ' recFiles(sind(i)).name];
end


%Find the path to the extraction programs
trodesPath = which('trodes_path_placeholder.m');
trodesPath = fileparts(trodesPath);

%Beacuse the path may have spaces in it, we deal with it differently in
%windows vs mac/linux
disp(['"',fullfile(trodesPath,'exportLFP'),'"', recFileString, ' -output ', fileNameMask]);
if ispc
    eval(['!"',fullfile(trodesPath,'exportLFP'),'"', recFileString, ' -usespikefilters 0 -lowpass -1 -highpass -1 -userefs 0 -outputrate 30000 -output ', fileNameMask]);
else
    escapeChar = '\ ';
    trodesPath = strrep(trodesPath, ' ', escapeChar);
    eval(['!',fullfile(trodesPath,'exportLFP'), recFileString, ' -output ', fileNameMask]);
end





