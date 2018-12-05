function matlabbatch = set_cdt_GLM_batch(matlabbatch, idx, irun, cdt, cfg)

if ~isempty(cdt.onsets)
    
    if ~isfield(matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun), 'cond')
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond = [];
    end
    
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end+1).name = cdt.name;
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).duration = 0;
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).tmod = 0;
    
    switch cfg.stim_onset
        case 'A'
            onset_delay = (1-0.04*8)/2;
        case 'V'
            onset_delay = (1-0.04*8)/2 * -1;
        case 'B'
            onset_delay = 0;
    end
    
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).onset = ...
        cdt.onsets + onset_delay ;
    
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).pmod = ...
        struct('name',{},'param',{}, 'poly', {});
    
end

end