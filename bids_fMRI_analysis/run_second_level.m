% runs subject level on the McGurk data with different pipelines
% then get the t-contrasts for all the needed condition for the group level

% despiking ON or OFF (original study was ON)

%%% slice timing with reference slice 1 or 21 (original study was 21 ?) ???
%%% normalization at 2 or 3 mm (original study was 2) ???

% HPF none, 100, 200 (original study was 200)
% stim onset on audio, on video, in between
% Blocks of none, Exp83, Exp100, Square83, Square100 (original study was Exp100)
% GLMdenoise OFF, 1, 2 or 3 (original study was OFF)
% RT correction (original study had both)

% time derivative (used or not ; original study was used)
% mvt noise regressors (ON or OFF ; original study was ON)

% implement concatenation

clear
clc

%% Set options, matlab path
TASK = 'contextmcgurk';

% DATA_DIR = 'C:\Users\Remi\Documents\McGurk';
DATA_DIR = '/data';

% data set
BIDS_DIR = fullfile(DATA_DIR, 'rawdata');

% OUTPUT_DIR = 'C:\Users\Remi\Documents\McGurk\derivatives';
OUTPUT_DIR = '/output';
OUTPUT_DIR = fullfile(OUTPUT_DIR, 'spm_artrepair', 'group');

% CODE_DIR = 'C:\Users\Remi\Documents\McGurk\code';
CODE_DIR = '/code/mcgurk/';

% set path
addpath(fullfile(CODE_DIR,'fMRI_analysis','bids', 'subfun'));


%% get data set info
choices = struct(...
    'outdir', fullfile(OUTPUT_DIR, 'spm_artrepair'), ...
    'keep_data', 'on',  ...
    'overwrite_data', 'off');

cd(choices.outdir)

[BIDS, subjects, options] = spmup_BIDS_unpack(BIDS_DIR, choices);

subj_ls = spm_BIDS(BIDS, 'subjects');
nb_subj = numel(subj_ls);

% get additional data from metadata (TR, resolution, slice timing
% parameters)
[opt] = get_metadata(BIDS, subjects, TASK);

% set up all the possible of combinations of GLM possible
[opt, all_GLMs] = set_all_GLMS(opt);


%%
