function matlabbatch = set_extra_regress_batch(matlabbatch, idx, irun, opt, cfg, blocks, RT_regressors_col)

% Inputs the reaction time parametric modulator regressors
if cfg.RT_correction
    for iRT_reg = 1:size(RT_regressors_col{irun},2)
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).regress(1,end+1).name = ...
            ['RT_par_mod-' num2str(iRT_reg)];
        matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).regress(1,end).val = ...
            RT_regressors_col{irun}(:,iRT_reg);
    end
end

% deal with the block regressors
if ~strcmp(cfg.block_type, 'none')
    
    onset_delay = get_onset_delay(cfg);
    
    block_duration = str2double(cfg.block_type(1:3));
    
    % get the onsets and duration of each block (nerge consecutie blocks
    % if duration==100)
    block_parameters = get_block_parameters(blocks, block_duration, irun);
    
    % if we have regular blocks we enter them as normal conditions to be
    % convolved later with the HRF  by the SPM machinery
    if strcmp(cfg.block_type(end), 's')
        
        for iBlock = 1:size(blocks,2)
            
            matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end+1).name = ...
                blocks(irun,iBlock).name;
            matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).onset = ...
                block_parameters(iBlock).onsets_1 + onset_delay ;
            matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).duration = ...
                block_parameters(iBlock).duration;
            
            matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).tmod = 0;
            matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).cond(1,end).pmod = ...
                struct('name',{},'param',{}, 'poly', {});
            
        end
        
        % In this case we have blocks that rise exponentially so we define them manually
    elseif strcmp(cfg.block_type(end), 'e')
        
        nb_vols = size(matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).scans,1);
        block_parameters = create_exp_reg(opt, cfg, nb_vols, block_parameters);
        
        for iBlock = 1:size(blocks,2)
            
            matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).regress(1,end+1).name = ...
                blocks(irun,iBlock).name;
            
            matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).regress(1,end).val = ...
                block_parameters(iBlock).exp_reg;
            
        end
        
    end
    
end

% if isfield(matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun), 'regress')
%     matlabbatch{idx}.spm.stats.fmri_spec.sess(1,irun).regress = ...
%     struct('name', '', 'name', []);
% end

end

function block_parameters = get_block_parameters(blocks, block_duration, irun)

for iBlock =  1:size(blocks,2)
    
    block_parameters(iBlock).onsets_1 = blocks(irun,iBlock).onsets_1; %#ok<*AGROW>
    block_parameters(iBlock).onsets_2 = blocks(irun,iBlock).onsets_2;
    block_parameters(iBlock).duration = repmat(block_duration, ...
        size(blocks(irun,iBlock).onsets_1));
    
    % If we want the block duration to be equal to 100 then we need to
    % merge 2 consecutive blocks of the same condition
    if block_duration==100
        block_idx = find(diff(block_parameters(iBlock).onsets_1)<125);
        block_parameters(iBlock).onsets_1(block_idx+1) = [];
        block_parameters(iBlock).onsets_2(block_idx+1) = [];
        block_parameters(iBlock).duration(block_idx) = 200;
        block_parameters(iBlock).duration(block_idx+1) = [];
    end
end

end

