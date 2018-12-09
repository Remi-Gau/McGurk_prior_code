% runs group level on the McGurk experiment and export the results corresponding to those
% published in the NIDM format

% t-test
% all events > baseline
% all blocks > baseline

% paired t-test
% block con > block inc ; block con < block inc ; block con + block inc > 0
% con_aud_vis*bf(1) > inc_aud*bf(1) ; con_aud_vis*bf(1) < inc_aud*bf(1)

% 2 X 2 ANOVA


clear
clc

spm('defaults','FMRI')


%% Set options, matlab path
DATA_DIR = 'C:\Users\Remi\Documents\McGurk';
% DATA_DIR = '/data';

% data set
BIDS_DIR = fullfile(DATA_DIR, 'rawdata');

OUTPUT_DIR = 'D:\BIDS\McGurk\derivatives';
% OUTPUT_DIR = '/output';
OUTPUT_DIR = fullfile(OUTPUT_DIR, 'spm12_artrepair', 'group');

CODE_DIR = 'C:\Users\Remi\Documents\McGurk\code';
% CODE_DIR = '/code/mcgurk/';

% set path
addpath(fullfile(CODE_DIR,'bids_fMRI_analysis', 'subfun'));


%% get data set info
BIDS = spm_BIDS(BIDS_DIR);
subj_ls = spm_BIDS(BIDS, 'subjects');
nb_subj = 4;%numel(subj_ls);

% set up all the possible of combinations of GLM possible
opt.norm_res = [2 3];
opt.slice_reference = [1 21];
[opt, all_GLMs] = set_all_GLMS(opt);


%%
cdt_ls = {...
    'mcgurk_con_aud', ...
    'mcgurk_con_fus', ...
    'mcgurk_con_other', ...
    'mcgurk_inc_aud', ...
    'mcgurk_inc_fus', ...
    'mcgurk_inc_other', ...
    'con_aud_vis', ...
    'con_other', ...
    'inc_aud', ...
    'inc_vis', ...
    'inc_other', ...
    'missed', ...
    'con_block', ...
    'inc_block'};

contrast_ls = {...
    ' con_aud_vis', ...
    ' inc_aud', ...
    ' mcgurk_con_aud', ...
    ' mcgurk_con_fus', ...
    ' mcgurk_inc_aud', ...
    ' mcgurk_inc_fus', ...
    ' con_block', ...
    ' inc_block', ...
    'all_events', ...
    'all_blocks'};

%%
for iGLM = 1:size(all_GLMs)
    
    %% get configuration for this GLM
    cfg = get_configuration(all_GLMs, opt, iGLM);
    
    % set output dir for this GLM configutation
    analysis_dir = name_analysis_dir(cfg);
    grp_lvl_dir = fullfile (OUTPUT_DIR, analysis_dir );
    mkdir(grp_lvl_dir)
    
    contrasts_file_ls = struct('con_name', {}, 'con_file', {});
    
    %%
    for isubj = 1:nb_subj

        subj_lvl_dir = fullfile ( ...
            OUTPUT_DIR, '..', ...
            ['sub-' subj_ls{isubj}], analysis_dir);
        
        load(fullfile(subj_lvl_dir, 'SPM.mat'))
        
        %% Count how many events for each condition / session / subject
        for iCdt = 1:numel(cdt_ls)
            
            nb_events{iCdt, isubj} = []; %#ok<SAGROW>
            
            for iSess = 1:numel(SPM.Sess)
                
                cdt_in_sess = cat(1,SPM.Sess(iSess).U(:).name);
                cdt_idx = contains(cdt_in_sess, cdt_ls{iCdt});
                
                if any(cdt_idx)
                    nb_event_this_sess = numel(SPM.Sess(iSess).U(cdt_idx).ons);
                else
                    nb_event_this_sess = 0;
                end
                
                nb_events{iCdt, isubj}(end+1) = nb_event_this_sess;
                
            end
        end
        
        %% Stores names of the contrast images
        for iCtrst = 1:numel(contrast_ls)
            
            contrasts_file_ls(isubj).con_name{iCtrst,1} = ...
                SPM.xCon(iCtrst).name;
            
            contrasts_file_ls(isubj).con_file{iCtrst,1} = ...
                fullfile(subj_lvl_dir, SPM.xCon(iCtrst).Vcon.fname);
            
        end
        
    end
    
    nb_events = cellfun(@sum, nb_events)>10;

    %% BLOCKS
    if ~strcmp(cfg.block_type, 'none')
        
        subj_to_include = 1:nb_subj;
        
        % paired ttest con_blocks VS inc_blocks
        ctrsts = {' con_block', ' inc_block'};

        scans = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include);

        matlabbatch = [];
        matlabbatch = set_ttest_batch(matlabbatch, grp_lvl_dir, scans, ...
            {'CON_block', 'INC_block'}, ...
            {'>','<','+>'});

        spm_jobman('run', matlabbatch)
        
        
        % ttest for all blocks
        ctrsts = {'all_blocks'};
        
        scans = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include);

        matlabbatch = [];
        matlabbatch = set_ttest_batch(matlabbatch, grp_lvl_dir, scans, ...
            {'all_blocks'}, ...
            {'>','<'});

        spm_jobman('run', matlabbatch)
        
    end
    
    
    %% EVENTS
    % paired ttest con_aud VS inc_aud
    cdts = {'con_aud_vis', 'inc_aud'};
    ctrsts = {' con_aud_vis', ' inc_aud'};
    
    subj_to_include = find_subj_to_include(cdt_ls, cdts, nb_events);
    scans = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include);

    matlabbatch = [];
    matlabbatch = set_ttest_batch(matlabbatch, grp_lvl_dir, scans, ...
        {'CON_aud', 'INC_aud'}, ...
        {'>','<','+>'});
    
    spm_jobman('run', matlabbatch)
    
    
    % ttest for all events
    ctrsts = {'all_events'};
    subj_to_include = 1:nb_subj;

    scans = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include);

    matlabbatch = [];
    matlabbatch = set_ttest_batch(matlabbatch, grp_lvl_dir, scans, ...
            {'all_events'}, ...
            {'>','<'});
    
    spm_jobman('run', matlabbatch)
    
    
    % 2x2 ANOVA
    cdts = {...
        'mcgurk_con_aud', ...
        'mcgurk_con_fus', ...
        'mcgurk_inc_aud', ...
        'mcgurk_inc_fus'};
    
    ctrsts = {
        ' mcgurk_con_aud', ...
        ' mcgurk_con_fus', ...
        ' mcgurk_inc_aud', ...
        ' mcgurk_inc_fus'};
    
    subj_to_include = find_subj_to_include(cdt_ls, cdts, nb_events);
    scans = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include);
    
    matlabbatch = [];
    matlabbatch = set_anova_batch(matlabbatch, grp_lvl_dir, scans, cdts, ...
        {...
        {[1 2] '>' [3 4] 'context:CON>INC'};...
        {[3 4] '>' [1 2] 'context:INC>CON'};...
        {[1 3] '>' [2 4] 'percept:AUD>FUS'};...
        {[2 4] '>' [1 3] 'percept:FUS>AUD'};...
        {[1 4] '>' [2 3] 'interaction_1'};...
        {[2 3] '>' [1 4] 'interaction_2'}} );
    
    spm_jobman('run', matlabbatch)

    
    
end
