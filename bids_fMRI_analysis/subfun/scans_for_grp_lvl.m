function scans = scans_for_grp_lvl(contrast_ls, ctrsts, contrasts_file_ls, subj_to_include)

    % figure out which are the contrasts we want
    ctrst_to_choose = [];
    for iCtrsts = 1:numel(ctrsts)
        ctrst_to_choose = [ctrst_to_choose ...
            find(ismember(contrast_ls, ctrsts{iCtrsts}))]; %#ok<*AGROW>
    end
    
    for iSubj = 1:numel(subj_to_include)
        scans{iSubj} = cat(1,...
            contrasts_file_ls(subj_to_include(iSubj)).con_file{ctrst_to_choose,:}); 
    end
    
end