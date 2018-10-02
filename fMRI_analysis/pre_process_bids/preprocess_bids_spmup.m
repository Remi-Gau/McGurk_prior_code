% preprocess data using the spmup toolbox by Cyril Pernet

clear
close all
clc

addpath(genpath('D:\Dropbox\GitHub\spmup'))
addpath('D:\Dropbox\GitHub\SPM_RG\mancoreg')

bids_dir = 'E:\McGurk\rawdata';

choice = struct('removeNvol', 5, 'keep_data', 'on',  'overwrite_data', 'on', ...
    'despike', 'on', 'drifter', 'off', 'motionexp', 'off', 'scrubbing', 'off', ...
    'compcor', 'off', 'norm', 'EPInorm', 'skernel', [8 8 8], 'derivatives', '1', ...
    'ignore_fieldmaps', 'on', 'QC', 'on'); % standard SPM pipeline
[anatQA,fMRIQA]=spmup_BIDS(bids_dir,choice)