% preprocess the McGurk data with different pipelines
% slice timing with reference slice 1 or 21 (original study was 21 ?)
% despiking ON or OFF (original study was ON)
% normalization at 2 or 3 mm (original study was 2)

clear
clc



%% Set options, matlab path
N_DUMMY_SCANS = 5;
MAX_N_SCANS = 325;

TASK = 'contextmcgurk';

FWHM = 8;

% slice repair (for Art repair)
REPAIR_FLAG = 1;
OUTSLICEdef = 18;
MASK_FLAG = 1;

% despiking option (for Art repair)
FILT_TYPE = 3;
DESPIKE_TYPE = 4;


% containers
DATA_DIR = '/data';
OUTPUT_DIR = '/output';
CODE_DIR = '/code/mcgurk';
% addpath(fullfile('/opt/spm12'));

% windows matlab
% DATA_DIR = 'C:\Users\Remi\Documents\McGurk';
% OUTPUT_DIR = 'C:\Users\Remi\Documents\McGurk\derivatives';
% CODE_DIR = 'C:\Users\Remi\Documents\McGurk\code';

% subsystem
% DATA_DIR = '/mnt/c/Users/Remi/Documents/McGurk/';
% OUTPUT_DIR = '/mnt/c/Users/Remi/Documents/McGurk/derivatives';
% CODE_DIR = '/mnt/c/Users/Remi/Documents/McGurk/code';
% addpath('/home/remi-gau/spm12')

% data set
BIDS_DIR = fullfile(DATA_DIR, 'rawdata');

mkdir(OUTPUT_DIR)
mkdir(fullfile(OUTPUT_DIR, 'spm12_artrepair'))

% add spm12 and spmup to path
addpath(genpath(fullfile(CODE_DIR, 'toolboxes', 'spmup')));
addpath(genpath(fullfile(CODE_DIR, 'toolboxes', 'art_repair')));
addpath(fullfile(CODE_DIR,'bids_fMRI_analysis', 'subfun'));



%% copy file to derivative folder and unpack data
% set options
choices = struct(...
    'outdir', fullfile(OUTPUT_DIR, 'spm12_artrepair'), ...
    'keep_data', 'on',  ...
    'overwrite_data', 'on');

[~,~,~] = mkdir(choices.outdir);
cd(choices.outdir)

[BIDS, subjects, options] = spmup_BIDS_unpack(BIDS_DIR, choices);

nb_subj = numel(spm_BIDS(BIDS, 'subjects'));

% get additional data from metadata (TR, resolution, slice timing
% parameters)
[opt] = get_metadata(BIDS, subjects, TASK);



%% 3D, slice repair, realign and unwarp
for isubj = 1:nb_subj

    nb_runs = numel(subjects{isubj}.func);
    matlabbatch = [];

    for irun = 1:nb_runs

        fprintf('\nconverting to 3D file and removing dummy scans sub %s run %s \n', ...
            num2str(isubj), num2str(irun))

        [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{irun, 1});
 
        spm_file_split(subjects{isubj}.func{irun, 1}, filepath);
        
        three_dim_files = spm_select('FPList', filepath, ['^' name '_00.*' ext '$']);


        if numel(three_dim_files)>MAX_N_SCANS
            files_to_delete = three_dim_files([1:N_DUMMY_SCANS MAX_N_SCANS:end],:);
        else
            files_to_delete = three_dim_files(1:N_DUMMY_SCANS,:);
        end
        delete(files_to_delete)

        fprintf('repairing slices: sub %s run %s \n', ...
            num2str(isubj), num2str(irun))

        files_to_repair = spm_select('FPList', filepath, ['^' name '_00.*' ext '$']);

        art_slice(files_to_repair, OUTSLICEdef, REPAIR_FLAG, MASK_FLAG)

    end

    fprintf('\nrealign and unwarp: sub %s \n', num2str(isubj))
    matlabbatch = realign_unwarp_batch(matlabbatch, 1, subjects{isubj}.func);
    
    spm_jobman('run', matlabbatch)

end


%% coregister to MNI
for isubj = 1:nb_subj


    nb_runs = numel(subjects{isubj}.func);
    matlabbatch = [];


    fprintf('\ncoregister to MNI: sub %s \n', num2str(isubj))

    spm_dir = spm_fileparts(which('spm'));
    T1_template = fullfile(spm_dir, 'canonical', 'avg152T1.nii');
    T2_template = fullfile(spm_dir, 'canonical', 'avg152T2.nii');

    anat = subjects{isubj}.anat;

    [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{1});
    mean_image = spm_select('FPList', filepath, ['^meanug*' name '_00.*' ext '*']);

    other = [];
    for iRun = 1:nb_runs
        [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{iRun});
        other = [other ; spm_select('FPList', filepath, ['^ug' name '_00.*' ext '$'])]; %#ok<*AGROW>
    end

    matlabbatch = coregister_batch(matlabbatch, ...
        1, T1_template, anat, '');
    matlabbatch = coregister_batch(matlabbatch, numel(matlabbatch)+1, ...
        T2_template, mean_image, other);
    matlabbatch = coregister_batch(matlabbatch, numel(matlabbatch)+1, ...
        mean_image, anat, '');

    spm_jobman('run', matlabbatch)
