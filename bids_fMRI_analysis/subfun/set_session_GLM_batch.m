function matlabbatch = set_session_GLM_batch(matlabbatch, idx, data, irun, cfg, rp_mvt_files)

matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).multi{1} = '';

matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).hpf = cfg.HPF;

[direc, name, ext] = spm_fileparts(data{irun});
matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).scans = ...
    cellstr(spm_select('ExtFPList', direc, ['^' name ext '$'], Inf));

if cfg.mvt
matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).multi_reg{1} = rp_mvt_files{irun};
else
    matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).multi_reg{1} = '';
end

matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).regress = struct('name',{},'val',{});

end