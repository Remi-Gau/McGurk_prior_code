function matlabbatch = set_anova_batch(matlabbatch, directory, scans, cdts, cmp)

factor_1 = 'context';
factor_2 = 'percept';

%% set design
directory = fullfile(directory, ['RM_anova_' factor_1 '_' factor_2]);

% enter contrast images for each subject
for iSubj = 1:numel(scans)
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(iSubj).scans = ...
        cellstr(scans{iSubj});
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(iSubj).conds = [...
        1 1
        1 2
        2 1
        2 2];
end


matlabbatch{1}.spm.stats.factorial_design.dir = {directory};

matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'subject';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;

matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = factor_1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;

matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).name = factor_2;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).ancova = 0;

matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1,1}.fmain.fnum = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1,2}.inter.fnums = [2;3];

matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};

matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;


matlabbatch = estimate_grp_level_NIDM(matlabbatch, cmp, cdts, scans);


end