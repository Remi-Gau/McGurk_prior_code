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

DATA_DIR = 'D:\BIDS\McGurk\';
% DATA_DIR = '/data';

% data set
BIDS_DIR = fullfile(DATA_DIR, 'rawdata');

OUTPUT_DIR = 'D:\BIDS\McGurk\derivatives';
% OUTPUT_DIR = '/output';

CODE_DIR = 'C:\Users\Remi\Documents\McGurk\code';
% CODE_DIR = '/code/mcgurk';

% add spm12 and spmup to path
addpath(genpath(fullfile(CODE_DIR, 'toolboxes', 'spmup')));
addpath(genpath(fullfile(CODE_DIR, 'toolboxes', 'art_repair')));
addpath(genpath(fullfile(CODE_DIR, 'toolboxes', 'GLMdenoise')));

addpath(fullfile(CODE_DIR,'bids_fMRI_analysis', 'subfun'));


%% get data set info
choices = struct(...
    'outdir', fullfile(OUTPUT_DIR, 'spm12_artrepair'), ...
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
for isubj = 1:nb_subj
    
    nb_runs = numel(subjects{isubj}.func);
    
    run_ls = spm_BIDS(BIDS, 'data', 'sub', subj_ls{isubj}, ...
        'type', 'bold');
    
    cdt = [];
    blocks = [];
    
    for iRun = 1:nb_runs
        
        % get onsets for all the conditions and blocks
        tsv_file = strrep(run_ls{iRun}, 'bold.nii.gz', 'events.tsv');
        onsets{iRun} = spm_load(tsv_file); %#ok<*SAGROW>

        [cdt, blocks] = get_cdt_onsets(cdt, blocks, onsets, iRun);
        
    end
    
    for iGLM = 1:size(all_GLMs) 
        
        % get configuration for this GLM 
        cfg = get_configuration(all_GLMs, opt, iGLM); 

        % to know on which data to run this GLM
        func_file_prefix = set_file_prefix(cfg);
        
        
        % list functional data and realignement parameters for each run
        for iRun = 1:nb_runs
            
            [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{iRun});
            
            data{iRun,1} = spm_select('FPList', filepath, ...
                ['^' func_file_prefix name ext '$']);
            
            rp_mvt_files{iRun,1} = ...
                spm_select('FPList', filepath, ['^rp_.*' name '_00.*.txt$']);
        end
        
        % to make sure that we got the data and the RP files
        if any(cellfun('isempty', data))
            error('Some data is missing: sub-%s - file prefix: %s', ...
                subj_ls{isubj}, func_file_prefix)
        end
        if any(cellfun('isempty', rp_mvt_files))
            error('Some realignement parameter is missing: sub-%s', ...
                subj_ls{isubj})
        end
        
        analysis_dir = name_analysis_dir(cfg);
        analysis_dir = fullfile ( ...
            OUTPUT_DIR, 'spm12_artrepair', ...
            ['sub-' subj_ls{isubj}], analysis_dir );
        mkdir(analysis_dir)
        
        if cfg.RT_correction
            % specify a dummy GLM to get one regressor for all the RTs
            RT_regressors_col = get_RT_regressor(analysis_dir, data, cdt, opt, cfg);
        else
            RT_regressors_col = {};
        end
        
        matlabbatch = [];
        
        % set the basic batch for this GLM
        matlabbatch = ...
            subject_level_GLM_batch(matlabbatch, 1, analysis_dir, opt, cfg);
       
        for iRun = 1:nb_runs
            
            % adds session specific parameters
            matlabbatch = ...
                set_session_GLM_batch(matlabbatch, 1, data, iRun, cfg, rp_mvt_files);
            
            % adds pcondition specific parameters for this session
            for iCdt = 1:size(cdt,2)
                matlabbatch = ...
                    set_cdt_GLM_batch(matlabbatch, 1, iRun, cdt(iRun,iCdt), cfg);
            end

            % adds extra regressors (blocks, RT param mod, ...) for this session
            matlabbatch = ...
                set_extra_regress_batch(matlabbatch, 1, iRun, opt, cfg, blocks, RT_regressors_col);
        end
        
        % runs GLMdenoise and adds noise regressors if necessary
        matlabbatch = get_reg_GLMdenoise(matlabbatch, cfg, analysis_dir);

        % specify design
        spm_jobman('run', matlabbatch)
        
        % concatenates
        if cfg.concat
            error('concatenation not yet implemented')
            spm_fmri_concatenate(...
                fullfile(analysis_dir, 'SPM.mat'), ...
                scans);
        end
        
        % estimate design
        matlabbatch = [];
        matlabbatch{1}.spm.stats.fmri_est.spmmat{1,1} = fullfile(analysis_dir, 'SPM.mat');    
        matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1; 
        spm_jobman('run', matlabbatch)
        
        % estimate contrasts
        matlabbatch = [];
        matlabbatch = set_t_contrasts(analysis_dir);
        spm_jobman('run', matlabbatch)

    end
    
    
end