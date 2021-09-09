function transferKilosortPrecuratedData(anclusterdir, dirs)

% get the folder name
currentdatadir = erase(anclusterdir, dirs.localclusterdir);
targetdir = [dirs.remoteprecurationdir currentdatadir];

% transfer all contents to the server
if ~exist(targetdir, 'dir')
    copystatus = copyfile(anclusterdir,targetdir);
    assert(copystatus, 'Warning: files could not be successfully transferred to server')
else
    disp('Precurated folder already exists on server. Skipping...')
end

% remove from local computer
if exist(targetdir, 'dir') %double check files copied successfully
    rmstatus = rmdir(anclusterdir,'s'); %this is the local dir
    assert(rmstatus, 'Warning: files were not successfully removed from the local directory')
end