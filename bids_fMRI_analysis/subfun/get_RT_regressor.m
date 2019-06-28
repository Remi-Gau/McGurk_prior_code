function RT_regressors = get_RT_regressor(analysis_dir, data, cdt, opt, cfg)
% sets up an fMRI design with no data and then extracts parametric
% modulators of RT for all events pooled together

fprintf('\n Computing RT regressors\n')

nb_runs = numel(data);

median_RT = cat(1,cdt(:).RT);
median_RT(median_RT>990) = [];
median_RT = median(median_RT);

matlabbatch{1}.spm.stats.fmri_design.dir = {analysis_dir};
matlabbatch{1}.spm.stats.fmri_design.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_design.timing.RT = opt.TR;
matlabbatch{1}.spm.stats.fmri_design.timing.fmri_t = opt.nb_slices;
matlabbatch{1}.spm.stats.fmri_design.timing.fmri_t0 = cfg.slice_reference;

matlabbatch{1}.spm.stats.fmri_design.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_design.bases.hrf.derivs = [cfg.time_der, 0];
matlabbatch{1}.spm.stats.fmri_design.volt = 1;
matlabbatch{1}.spm.stats.fmri_design.global = 'None';
matlabbatch{1}.spm.stats.fmri_design.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_design.cvi = 'AR(1)';

for iRun = 1:nb_runs
    
    % creates one condition for all the events
    all_stim(iRun, 1).onsets = cat(1,cdt(iRun,:).onsets); %#ok<*AGROW>
    
    % changes missed and other responses into median RT
    RT = cat(1,cdt(iRun,:).RT);
    RT(RT>990) = median_RT;
    all_stim(iRun, 1).RT = RT;
    
    matlabbatch{1}.spm.stats.fmri_design.sess(1,iRun).nscan = ...
        numel(spm_vol(data{iRun}));
    
    matlabbatch{1}.spm.stats.fmri_design.sess(1,iRun).cond(1) = struct(...
        'name', 'all_stim', ...
        'onset', all_stim(iRun, 1).onsets, ...
        'duration', 0, ...
        'tmod', 0);
    
    matlabbatch{1}.spm.stats.fmri_design.sess(1,iRun).cond(1).pmod.name = 'reaction_time';
    matlabbatch{1}.spm.stats.fmri_design.sess(1,iRun).cond(1).pmod.param = all_stim(iRun, 1).RT;
    matlabbatch{1}.spm.stats.fmri_design.sess(1,iRun).cond(1).pmod.poly = 1;
    
    matlabbatch{1}.spm.stats.fmri_design.sess(1,iRun).multi = {''};
    matlabbatch{1}.spm.stats.fmri_design.sess(1,iRun).hpf = cfg.HPF;
    
    matlabbatch{1}.spm.stats.fmri_design.sess(1,iRun).multi_reg{1} = '';
    matlabbatch{1}.spm.stats.fmri_design.sess(1,iRun).regress = struct('name',{},'val',{});
end

spm_jobman('run', matlabbatch)

load(fullfile(analysis_dir,'SPM.mat'), 'SPM')
RT_regressors_col = find(contains(SPM.xX.name','reaction_time'));
for iRun = 1:nb_runs
    col_to_select = ismember(SPM.Sess(iRun).col, RT_regressors_col);
    RT_regressors{iRun} = SPM.xX.X(SPM.Sess(iRun).row, SPM.Sess(iRun).col(col_to_select));
end

delete(fullfile(analysis_dir,'SPM.mat'))
end