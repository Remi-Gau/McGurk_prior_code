function matlabbatch = coregister_batch(matlabbatch,idx,target,source,other)

matlabbatch{idx}.spm.spatial.coreg.estimate.ref = {target};                
matlabbatch{idx}.spm.spatial.coreg.estimate.source = {source};

matlabbatch{idx}.spm.spatial.coreg.estimate.other = cellstr(other);                              
matlabbatch{idx}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{idx}.spm.spatial.coreg.estimate.eoptions.sep = [4,2];
matlabbatch{idx}.spm.spatial.coreg.estimate.eoptions.tol = [repmat(0.02, 1, 3), repmat(0.001, 1, 3), repmat(0.01, 1, 3), repmat(0.001, 1, 3)];
matlabbatch{idx}.spm.spatial.coreg.estimate.eoptions.fwhm = [7,7];

[filepath] = spm_fileparts(source);
coreg_mat_name = strcat('coreg_mat_', datestr(now, 'yyyy_mm_dd_HH_MM'), '.mat');

matlabbatch{idx+1}.cfg_basicio.var_ops.cfg_save_vars.name = coreg_mat_name;
matlabbatch{idx+1}.cfg_basicio.var_ops.cfg_save_vars.outdir = {filepath};
matlabbatch{idx+1}.cfg_basicio.var_ops.cfg_save_vars.vars(1).vname = 'M';
matlabbatch{idx+1}.cfg_basicio.var_ops.cfg_save_vars.vars(1).vcont(1) = ...
    cfg_dep('Coregister: Estimate: Coregistration Matrix', ...
    substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','M'));
matlabbatch{idx+1}.cfg_basicio.var_ops.cfg_save_vars.vars(2).vname = 'target_file';
matlabbatch{idx+1}.cfg_basicio.var_ops.cfg_save_vars.vars(2).vcont = target;
matlabbatch{idx+1}.cfg_basicio.var_ops.cfg_save_vars.vars(3).vname = 'source_file';
matlabbatch{idx+1}.cfg_basicio.var_ops.cfg_save_vars.vars(3).vcont = source;
matlabbatch{idx+1}.cfg_basicio.var_ops.cfg_save_vars.vars(4).vname = 'other_files';
matlabbatch{idx+1}.cfg_basicio.var_ops.cfg_save_vars.vars(4).vcont = other;
matlabbatch{idx+1}.cfg_basicio.var_ops.cfg_save_vars.saveasstruct = false;
end