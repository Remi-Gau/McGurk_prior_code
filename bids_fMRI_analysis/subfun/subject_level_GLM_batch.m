function matlabbatch = subject_level_GLM_batch(matlabbatch, idx, analysis_dir, opt, cfg)
   
    matlabbatch{idx}.spm.stats.fmri_spec.dir = {analysis_dir};
    
    matlabbatch{idx}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{idx}.spm.stats.fmri_spec.timing.RT = opt.TR;
    matlabbatch{idx}.spm.stats.fmri_spec.timing.fmri_t = opt.nb_slices;
    matlabbatch{idx}.spm.stats.fmri_spec.timing.fmri_t0 = cfg.slice_reference;
    
    matlabbatch{idx}.spm.stats.fmri_spec.fact = struct('name',{},'levels',{});
    
    matlabbatch{idx}.spm.stats.fmri_spec.bases.hrf.derivs = [cfg.time_der, 0]; % First is time derivative, Second is dispersion
    
    matlabbatch{idx}.spm.stats.fmri_spec.volt = 1;
    
    matlabbatch{idx}.spm.stats.fmri_spec.global = 'None';
    
    matlabbatch{idx}.spm.stats.fmri_spec.mask = {''};
    
    matlabbatch{idx}.spm.stats.fmri_spec.cvi = 'AR(1)';
end