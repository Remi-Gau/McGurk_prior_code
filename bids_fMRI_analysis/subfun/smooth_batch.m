function matlabbatch = smooth_batch(matlabbatch, idx, input_files, FWHM)

matlabbatch{idx}.spm.spatial.smooth.data = cellstr(input_files);
matlabbatch{idx}.spm.spatial.smooth.fwhm = [FWHM FWHM FWHM];                                 
matlabbatch{idx}.spm.spatial.smooth.dtype = 0;
matlabbatch{idx}.spm.spatial.smooth.prefix = 's';

end