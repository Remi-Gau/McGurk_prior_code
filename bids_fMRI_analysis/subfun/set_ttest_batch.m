function matlabbatch = set_ttest_batch(matlabbatch, directory, scans, cdts, cmp)


%% set design

% for ttest
if numel(cdts)==1
    directory = fullfile(directory, ['ttest_' cdts{1}]);
    for iSubj = 1:numel(scans)
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{iSubj,1} = ...
            scans{iSubj};
    end

% for paired ttest
elseif numel(cdts)==2
    directory = fullfile(directory, ['ttest-paired_' cdts{1} '_vs_' cdts{1}]);
    % enter contrast image pairs for each subject
    for iSubj = 1:numel(scans)
        matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(iSubj).scans = ...
            cellstr(scans{iSubj});
    end
end

matlabbatch{1}.spm.stats.factorial_design.dir = {directory};
matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = ...
    struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = ...
    struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;


matlabbatch = estimate_grp_level_NIDM(matlabbatch, cmp, cdts, scans);


end

