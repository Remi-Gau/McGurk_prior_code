function matlabbatch = segment_batch(matlabbatch,idx,anat)

spm_root = spm_fileparts(which('spm'));

matlabbatch{idx}.spm.tools.oldseg.data = {anat};
matlabbatch{idx}.spm.tools.oldseg.output.GM = [0 0 1];
matlabbatch{idx}.spm.tools.oldseg.output.WM = [0 0 1];
matlabbatch{idx}.spm.tools.oldseg.output.CSF = [0 0 0];
matlabbatch{idx}.spm.tools.oldseg.output.biascor = 1;
matlabbatch{idx}.spm.tools.oldseg.output.cleanup = 0;
matlabbatch{idx}.spm.tools.oldseg.opts.tpm = { 
    fullfile(spm_root, 'toolbox', 'OldSeg' , 'grey.nii')
    fullfile(spm_root, 'toolbox', 'OldSeg' , 'white.nii')
    fullfile(spm_root, 'toolbox', 'OldSeg' , 'csf.nii')};
matlabbatch{idx}.spm.tools.oldseg.opts.ngaus = [2 2 2 4];
matlabbatch{idx}.spm.tools.oldseg.opts.regtype = 'mni';
matlabbatch{idx}.spm.tools.oldseg.opts.warpreg = 1;
matlabbatch{idx}.spm.tools.oldseg.opts.warpco = 25;
matlabbatch{idx}.spm.tools.oldseg.opts.biasreg = 0.0001;
matlabbatch{idx}.spm.tools.oldseg.opts.biasfwhm = 60;
matlabbatch{idx}.spm.tools.oldseg.opts.samp = 3;
matlabbatch{idx}.spm.tools.oldseg.opts.msk = {''};

end