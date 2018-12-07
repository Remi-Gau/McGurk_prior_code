% runs group level on the McGurk experiment and export the results corresponding to those 
% published in the NIDM format

% t-test
% all events > baseline
% all blocks > baseline

% paired t-test
% block con > block inc ; block con < block inc ; block con + block inc > 0
% con_aud_vis*bf(1) > inc_aud*bf(1) ; con_aud_vis*bf(1) < inc_aud*bf(1)

% 2 X 2 ANOVA
% 

clear
clc


%% Set options, matlab path
DATA_DIR = 'C:\Users\Remi\Documents\McGurk';
% DATA_DIR = '/data';

% data set
BIDS_DIR = fullfile(DATA_DIR, 'rawdata');

OUTPUT_DIR = 'C:\Users\Remi\Documents\McGurk\derivatives';
% OUTPUT_DIR = '/output';
OUTPUT_DIR = fullfile(OUTPUT_DIR, 'spm_artrepair', 'group');

CODE_DIR = 'C:\Users\Remi\Documents\McGurk\code';
% CODE_DIR = '/code/mcgurk/';

% set path
addpath(fullfile(CODE_DIR,'bids_fMRI_analysis', 'subfun'));


%% get data set info
BIDS = spm_BIDS(BIDS_DIR);
subj_ls = spm_BIDS(BIDS, 'subjects');
nb_subj = numel(subj_ls);

% set up all the possible of combinations of GLM possible
opt.norm_res = [2 3];
opt.slice_reference = [1 21];
[opt, all_GLMs] = set_all_GLMS(opt);


%%
for iGLM = 1:size(all_GLMs) 
    
        % get configuration for this GLM 
        cfg = get_configuration(all_GLMs, opt, iGLM); 

        analysis_dir = name_analysis_dir(cfg);
        analysis_dir = fullfile (OUTPUT_DIR, analysis_dir );
        mkdir(analysis_dir)
        
        cdt_ls = {...
            ' con_aud_vis*bf(1)', ...
            ' inc_aud*bf(1)', ...
            'mcgurk_con_aud*bf(1)', ...
            'mcgurk_con_fus*bf(1)', ...
            'mcgurk_inc_aud*bf(1)', ...
            'mcgurk_inc_fus*bf(1)', ...
            'con*bf(1)', ...
            'inc*bf(1)'};
        
    
% ttest
matlabbatch{1}.spm.stats.factorial_design.cov = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {[]};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{1}.spm.stats.factorial_design.dir = {''};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {''};


%% paired ttest
matlabbatch{1}.spm.stats.factorial_design.cov = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {[]};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(1).scans = {''};
matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(2).scans = {''};
matlabbatch{1}.spm.stats.factorial_design.dir = {''};


%% 2x2 ANOVA
matlabbatch{1}.spm.stats.factorial_design.dir = {''};
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'Subject';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = 'Context';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).name = 'Percept';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(1).scans = {''};
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(1).conds = [1 1
                                                                                  1 2
                                                                                  2 1
                                                                                  2 2];
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(2).scans = {''};
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(2).conds = [1 1
                                                                                  1 2
                                                                                  2 1
                                                                                  2 2];

matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.inter.fnums = [2
                                                                                  3];
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat = {''};
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    
end
