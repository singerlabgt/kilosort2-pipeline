# kilosort2-pipeline
#### This script is used to prepare data to be sorted with Kilosort2, and to process the resulting output into standardized data structures. 

## Table of contents
[How it works](#how-it-works) - brief information on how the script operates  
[Using the script](#using-the-script) - how to set up and use the pipeline on your own data  
[Clustering and manual curation](#clustering-and-manual-curation) - information on installing clustering software and curating the output  

## How it works
The Kilosort2 Pipeline has four main sections. As a user, you will only edit Sections 1-2, which consist of input parameters and run options. Do not edit Section 3 without consulting all other users. 

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
% writeToBin - first step, run to get .bin for Kilosort2
% getSingleUnitTimes - run after manual curation in Phy2

writeToBIN = 1; 
getSingleUnitTimes = 0; 
getWFstruct = 0;
qualityMetrics = 0; 
```

A second set of flags tell the script to rewrite files at specific steps of the pipeline, if they exist. 

```matlab
%% set rewriting options
% set these options to force the code to rewrite the files specified below.
% Otherwise, the pipeline will load up previously stored files if they
% exist.

rewrite.eeg = 0;
rewrite.wf = 1;
rewrite.qualitymetrics = 1;
```

### Section 3 - write clustering files

## Using the script
### Creating a user profile

### Typical clustering workflow

### Inputs
The only required data input is raw data files. Currently, only Intan (.rhd) and Spike Gadgets (.rec) data formats are supported. 

### Outputs

## Clustering and manual curation 
This script relies upon the Kilosort2 algorithm and Phy2 gui to cluster and manually curate. See the links below for information on installing those packages. 

### Installing kilosort2
Visit https://github.com/MouseLand/Kilosort2 for installation instructions. Further information on the algorithm and GUI settings can be found in the wiki https://github.com/MouseLand/Kilosort2/wiki.

### Installing phy2
Visit https://github.com/cortex-lab/phy for information about installing Phy2. 

### Singer Lab guidelines for clustering


