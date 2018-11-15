function matlabbatch = fourD_to_threeD(matlabbatch,idx,filename,output_dir)
    matlabbatch{idx}.spm.util.split.vol = {[filename ',1']};
    matlabbatch{idx}.spm.util.split.outdir = {output_dir};
end