% unpacks

%% Set options, matlab path and get data
clear
clc

data_dir = 'C:\Users\Remi\Documents\McGurk';
% data_dir = '/data';

output_dir = 'C:\Users\Remi\Documents\McGurk\derivatives';
% output_dir = '/output';

nb_dummy_scans = 5;


%%% max_nb_vols = 325; %%%


task = 'contextmcgurk';

FWHM = 8;

% Slice repair
repair_flag = 1;
OUTSLICEdef = 18;
mask_flag = 1;

% add spm12 and spmup to path
addpath(genpath(fullfile(pwd, 'toolboxes', 'spmup')));
addpath(genpath(fullfile(pwd, 'toolboxes', 'ArtRepair')));
addpath(fullfile(pwd, 'subfun'));

% data set
BIDS_dir = fullfile(data_dir, 'rawdata');

%% copy file to derivative folder and unpack data
% set options
choices = struct(...
    'outdir', fullfile(output_dir, 'art_repair', 'octave'), ...
    'keep_data', 'on',  ...
    'overwrite_data', 'off');

cd(choices.outdir)

[BIDS, subjects, options] = spmup_BIDS_unpack(BIDS_dir, choices);

subjs_ls = spm_BIDS(BIDS, 'subjects');
nb_subj = numel(subjs_ls);
spm_BIDS(BIDS, 'tasks');

hdr = spm_vol(subjects{1}.func{1, 1});
opt.epi_res = diag(hdr(1).mat);
opt.epi_res(end) = [];
opt.epi_res = abs(min(opt.epi_res));
opt.nb_slices = hdr(1).dim(3);

metadata = spm_BIDS(BIDS, 'metadata', 'sub', subjs_ls{1}, 'type', 'bold', ...
    'task', task, 'run', '01');

opt.nb_slices = numel(metadata.SliceTiming);
opt.TR = metadata.RepetitionTime*1000;
opt.TA = opt.TR - (opt.TR/opt.nb_slices);
opt.acquisition_order = metadata.SliceTiming*1000;
slice_reference = [1 floor(opt.nb_slices/2)];



%% 3D, slice repair, realign and unwarp
for isubj = 1:nb_subj
    
    nb_runs = numel(subjects{isubj}.func);
    matlabbatch = [];
    
    for irun = 1:nb_runs
        
        fprintf('\nconverting to 3D file and removing dummy scans sub %s run %s \n', ...
            num2str(isubj), num2str(irun))
        
            [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{irun, 1});
        
        %     three_dim_files = spm_file_split(subjects{isubj}.func{irun, 1}, filepath);
        
%             files_to_delete = three_dim_files(1:nb_dummy_scans);
        %     delete(files_to_delete.fname)
        
        %     descr = struct('Name', 'My Dataset', 'BIDSVersion', '1.0.2';
        %     spm_jsonwrite('dataset_description.json', descr, struct('indent', ' '));
        
        fprintf('repairing slices: sub %s run %s \n', ...
            num2str(isubj), num2str(irun))
        
            files_to_repair = spm_select('FPList', filepath, ['^' name '_00.*' ext '$']);
        
        %     art_slice(files_to_repair, OUTSLICEdef, repair_flag, mask_flag)
        
    end
    
    fprintf('\nrealign and unwarp: sub %s \n', num2str(isubj))
      matlabbatch = realign_unwarp_batch(matlabbatch, 1, subjects{isubj}.func);
    %   spm_jobman('run', matlabbatch)
    
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
    
    matlabbatch = coregister_batch(matlabbatch, 1, T1_template, anat, '');
    matlabbatch = coregister_batch(matlabbatch, 2, T2_template, mean_image, other);
    matlabbatch = coregister_batch(matlabbatch, 3, mean_image, anat, '');
    
%     spm_jobman('run', matlabbatch)
end



%% segment, slice time, despike, normalize and smooth
for isubj = 1:nb_subj
    
    nb_runs = numel(subjects{isubj}.func);
    matlabbatch = [];
    
    
    fprintf('\nsegment: sub %s \n', num2str(isubj))
    anat = subjects{isubj}.anat;
    matlabbatch = segment_batch(matlabbatch,1,anat);
    
    
    fprintf('\nslice timing: sub %s \n', num2str(isubj))
    for iSlice_ref = 1:numel(slice_reference)
        opt.slice_reference = slice_reference(iSlice_ref);
        matlabbatch = slice_timing_batch(matlabbatch, 1+iSlice_ref, subjects{isubj}.func, opt);
        
    end
%     spm_jobman('run', matlabbatch)

    
    fprintf('\ndespiking: sub %s \n', num2str(isubj))
    for iRun = 1:nb_runs
        [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{iRun});
        images_2_despike = spm_select('FPList', filepath, ['^a_01ug' name '_00.*' ext '$']);
%         art_despike(images_2_despike,3,4);
        images_2_despike = spm_select('FPList', filepath, ['^a_21ug' name '_00.*' ext '$']);
%         art_despike(images_2_despike,3,4);
    end
    

    fprintf('\nnormalizing data: sub %s \n', num2str(isubj))
    
    [filepath, name, ext] = spm_fileparts(subjects{isubj}.anat);
    anat = spm_select('FPList', filepath, ['^m' name '.*' ext '*']);
    segment_mat = spm_select('FPList', filepath, ['^' name '_seg_sn.mat$']); 
    
    [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{1});
    mean_image = spm_select('FPList', filepath, ['^meanug*' name '_00.*' ext '*']);
    
    input_files = char({anat; mean_image});
    
    func_files = [];
    for iRun = 1:nb_runs
        [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{iRun});
        func_files = [func_files ; spm_select('FPList', filepath, ['^da_.*ug' name '_00.*' ext '$'])]; %#ok<*AGROW>
    end

    matlabbatch = [];
%     matlabbatch = normalize_batch(matlabbatch, 1, input_files, segment_mat, 2);
%     matlabbatch = normalize_batch(matlabbatch, 2, input_files, segment_mat, opt.epi_res);
%     matlabbatch = normalize_batch(matlabbatch, 3, func_files, segment_mat, 2);
%     matlabbatch = normalize_batch(matlabbatch, 4, func_files, segment_mat, opt.epi_res);
    
    
    fprintf('\nsmooth data: sub %s \n', num2str(isubj))
    func_files = [];
    for iRun = 1:nb_runs
        [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{iRun});
        func_files = [func_files ; spm_select('FPList', filepath, ['^w_.*da_.*ug' name '_00.*' ext '$'])]; %#ok<*AGROW>
    end
    matlabbatch = smooth_batch(matlabbatch, 1, func_files, FWHM);
    
    spm_jobman('run', matlabbatch)
end