end



%% segment, slice time, despike, normalize and smooth
for isubj = 1:nb_subj

    nb_runs = numel(subjects{isubj}.func);
    matlabbatch = [];


    fprintf('\nsegment: sub %s \n', num2str(isubj))
    anat = subjects{isubj}.anat;
    matlabbatch = segment_batch(matlabbatch,1,anat);


    fprintf('\nslice timing: sub %s \n', num2str(isubj))
    for iSlice_ref = 1:numel(opt.slice_reference)
        slice_reference = opt.slice_reference(iSlice_ref);
        matlabbatch = slice_timing_batch(matlabbatch, 1+iSlice_ref, subjects{isubj}.func, opt, slice_reference);
    end
    
    spm_jobman('run', matlabbatch)


    fprintf('\ndespiking: sub %s \n', num2str(isubj))
    for iSlice_ref = 1:numel(opt.slice_reference)
        for iRun = 1:nb_runs
            [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{iRun});
            images_2_despike = spm_select('FPList', filepath, ...
                ['^a_' sprintf('%02.0f',opt.slice_reference(iSlice_ref)) 'ug' name '_00.*' ext '$']);
            art_despike(images_2_despike, FILT_TYPE, DESPIKE_TYPE);
        end
    end


    fprintf('\nnormalizing data: sub %s \n', num2str(isubj))

    [filepath, name, ext] = spm_fileparts(subjects{isubj}.anat);
    anat = spm_select('FPList', filepath, ['^m' name '.*' ext '*']);
    segment_mat = spm_select('FPList', filepath, ['^' name '_seg_sn.mat$']);

    [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{1});
    mean_image = spm_select('FPList', filepath, ['^meanug*' name '_00.*' ext '*']);

    input_files = char({anat; mean_image});

    func_files = {};
    for iRun = 1:nb_runs
        [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{iRun});
        func_files = cat(1, func_files, ...
            cellstr(spm_select('FPList', filepath, ['^da_.*ug' name '_00.*' ext '$'])), ... % normalize despiked files
            cellstr(spm_select('FPList', filepath, ['^a_.*ug' name '_00.*' ext '$'])) ); % normalize non-despiked files
    end
    
    func_files = char(func_files);

    matlabbatch = [];
    idx = 1;
    for iRes = 1:numel(opt.norm_res)
        matlabbatch = normalize_batch(matlabbatch, idx, input_files, segment_mat, opt.norm_res(iRes)); % normalize anat and mean
        idx = idx + 1;
        matlabbatch = normalize_batch(matlabbatch, idx, func_files, segment_mat, opt.norm_res(iRes)); % normalize functional
        idx = idx + 1;
    end
    
    spm_jobman('run', matlabbatch)


    fprintf('\nsmooth data: sub %s \n', num2str(isubj))
    matlabbatch = [];
    func_files = [];
    for iRun = 1:nb_runs
        [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{iRun});
        func_files = [func_files ; spm_select('FPList', filepath, ...
            ['^w_.*a_.*ug' name '_00.*' ext '$'])]; %#ok<*AGROW>
    end
    matlabbatch = smooth_batch(matlabbatch, 1, func_files, FWHM);

    spm_jobman('run', matlabbatch)
end


%% merge to 4D and clean the other files
for isubj = 1:nb_subj

    fprintf('\nconverting to 4D: sub %s \n', num2str(isubj))
    
    nb_runs = numel(subjects{isubj}.func);

    matlabbatch = [];
    idx = 0;

    for iRun = 1:nb_runs

        [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{iRun});
        
        % rename mean images to prevent them from being deleted later
        mean_images = spm_select('FPList', filepath,'^.*mean.*000.*$');
        for iMean = 1:size(mean_images,1)
            copyfile( ...
                mean_images(iMean,:), ...
                strrep(mean_images(iMean,:), 'bold_00006', 'bold'))
        end

        for iDespiked = 0:1
            if iDespiked
                despik_pfx = 'd';
            else
                despik_pfx = '';
            end
            for iRes = 1:numel(opt.norm_res)
                for iSlice_ref = 1:numel(opt.slice_reference)

                    idx = idx + 1;

                    input_files = spm_select('FPList', filepath, ...
                        ['^sw_' sprintf('%02.0f',opt.norm_res(iRes)) ...
                        despik_pfx 'a_' sprintf('%02.0f',opt.slice_reference(iSlice_ref)) '.*' name '_00.*' ext '$']); %#ok<*AGROW>

                    output_name = fullfile(filepath, ...
                        ['sw' sprintf('%02.0f',opt.norm_res(iRes)) ...
                        '_' despik_pfx 'a-' sprintf('%02.0f',opt.slice_reference(iSlice_ref)) '_ug_' name ext]);

                    matlabbatch = threeD_to_fourD(matlabbatch, idx, input_files, output_name);
                end
            end
        end
    end

    spm_jobman('run', matlabbatch)

    fprintf('\ndeleting files: sub %s \n', num2str(isubj))
    for iRun = 1:nb_runs
        [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{iRun});
        delete(fullfile(filepath, ['*' name '_00*' ext]))
    end
end
