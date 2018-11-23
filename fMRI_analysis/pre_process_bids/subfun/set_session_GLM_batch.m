function matlabbatch = set_session_GLM_batch(matlabbatch, idx, data, irun, HPF, rp_mvt_files)

matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).multi{1} = '';

matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).regress = struct('name',{},'val',{});

matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).hpf = HPF;

matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).scans = {data{irun}};

matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).multi_reg{1} = rp_mvt_files{irun};

end