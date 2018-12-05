% runs subject level on the McGurk data with different pipelines

% despiking ON or OFF (original study was ON)

%%% slice timing with reference slice 1 or 21 (original study was 21 ?) ???
%%% normalization at 2 or 3 mm (original study was 2) ???

% HPF none, 100, 200 (original study was 200)
% stim onset on audio, on video, in between
% Blocks of none, Exp83, Exp100, square100 (original study was Exp100)
% GLMdenoise OFF, 1, 2 or 3 (original study was OFF)
% RT correction (original study had both)

% time derivative (used or not ; original study was used)
% mvt noise regressors (ON or OFF ; original study was ON)

% implement concatenation

clear
clc

%% Set options, matlab path
TASK = 'contextmcgurk';

DATA_DIR = 'C:\Users\Remi\Documents\McGurk';
% DATA_DIR = '/data';

% data set
BIDS_DIR = fullfile(DATA_DIR, 'rawdata');

OUTPUT_DIR = 'C:\Users\Remi\Documents\McGurk\derivatives';
% OUTPUT_DIR = '/output';

CODE_DIR = 'C:\Users\Remi\Documents\McGurk\code';
% CODE_DIR = '/code/mcgurk';

% add spm12 and spmup to path
addpath(genpath(fullfile(CODE_DIR, 'toolboxes', 'spmup')));
addpath(genpath(fullfile(CODE_DIR, 'toolboxes', 'art_repair')));
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

% get aadditional data from metadata (TR, resolution, slice timing
% parameters)
[opt] = get_metadata_func(BIDS, subjects, TASK);

opt.despiked = [0 1];

opt.GLM_denoise = [0 1 2 3]; % GLMdenoise OFF, 1, 2 or 3 (original study was OFF)
opt.HPF = [Inf 100 200]; % HPF none, 100, 200 (original study was 200)
opt.stim_onset = {'A' 'V' 'B'}; % stim onset on audio, on video, in between
opt.RT_correction = [0 1]; % RT correction (original study had both)
opt.block_type = {'none' '083e' '100e' '100s'}; % % Blocks of none, Exp83, Exp100, square100 (original study was Exp100)
opt.time_der = [0 1]; % time derivative (used or not ; original study was used)
opt.mvt = [0 1]; % mvt noise regressors (ON or OFF ; original study was ON)

% list all possible GLMs to run
sets{1} = 1:numel(opt.despiked); %#ok<*NASGU>
sets{end+1} = 2; %opt.slice_reference
sets{end+1} = 1; %opt.norm_res
sets{end+1} = 1; %:numel(opt.GLM_denoise);
sets{end+1} = 1:numel(opt.HPF);
sets{end+1} = 1:numel(opt.stim_onset);
sets{end+1} = 1:numel(opt.RT_correction);
sets{end+1} = 1:numel(opt.block_type);
sets{end+1} = 1:numel(opt.time_der);
sets{end+1} = 1:numel(opt.mvt);

[a, b, c, d, e, f, g, h, i, j] = ndgrid(sets{:}); clear sets
all_GLMs = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:)];


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
        func_file_prefix = set_func_file_prefix(cfg);
        
        
        % list functional data and realignement parameters for each run
        for iRun = 1:nb_runs
            
            [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{iRun});
            
            data{iRun,1} = spm_select('FPList', filepath, ...
                ['^' func_file_prefix name ext '$']);
            
            rp_mvt_files{iRun,1} = ...
                spm_select('FPList', filepath, ['^rp_.*' name '_00.*.txt$']);
        end
        
        % data %#ok<*NOPTS>
        % rp_mvt_files
        
        analysis_dir = fullfile (OUTPUT_DIR, 'spm_artrepair', ['sub-' subj_ls{isubj}], ...
            [ 'GLM_' ...
            'despike-' num2str(cfg.despiked) '_' ...
            'st-' num2str(cfg.slice_reference) '_' ...
            'res-' num2str(cfg.norm_res) '_' ...
            'denoise-' num2str(cfg.GLM_denoise) '_' ...
            'HPF-' sprintf('%03.0f',cfg.HPF) '_' ...
            'onset-' cfg.stim_onset '_' ...
            'RT-' num2str(cfg.RT_correction) '_' ...
            'block-' cfg.block_type '_' ...
            'timeder-' num2str(cfg.time_der) '_' ...
            'mvt-' num2str(cfg.mvt) ...
            ]);
        
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
                set_extra_regress_batch(matlabbatch, 1, iRun, cfg, blocks, RT_regressors_col);
        end
        
        % specify design
        spm_jobman('run', matlabbatch)
        
        % estimamte design
        matlabbatch = [];
        matlabbatch{1}.spm.stats.fmri_est.spmmat{1,1} = fullfile(analysis_dir, 'SPM.mat');    
        matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1; 
        spm_jobman('run', matlabbatch)
        
        
        %                             % denoise 1
        %                             Results = GLMdenoisedata(Design, Data, Condition_Duration, TR, 'assume', [], opt,'DenoiseFig')
        %
        %                             % denoise 2
        %                             opt.numpcstotry = 20;
        %                             opt.denoisespec =  '00000';
        %                             Results = GLMdenoisedata(Design, Data, Condition_Duration, TR, 'assume', 1, opt,'DenoiseFig')
        %
        %                             % denoise 3
        %                             Results = GLMdenoisedata(Design, Data, Condition_Duration, TR, 'assume', 1, opt,'DenoiseFig')
        %
        %                             DenoiseResults.pcnum =  Results.pcnum;
        %                             DenoiseResults.pcregressors =  Results.pcregressors;
        %
        %                             save(['DenoiseDay' num2str(Day_Ind) '.mat'], 'Design', 'Condition_Duration', 'TR', 'opt', 'DenoiseResults', 'Runs2Include')
        %
        %                             for j=1:DenoiseResults.pcnum
        %                                 matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).regress(1,end+1).name = strcat('Noise Regresor ', num2str(j));
        %                                 matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).regress(1,end).val = double(DenoiseResults.pcregressors{1,i}(:,j));
        %                             end
        
        
        
        
    end
    
    
end