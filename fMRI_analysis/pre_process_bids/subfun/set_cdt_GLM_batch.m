function matlabbatch = set_cdt_GLM_batch(matlabbatch, idx, irun, icdt, cdt)
matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,icdt).name = cdt.name;
matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,icdt).duration = 0;
matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,icdt).tmod = 0;
matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,icdt).pmod=struct('name',{},'param',{}, 'poly', {});
matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,icdt).onset = cdt.onsets;
end