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

clear
clc

%% Set options, matlab path
task = 'contextmcgurk';

nb_dummy_scans = 5;

data_dir = 'C:\Users\Remi\Documents\McGurk';
% data_dir = '/data';

% data set
BIDS_dir = fullfile(data_dir, 'rawdata');

output_dir = 'C:\Users\Remi\Documents\McGurk\derivatives';
% output_dir = '/output';

% add spm12 and spmup to path
addpath(genpath(fullfile(pwd, 'toolboxes', 'spmup')));
addpath(genpath(fullfile(pwd, 'toolboxes', 'GLMdenoise')));
addpath(fullfile(pwd, 'subfun'));


%% get data set info
choices = struct(...
    'outdir', fullfile(output_dir, 'art_repair', 'octave'), ...
    'keep_data', 'on',  ...
    'overwrite_data', 'off');

cd(choices.outdir)

[BIDS, subjects, options] = spmup_BIDS_unpack(BIDS_dir, choices);

subj_ls = spm_BIDS(BIDS, 'subjects');
nb_subj = numel(subj_ls);

% get aadditional data from metadata (TR, resolution, slice timing
% parameters)
[opt] = get_metadata_func(BIDS, subjects, task);

opt.GLM_denoise = [0 1 2 3]; % GLMdenoise OFF, 1, 2 or 3 (original study was OFF)
opt.HPF = [0 100 200]; % HPF none, 100, 200 (original study was 200)
opt.stim_onset = {'A' 'V' 'B'}; % stim onset on audio, on video, in between
opt.RT_correction = [0 1]; % RT correction (original study had both)
opt.block_type = {'none' '083e' '100e' '100s'}; % % Blocks of none, Exp83, Exp100, square100 (original study was Exp100)


%%
for isubj = 1:nb_subj
    
    nb_runs = numel(subjects{isubj}.func);
    
    % get stimuli onsets
    run_ls = spm_BIDS(BIDS, 'data', 'sub', subj_ls{isubj}, ...
        'type', 'bold');

    for iRun = 1:nb_runs
        tsv_file = strrep(run_ls{iRun}, 'bold.nii.gz', 'events.tsv');
        onsets{iRun} = spm_load(tsv_file); %#ok<*SAGROW>
        onsets{iRun}.onset = onsets{iRun}.onset - nb_dummy_scans * opt.TR; % remove time from dummy scans  
        
        cdt_ls = unique(onsets{iRun}.trial_type);
        for iCdt = 1:numel(cdt_ls)
            cdt_name = cdt_ls{iCdt};
            trials = strcmp(onsets{iRun}.trial_type,cdt_name);
            cdt(iRun,iCdt).name = cdt_name;
            cdt(iRun,iCdt).onsets = onsets{iRun}.onset(trials);
            cdt(iRun,iCdt).RT = onsets{iRun}.response_time(trials);
        end
        
    end

    for iDespiked = 0:1
        
        if iDespiked
            despik_pfx = 'd';
        else
            despik_pfx = 'd';
        end
        
        % for iRes = 1:numel(opt.norm_res)
        % for iSlice_ref = 1:numel(opt.slice_reference)
        slice_reference = opt.slice_reference(2);
        norm_res = opt.norm_res(1);
        
        func_file_prefix = ...
            ['sw' sprintf('%02.0f',norm_res) ...
            '_' despik_pfx 'a-' sprintf('%02.0f',slice_reference) '_ug_'];
        
        % list fucntional data and realignement parameters for each run
        for iRun = 1:nb_runs
            [filepath, name, ext] = spm_fileparts(subjects{isubj}.func{iRun});
            data{iRun,1} = fullfile(filepath, ...
                        [func_file_prefix name ext]);
                    
            rp_mvt_files{iRun,1} = spm_select('FPList', filepath, ['^rp_.*' name '_00.*.txt$']);
        end
        
        data %#ok<*NOPTS>
        
        rp_mvt_files
        
        
        for iGLM_denoise = 1:numel(opt.GLM_denoise)
            for iHPF = 1:numel(opt.HPF)
                for iStim_onset = 1:numel(opt.stim_onset)
                    for iRT_correction = 1:numel(opt.RT_correction)
                        for iBlock_type = 1:numel(opt.block_type)
                            
                            GLM_denoise = opt.GLM_denoise(iGLM_denoise);
                            HPF = opt.HPF(iHPF);
                            stim_onset = opt.stim_onset{iStim_onset};
                            RT_correction = opt.RT_correction(iRT_correction);
                            block_type = opt.block_type{iBlock_type};
                            
                            analysis_dir = fullfile (output_dir, ['sub-' subj_ls{isubj}], ...
                                [ 'GLM_' ...
                                'despike-' num2str(iDespiked) '_' ...
                                'denoise-' num2str(iGLM_denoise) '_' ...
                                'HPF-' sprintf('%03.0f',HPF) '_' ...
                                'onset-' stim_onset '_' ...
                                'RT-' num2str(RT_correction) '_' ...
                                'block-' block_type ...
                                ]);
                            
                            mkdir(analysis_dir)
                            
                            matlabbatch = [];
                            matlabbatch = subject_level_GLM_batch(matlabbatch, 1, analysis_dir, opt, slice_reference);
                            
                            
                            if HPF == 0
                                HPF = Inf;
                            end
                            
                            for iRun = 1:nb_runs
                                matlabbatch = set_session_GLM_batch(matlabbatch, 1, data, iRun, HPF, rp_mvt_files);
                                
                                for iCdt = 1:size(cdt,2)
                                    matlabbatch = set_cdt_GLM_batch(matlabbatch, 1, iRun, iCdt, cdt(iRun,iCdt));
                                end
                            end

                            spm_jobman('run', matlabbatch)
                            
                            matlabbatch = [];
                            matlabbatch{1}.spm.stats.fmri_est.spmmat{1,1} = fullfile(analysis_dir, 'SPM.mat');     %set the spm file to be estimated
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
                end
            end
        end
        
    end
    
end