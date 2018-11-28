function matlabbatch = realign_unwarp_batch(matlabbatch,idx,input_files)

nb_runs = numel(input_files);

for iRun = 1:nb_runs

    [filepath, name, ext] = spm_fileparts(input_files{iRun,1});

    files_to_realign = spm_select('FPList',filepath,['^g' name '_00.*' ext '*']);

    matlabbatch{idx}.spm.spatial.realignunwarp.data(1,iRun).scans = cellstr(files_to_realign);
    matlabbatch{idx}.spm.spatial.realignunwarp.data(1,iRun).pmscan = '';

end

matlabbatch{idx}.spm.spatial.realignunwarp.eoptions.quality = 1;
matlabbatch{idx}.spm.spatial.realignunwarp.eoptions.sep = 4;
matlabbatch{idx}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
matlabbatch{idx}.spm.spatial.realignunwarp.eoptions.rtm = 0; % Register to mean
matlabbatch{idx}.spm.spatial.realignunwarp.eoptions.einterp = 2;
matlabbatch{idx}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
matlabbatch{idx}.spm.spatial.realignunwarp.eoptions.weight = {''};

matlabbatch{idx}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
matlabbatch{idx}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
matlabbatch{idx}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
matlabbatch{idx}.spm.spatial.realignunwarp.uweoptions.jm = 0;
matlabbatch{idx}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
matlabbatch{idx}.spm.spatial.realignunwarp.uweoptions.sot = [];
matlabbatch{idx}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
matlabbatch{idx}.spm.spatial.realignunwarp.uweoptions.rem = 1;
matlabbatch{idx}.spm.spatial.realignunwarp.uweoptions.noi = 5;
matlabbatch{idx}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';

matlabbatch{idx}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
matlabbatch{idx}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
matlabbatch{idx}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
matlabbatch{idx}.spm.spatial.realignunwarp.uwroptions.mask = 1;
matlabbatch{idx}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';

end
