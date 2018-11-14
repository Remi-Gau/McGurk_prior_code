% unpacks

%% Set options, matlab path and get data
clear
clc

% data_dir = 'C:\Users\Remi\Documents\McGurk';
data_dir = '/data';

% output_dir = 'C:\Users\Remi\Documents\McGurk\derivatives';
output_dir = '/output';

% add spm12 and spmup to path
% addpath('/opt/spm12')
addpath(genpath(fullfile(pwd, 'spmup')))

% data set
BIDS_dir = fullfile(data_dir, 'rawdata');




%% copy file to derivative folder and unpack data
% set options
choices = struct(...
    'outdir', fullfile(output_dir, 'art_repair', 'octave'),...
    'keep_data', 'on',  ...
    'overwrite_data', 'on');

[BIDS,subjects,options] = spmup_BIDS_unpack(BIDS_dir,choices);


%% 

spm('defaults', 'FMRI');