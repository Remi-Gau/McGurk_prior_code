function matlabbatch = set_extra_regress_batch(matlabbatch, idx, irun, cfg, blocks, RT_regressors_col)

% Inputs the reaction time parametric modulator regressors
if cfg.RT_correction
    for iRT_reg = 1:size(RT_regressors_col{irun},2)
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).regress(1,iRT_reg).name = ...
            ['RT_par_mod-' num2str(iRT_reg)];
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).regress(1,iRT_reg).val = ...
            RT_regressors_col{irun}(:,iRT_reg);
    end
end

end