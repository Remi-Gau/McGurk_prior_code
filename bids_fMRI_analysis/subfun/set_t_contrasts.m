function matlabbatch = set_t_contrasts(analysis_dir)
% set batch to estimate the following contrasts (> bseline)
% (1) auditory responses for congruent non-McGurk–MacDonald stimuli (i.e. CON),
% (2) auditory responses for incongruent non-McGurk–MacDonald stimuli (i.e. INC),
% (3) auditory responses for McGurk–MacDonald stimuli in congruent blocks (AuditoryCon),
% (4) fused responses for McGurk–MacDonald stimuli in congruent blocks (FusedCon),
% (5) auditory responses for McGurk– MacDonald stimuli in incongruent blocks (AuditoryInc),
% (6) fused ressponses for McGurk–MacDonald stimuli in incongruent blocks (FusedInc),
% (7) congruent blocks (i.e. CONContext)
% (8) incongruent blocks (i.e. INCContext).
% (9) all events > baseline
% (10) all events > baseline

% cdt_ls = {...
%     'mcgurk_con_aud', ...
%     'mcgurk_con_fus', ...
%     'mcgurk_con_other', ...
%     'mcgurk_inc_aud', ...
%     'mcgurk_inc_fus', ...
%     'mcgurk_inc_other', ...
%     'con_aud_vis', ...
%     'con_other', ...
%     'inc_aud', ...
%     'inc_vis', ...
%     'inc_other', ...
%     'missed'};

% blocks_ls = {'con_block', 'inc_block'};

cdt_ls = {...
    ' con_aud_vis', ...
    ' inc_aud', ...
    ' mcgurk_con_aud', ...
    ' mcgurk_con_fus', ...
    ' mcgurk_inc_aud', ...
    ' mcgurk_inc_fus', ...
    ' con_block', ...
    ' inc_block'};

load(fullfile(analysis_dir, 'SPM.mat'), 'SPM');

matlabbatch{1}.spm.stats.con.spmmat{1} = fullfile(analysis_dir, 'SPM.mat');
matlabbatch{1}.spm.stats.con.delete = 1;

for iCdt = 1:numel(cdt_ls)
    
    cdt_name = cdt_ls{iCdt};
    
    weight_vec = init_weight_vector(SPM);
    
    % add the suffix '*bf(1)' to look for regressors that are convolved
    % with canonical HRF
    idx = strfind(SPM.xX.name', [cdt_name '*bf(1)']);
    idx = ~cellfun('isempty', idx); %#ok<STRCL1>
    
    % in case we are dealing with a block regressors that was added
    % manually and not convolved automatically by SPM
    idx = search_non_convolved_reg(idx, cdt_name, SPM);
    
    weight_vec(idx) = 1;
    
    [weight_vec, cdt_name] = warning_dummy_contrast(weight_vec, cdt_name);
    
    matlabbatch = set_cdt_contrast_batch(matlabbatch, cdt_name, weight_vec, iCdt);
    
end

%% we do the same for [all events > baseline]
all_events_ls = {...
    ' mcgurk_con_aud', ...
    ' mcgurk_con_fus', ...
    ' mcgurk_con_other', ...
    ' mcgurk_inc_aud', ...
    ' mcgurk_inc_fus', ...
    ' mcgurk_inc_other', ...
    ' con_aud_vis', ...
    ' con_other', ...
    ' inc_aud', ...
    ' inc_vis', ...
    ' inc_other', ...
    ' missed'};

weight_vec = init_weight_vector(SPM);

for iCdt = 1:numel(all_events_ls)
    idx = strfind(SPM.xX.name', [all_events_ls{iCdt} '*bf(1)']);
    idx = ~cellfun('isempty', idx); %#ok<STRCL1>
    weight_vec(idx) = sum(idx);
end

[weight_vec, cdt_name] = warning_dummy_contrast(weight_vec, 'all_events');

weight_vec = norm_weight_vector(weight_vec);

matlabbatch = set_cdt_contrast_batch(matlabbatch, cdt_name, weight_vec, numel(cdt_ls)+1);


%% we do the same for [all blocks > baseline]
all_blocks_ls = {...
    ' con_block', ...
    ' inc_block'};

weight_vec = init_weight_vector(SPM);

for iCdt = 1:numel(all_blocks_ls)
    cdt_name = all_blocks_ls{iCdt};
    idx = strfind(SPM.xX.name', [cdt_name '*bf(1)']);
    idx = ~cellfun('isempty', idx); %#ok<STRCL1>
    idx = search_non_convolved_reg(idx, cdt_name, SPM);
    weight_vec(idx) = sum(idx);
end

[weight_vec, cdt_name] = warning_dummy_contrast(weight_vec, 'all_blocks');

matlabbatch = set_cdt_contrast_batch(matlabbatch, cdt_name, weight_vec, numel(cdt_ls)+2);


end

function weight_vec = init_weight_vector(SPM)
weight_vec = zeros(size(SPM.xX.X,2),1);
end

function idx = search_non_convolved_reg(idx, cdt_name, SPM)
if sum(idx)==0
    warning('No regressor was found for condition %s. Trying with %s', ...
        [cdt_name '*bf(1)'], cdt_name)
    idx = strfind(SPM.xX.name', cdt_name);
    idx = ~cellfun('isempty', idx); %#ok<STRCL1>
end
end

function [weight_vec, cdt_name] = warning_dummy_contrast(weight_vec, cdt_name)

if sum(weight_vec)>0
    % we normalize by the number of sessions this condition was present in.
    weight_vec = norm_weight_vector(weight_vec);
else
    warning('no regressor was found for condition %s, creating a dummy contrast', ...
        cdt_name)
    cdt_name = 'dummy_contrast';
    weight_vec = zeros(size(weight_vec));
    weight_vec(end) = 1;
end

end

function weight_vec = norm_weight_vector(weight_vec)
weight_vec =  weight_vec/sum(weight_vec);
end

function matlabbatch = set_cdt_contrast_batch(matlabbatch, cdt_name, weight_vec, iCdt)
matlabbatch{1}.spm.stats.con.consess{iCdt}.tcon.name = cdt_name;
matlabbatch{1}.spm.stats.con.consess{iCdt}.tcon.weights = weight_vec;
matlabbatch{1}.spm.stats.con.consess{iCdt}.tcon.sessrep = 'none';
end