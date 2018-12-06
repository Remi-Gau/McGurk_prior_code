function matlabbatch = normalize_batch(matlabbatch, idx, input_files, segment_mat, res)

matlabbatch{idx}.spm.tools.oldnorm.write.subj.matname{1} = segment_mat;
matlabbatch{idx}.spm.tools.oldnorm.write.subj.resample = cellstr(input_files);

matlabbatch{idx}.spm.tools.oldnorm.write.roptions.preserve = 0;
matlabbatch{idx}.spm.tools.oldnorm.write.roptions.bb = [-78,-112,-50;78,76,85];
matlabbatch{idx}.spm.tools.oldnorm.write.roptions.vox = repmat(res, [1, 3]);
matlabbatch{idx}.spm.tools.oldnorm.write.roptions.interp = 1;
matlabbatch{idx}.spm.tools.oldnorm.write.roptions.wrap = [0 0 0];
matlabbatch{idx}.spm.tools.oldnorm.write.roptions.prefix = ['w_' sprintf('%02.0f',res)];

end
