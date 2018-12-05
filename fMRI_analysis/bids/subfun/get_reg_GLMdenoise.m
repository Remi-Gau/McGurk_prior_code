function matlabbatch = get_reg_GLMdenoise(matlabbatch, cfg, analysis_dir)
% adds noise regressors extracted from GLMdenoise to design matrix
% option 1 and 2: just runs the GLMdenoiose with same design but slightly
% different options
% option 3: does GLMdenoise cross validation over days and not over runs

fmri_spec = matlabbatch{1,1}.spm.stats.fmri_spec;
nb_run = size(fmri_spec.sess, 2);
TR = fmri_spec.timing.RT;
cdt_dur = fmri_spec.sess(1).cond(1).duration;
GLMdenoise_opt = struct('extraregressors',cell(1));

fig_dir = fullfile(analysis_dir, 'GLMdenoise_figs');

if cfg.GLM_denoise > 0
    
    fprintf('getting data for GLM denoise:\n')
    
    for iRun = 1:nb_run
        
        fprintf(' - run %i\n', iRun)

        % gets the design for this session
        nb_cdt = numel(fmri_spec.sess(iRun).cond);
        stim_onsets = {};
        for iCdt = 1:nb_cdt
            stim_onsets{1,iCdt} = ...
                fmri_spec.sess(iRun).cond(iCdt).onset;
        end
        design{1,iRun}=stim_onsets;
        
        % get extra regressors (RT, blocks)
        nb_extra_reg = numel(fmri_spec.sess(iRun).regress);
        for iExtra_reg = 1:nb_extra_reg
            GLMdenoise_opt.extraregressors{1,iRun}(:,iExtra_reg) = ...
                fmri_spec.sess(iRun).regress(iExtra_reg).val;
        end
        
        % get mvt regressors
        if cfg.mvt
            rp_reg = load(fmri_spec.sess(iRun).multi_reg{1});
            for iRp_reg = 1:size(rp_reg,2)
                GLMdenoise_opt.extraregressors{1,iRun}(:,nb_extra_reg+iRp_reg) = ...
                    rp_reg(:,iRp_reg);
            end
        end
        
        % loads fMRI data
        hdr = spm_vol(char(fmri_spec.sess(iRun).scans));
        data{1,iRun} = single(spm_read_vols(hdr)); %#ok<*AGROW>
        
    end
    
    switch cfg.GLM_denoise
        case 1
            hrfknobs = [];
        case 2
            hrfknobs = 1;
            GLMdenoise_opt.numpcstotry = 20;
            GLMdenoise_opt.denoisespec =  '00000';
        case 3
            hrfknobs = 1;
            GLMdenoise_opt.numpcstotry = 20;
            GLMdenoise_opt.denoisespec =  '00000';
            error('not implemented')
    end

    
    fprintf('running GLM denoise \n')
    results = GLMdenoisedata(...
        design, data, cdt_dur, TR, 'assume', hrfknobs, GLMdenoise_opt, fig_dir);
    
    % insert the regressors into the batch
    for iRun = 1:nb_run
        for j=1:results.pcnum
            matlabbatch.spm.stats.fmri_spec.sess(1,iRun).regress(1,end+1).name = ...
                strcat('GLMdenoise_', num2str(j));
            matlabbatch.spm.stats.fmri_spec.sess(1,iRun).regress(1,end).val = ...
                double(results.pcregressors{1,iRun}(:,j));
        end
    end
    
end

end