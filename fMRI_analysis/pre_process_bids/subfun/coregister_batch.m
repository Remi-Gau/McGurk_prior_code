function matlabbatch = coregister_batch(matlabbatch,idx,target,source,other)

matlabbatch{idx}.spm.spatial.coreg.estimate.ref = {target};                
matlabbatch{idx}.spm.spatial.coreg.estimate.source = {source};

matlabbatch{idx}.spm.spatial.coreg.estimate.other = cellstr(other);                              
matlabbatch{idx}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{idx}.spm.spatial.coreg.estimate.eoptions.sep = [4,2];
matlabbatch{idx}.spm.spatial.coreg.estimate.eoptions.tol = [repmat(0.02, 1, 3), repmat(0.001, 1, 3), repmat(0.01, 1, 3), repmat(0.001, 1, 3)];
matlabbatch{idx}.spm.spatial.coreg.estimate.eoptions.fwhm = [7,7];

end