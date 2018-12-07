function [cdt, blocks]= get_cdt_onsets(cdt, blocks, onsets, iRun)
% Defines the different conditions we will use in the GLMs with their onset and durations 

minimum_RT = 0.8;
maximum_RT = 990;
nb_stim_per_block = 8;

%% classify responses
stim_file = char(onsets{iRun}.stim_file);
responses = char(onsets{iRun}.response);
responses = responses(:,1);

% classify missed responses
is_missed = any([...
    onsets{iRun}.response_time < minimum_RT ...
    onsets{iRun}.response_time > maximum_RT], 2);

% classify auditory and visual responses
is_vis = strcmp(cellstr(stim_file(:,3)), cellstr(responses));
is_aud = strcmp(cellstr(stim_file(:,8)), cellstr(responses));

% classify fused responses
is_KP =  strcmp(cellstr(stim_file(:,[3 8])), 'KP'); % K P mcgurk stim
is_GB =  strcmp(cellstr(stim_file(:,[3 8])), 'GB'); % G B mcgurk stim

is_fus = false(size(is_aud));
is_fus(is_KP) = strcmp(cellstr(responses(is_KP)), 'T');
is_fus(is_GB) = strcmp(cellstr(responses(is_GB)), 'D');

% classify all other responses as others
is_other = true(size(is_aud));
is_other(is_vis) = 0;
is_other(is_aud) = 0;
is_other(is_fus) = 0;

% make sure that no missed response is labelled as something else
is_vis(is_missed) = 0;
is_aud(is_missed) = 0;
is_fus(is_missed) = 0;
is_other(is_missed) = 0;

% check that some responses are not labelled twice
if any(sum([is_vis, is_fus], 2) == 2) || any(sum([is_aud, is_fus], 2) == 2)
    error('some stimuli seem to be labelled twice')
end

% check that we did not forget to label any stimuli
if sum(any([is_vis, is_aud, is_fus, is_other, is_missed], 2)) ~= size(stim_file,1)
    error('we missed one or more stimuli')
end


%% classify stimuli
trial_type = char(onsets{iRun}.trial_type);

is_con = strcmp(cellstr(trial_type),'Congruent');
is_inc = strcmp(cellstr(trial_type),'Incongruent');
is_mcgurk_con = strcmp(cellstr(trial_type),'McGurk in congruent');
is_mcgurk_inc = strcmp(cellstr(trial_type),'McGurk in Incongruent');


%% define conditions
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
    'missed'};

cdt_logical{1} = all(  [is_aud    is_mcgurk_con] ,2);
cdt_logical{2} = all(  [is_fus    is_mcgurk_con], 2);
cdt_logical{3} = all(  [is_other  is_mcgurk_con], 2);
cdt_logical{4} = all(  [is_aud    is_mcgurk_inc], 2);
cdt_logical{5} = all(  [is_fus    is_mcgurk_inc], 2);
cdt_logical{6} = all(  [is_other  is_mcgurk_inc], 2);
cdt_logical{7} = all(  [is_aud    is_con], 2);
cdt_logical{8} = all(  [is_other  is_con], 2);
cdt_logical{9} = all(  [is_aud    is_inc], 2);
cdt_logical{10} = all( [is_vis    is_inc], 2);
cdt_logical{11} = all( [is_other  is_inc], 2);
cdt_logical{12} = is_missed;

for iCdt = 1:numel(cdt_ls)
    cdt(iRun,iCdt).name = cdt_ls{iCdt};
    cdt(iRun,iCdt).onsets = onsets{iRun}.onset(cdt_logical{iCdt});
    cdt(iRun,iCdt).RT = onsets{iRun}.response_time(cdt_logical{iCdt});
end


%% define blocks
blocks(iRun,1).name = 'con_block';

% onset of all congruent stim
onsets_con = onsets{iRun}.onset(is_con);
% onset of the the first congruent stim of each block
blocks(iRun,1).onsets_1 = onsets_con(1:nb_stim_per_block:end); 
% onset of the the second congruent stim of each block
blocks(iRun,1).onsets_2 = onsets_con(2:nb_stim_per_block:end);



blocks(iRun,2).name = 'inc_block';
% onset of all incongruent stim
onsets_inc = onsets{iRun}.onset(is_inc);
% onset of the the first incongruent stim of each block
blocks(iRun,2).onsets_1 = onsets_inc(1:nb_stim_per_block:end); 
% onset of the the second incongruent stim of each block
blocks(iRun,2).onsets_2 = onsets_inc(2:nb_stim_per_block:end);

end

