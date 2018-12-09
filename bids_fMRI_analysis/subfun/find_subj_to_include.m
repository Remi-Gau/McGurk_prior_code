function subj_to_include = find_subj_to_include(cdt_ls, cdts, nb_events)

cdt_to_choose = [];
for iCdt = 1:numel(cdts)
    % figure out which are the conditions we want
    cdt_to_choose = [cdt_to_choose, ismember(cdt_ls, cdts{iCdt})']; %#ok<*AGROW>
end

cdt_to_choose = any(cdt_to_choose, 2);

% only include subjects that have more than 10 events in total for both of those
% conditions
subj_to_include = find(all(nb_events(cdt_to_choose,:)));

end