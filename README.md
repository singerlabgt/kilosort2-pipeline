# kilosort2-pipeline
#### This pipeline is used to prepare, sort, curate, and quality control data with kilosort2 and phy spike sorting software in the Singer Lab

## Table of contents
[How it works](#how-it-works) - brief information on how the script operates  
[Using the pipeline](#using-the-pipeline) - how to set up and use the pipeline on your own data  
[Manual curation guidelines](#guidelines-for-manual-curation) - information on the manual curation process  

## How it works
The Kilosort2 Pipeline has four main sections. As a user, you will only edit Sections 1-2, which consist of input parameters and run options. Do not edit Section 3-4 without consulting all other users. Feel free to edit on your own branch or fork, but don't push changes to the master without consulting everyone.  

### Section 1 - setting parameters
In this section, user profiles and recording parameters are defined. Edit permanent parameters for your probes and experiments in your [User Profile](#creating-a-user-profile). Set information about the recording sessions you wish to cluster. 

```matlab
[params, dirs] = userProfiles_K2pipeline('Abby', 'ChronicFlicker');

animals = [25];
daysincl = [210913];
datesexcl = [nan];
```

### Section 2 - setting run options
In this section, flags are set which tell the script which steps to perform. 

```matlab
%% Set run options
%First, run the preCuration step. 
%After manually curation the Kilosort2 output, run the postCuration step. 

run.preCuration = 0;            %write specificed files to .bin for Kilosort
run.kilosortScript = 0;         %run kilosort spike sorting using main_kilosort script
run.kilosortGUI = 0;            %run kilosort spike sorting using the gui
run.transferPrecuratedData = 0; %automatically transfer precurated data to server, removes locally
run.transferPostcuratedData = 0; %automatically transfer postcurated data to server, removes locally
run.postCuration = 0;           %get single unit times, get waveforms, and apply quality metrics

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

### Section 3 - writing raw data files and running the algorithm
The third step runs the kilosort algorithm to generate an uncurated set of potential units. 

```matlab
%% write raw recording files to BIN for kilosort2
converttoBIN_K2(anrawdatadir, anclusterdir, params.files, params.probeChannels, params.brainReg, dirs.clusfolder)

%% run kilosort algorithm
if run.kilosortGUI
  kilosort
end

if run.kilosortScript
  main_kilosort(anclusterdir, dirs, params, channels)
end
```
Note: After this step, you need to curate the data before proceeding with the data structure creation.

### Section 4 - creating output data structures
After the data has been curated, set the `run.postCuration` flag to generate the lab-specific cluster structures, get waveforms for each cluster from the raw data files, and apply quality metrics on the output clusters.

```matlab
%get information about the curated units from the kilsort and phy files
makeClusterStructure(anclusterdir, recinfo, dirs.clusfolder, params, br)
            
%get waveforms and other metrics about each cluster
getWaveForms_K2(anprocesseddatadir, anclusterdir, recinfo, figdir, rewrite)
            
%apply quality metrics to all clusters and create outputs structures
applyQualityMetrics(anclusterdir, recinfo, rewrite.qualitymetrics, th)
```

## Using the pipeline

### Installation instructions
#### Installing kilosort2
Visit the [Kilosort2 Github page](https://github.com/MouseLand/Kilosort2) for installation instructions. Further information on the algorithm and GUI settings can be found in the [Kilosort wiki](https://github.com/MouseLand/Kilosort2/wiki).

#### Installing phy2
Visit the [Phy Github page](https://github.com/cortex-lab/phy) for information about installing Phy2. 


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

### Running the typical clustering workflow
1. Enter the information for your desired recordings: `animals`, `daysincl`, and `daysexcl`. 
2. Set  `run.preCuration = 1` and option to generate the raw .bin files from the raw acquisition system data (e.g. Intan or SpikeGadgets). Also, set either `run.kilosortScript = 1` OR `run.kilosortGUI = 1` to run the kilosort algorithm via a script or graphical user interface. 
3. Run the script. 
4. After Kilosort has finished, open a GitBash or Anaconda terminal and run the following commands
    ```bash
    cd "\path\to\your\data\sorted\kilosort\"  # to get to your kilosort directory
    conda activate phy2                       # to activate the conda environment for the phy package
    phy template-gui params.py                # to open the phy gui to curate clusters
    ```
5. Manually curate clusters in the Phy2 gui. Save while curation is in progress, and before exiting. See the [Tutorial](tutorial/instructions.md) for instructions on how to manually curate data.
6. Return to matlab and set `run.preCuration = 0`, `run.kilosortScript = 0` and `run.kilosortGUI = 0`. Then set `run.postCuration = 1`.
7. Run the pipeline to generate curated data structures and apply quality control metrics 
  
### Inputs
The only required data input is raw data files. Currently, only Intan (.rhd) and Spike Gadgets (.rec) data formats are supported. 

### Outputs
The outputs are a singer lab specific clusters data structure format. Curated spike sorting output files are also generated by phy and can be used directly for other analysis processes (e.g. CellExplorer, NWB conversion)

## Guidelines for manual curation
The manual curation step of spike sorting is used to refine the results of the kilosort algorithm (excluding noise, identifying good vs. multi-unit activity units, and merging or splitting cells). We recommend the [Phy sorting user guide](https://phy.readthedocs.io/en/latest/sorting_user_guide/) for a good overview of the basics of the spike sorting and manual curation process.

Based on other sorting guides and our experience, we have also generated an set of [Instructions](tutorial/instructions.md), [Example Workflow](tutorial/instructions.md#schematic-to-follow), and [List of Special Cases](tutorial/special-cases.md) to help with the manual curation process. It is important to note that these guidelines were developed with extracellular electrophysiology recordings using NeuroNexus silicon probes, mostly with data acquired from hippocampus. The decision making process and guidelines may be different depending on your brain region of interest, project, and experimental question. 


