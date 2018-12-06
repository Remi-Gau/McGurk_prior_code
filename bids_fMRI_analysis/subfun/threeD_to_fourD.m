function matlabbatch = threeD_to_fourD(matlabbatch, idx, input_files, output_name)
matlabbatch{idx}.spm.util.cat.vols =  cellstr(input_files);
matlabbatch{idx}.spm.util.cat.name = output_name;
matlabbatch{idx}.spm.util.cat.dtype = 0;
end
