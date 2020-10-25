# kilosort2-pipeline
#### This script is used to prepare data to be sorted with Kilosort2, and to process the resulting output into standardized data structures. 

## Table of contents
[How it works](#how-it-works) - brief information on how the script operates  
[Using the script](#using-the-script) - how to set up and use the pipeline on your own data  
[Clustering and manual curation](#clustering-and-manual-curation) - information on installing clustering software and curating the output  

## How it works
The Kilosort2 Pipeline has three main sections. As a user, you will only edit Sections 1-2, which consist of input parameters and run options. Do not edit Section 3 without consulting all other users. Feel free to edit on your own branch or fork, but don't push changes to the master without consulting everyone.  

### Section 1 - setting parameters
In this section, user profiles and recording parameters are defined. Edit permanent parameters for your probes and experiments in your [User Profile](#creating-a-user-profile). Set information about the recording sessions you wish to cluster. 

```matlab
[params, dirs] = userProfiles_K2pipeline('Abby', 'ChronicFlicker');
params.animal = [21, 21, 21];
params.day = [200204, 200205, 200213];
params.files = {1:5, 1:5, 1:5};
```

### Section 2 - setting run options
In this section, flags are set which tell the script which steps to perform. 

```matlab
%% Set run options
%First, run the preCuration step. 
%After manually curation the Kilosort2 output, run the postCuration step. 

run.preCuration = 0; %write specificed files to .bin for Kilosort
run.postCuration = 1; %get single unit times, get waveforms, and apply quality metrics
```

A second set of flags tell the script to rewrite files at specific steps of the pipeline, if they exist. 

```matlab
%% Set rewriting options
% set these options to force the code to rewrite the files specified below.
% Otherwise, the pipeline will load up previously stored files if they
% exist.

rewrite.eeg = 1;
rewrite.wf = 1;
rewrite.qualitymetrics = 1;
```

### Section 3 - write clustering files
This section of the documentation is in progress...

## Using the script
### Creating a user profile
Create a profile for yourself to save commonly used directories and settings for your experiments. Here you will set information about your probe (how many channels and shanks), the brain regions recorded from, and define your preferences for directories and saving. Detailed information about the format of each variable is in the comments of the userProfile function, and you can base your profile off of existing profiles. You must add a profile - because each experiment has unique directories and parameters, there is no default setting.

```matlab
%%%%%%%%%%%%%%%%% ----- New User ----- %%%%%%%%%%%%%%%

if strcmp(user, 'NewUser')
  if strcmp(project, 'NewProject')
        params.probeChannels = {1:32}; %should be the indices of the channels in the data structure totalCh x samples
        params.brainReg = {'CA1'}; %your brain region here 
        params.animalID = 'A'; %sub your animal prefix here
        params.numShanks = 1; % how many shanks does your probe have? 
        
        dirs.rawdatadir = ''; %the location of your raw data files
        dirs.clusterdir = ''; %where you want your cluster files to end up
        dirs.processeddatadir = ''; %where the processed data for your experiment is
        dirs.clusfolder = 'sorted\'; %subfolder that finished files will save into 
  end
end
```

### Typical clustering workflow
1. Enter the information for your desired recordings: `params.animal`, `params.day`, and `params.files`. Set  `run.preCuration = 1` and run the pipeline to generate your data as a .bin file. 
2. Open the Kilosort2 Gui by entering `kilosort` in the command line. 
3. After Kilosort has finished, open a terminal and `cd` to your kilosort directory. For example, `> cd C:\Desktop\TempKilosort\MyMouse\sorted\kilosort\`. Enter `> conda activate phy2` to activate the python package for the gui. Phy2 should appear next to your directory name, like so: `(phy2) C:\Desktop\TempKilosort\MyMouse\sorted\kilosort\`. To open the gui, enter `> phy template-gui params.py`. 
4. Manually curate clusters in the Phy2 gui. Save while curation is in progress, and before exiting. 
5. Return to the pipeline and set `run.preCuration = 0` and `run.postCuration = 1`. Run the pipeline to generate curated data structures as detailed in [Outputs](#outputs). 
6. Copy the folder containing your Kilosort files and output variables to the server, and continue with your analysis! 

### Inputs
The only required data input is raw data files. Currently, only Intan (.rhd) and Spike Gadgets (.rec) data formats are supported. 

### Outputs
The section of the documentation is in progress...

## Clustering and manual curation 
This script relies upon the Kilosort2 algorithm and Phy2 gui to cluster and manually curate. See the links below for information on installing those packages. 

### Installing kilosort2
Visit https://github.com/MouseLand/Kilosort2 for installation instructions. Further information on the algorithm and GUI settings can be found in the wiki https://github.com/MouseLand/Kilosort2/wiki.

### Installing phy2
Visit https://github.com/cortex-lab/phy for information about installing Phy2. 

### Singer Lab guidelines for clustering
This section of the documentation is in progress...

