% unpacks

%% Set options, matlab path and get data
clear
clc

nb_dummy_scans = 5;

data_dir = 'C:\Users\Remi\Documents\McGurk';
% data_dir = '/data';

output_dir = 'C:\Users\Remi\Documents\McGurk\derivatives';
% output_dir = '/output';

% add spm12 and spmup to path
addpath(genpath(fullfile(pwd, 'toolboxes', 'spmup')));
addpath(genpath(fullfile(pwd, 'toolboxes', 'ArtRepair')));
addpath(fullfile(pwd, 'subfun'));

% data set
BIDS_dir = fullfile(data_dir, 'rawdata');


%% copy file to derivative folder and unpack data
% set options
choices = struct(...
    'outdir', fullfile(output_dir, 'art_repair', 'octave'),...
    'keep_data', 'on',  ...
    'overwrite_data', 'off');

[BIDS,subjects,options] = spmup_BIDS_unpack(BIDS_dir,choices);

% BIDS

% subjects

nb_subj = numel(subjects);

for isubj = 1%:nb_subj
    nb_runs = numel(subjects{isubj}.func);
    matlabbatch = [];
    for irun = 1%:2 %nb_runs
        
        fprintf('\nconverting to 3D file and removing dummy scans sub %s run %s \n', ...
            num2str(isubj), num2str(irun))
        [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{irun,1});
        
%         three_dim_files = spm_file_split(subjects{isubj}.func{irun,1}, filepath);

%         files_to_delete = three_dim_files(1:nb_dummy_scans);
%         delete(files_to_delete.fname)
        
        files_to_repair = spm_select('FPList',filepath,['^' name '_00.*' ext '*']);
        repair_flag = 1;
        OUTSLICEdef = 18;
        mask_flag = 1;
        art_slice(files_to_repair, OUTSLICEdef, repair_flag, mask_flag)
    end
%     spm_jobman('run',matlabbatch);
end
