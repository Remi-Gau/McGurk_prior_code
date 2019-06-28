function [opt, all_GLMs] = set_all_GLMS(opt)
% defines some more options for setting up GLMs and gets all possible
% combinations of GLMs to run

opt.despiked = [0 1];
opt.GLM_denoise = [0 1 2 3]; % GLMdenoise OFF, 1, 2 or 3 (original study was OFF)

opt.HPF = [Inf 100 200]; % HPF none, 100, 200 (original study was 200)
opt.stim_onset = {'A' 'V' 'B'}; % stim onset on audio, on video, in between
opt.RT_correction = [0 1]; % RT correction (original study had both)
opt.block_type = {'none' '083s' '083e' '100s' '100e'}; % % Blocks of none, Exp83, Exp100, square100 (original study was Exp100)
opt.time_der = [0 1]; % time derivative (used or not ; original study was used)
opt.mvt = [0 1]; % mvt noise regressors (ON or OFF ; original study was ON)
opt.concat = [0 1]; % concatenate session (ON or OFF ; original study was OFF)

% list all possible GLMs to run
sets{1} = 1:numel(opt.despiked); %#ok<*NASGU>
sets{end+1} = 1:opt.slice_reference;
sets{end+1} = 1:opt.norm_res;
sets{end+1} = 1;%:numel(opt.GLM_denoise);
sets{end+1} = numel(opt.HPF);
sets{end+1} = 3; %1:numel(opt.stim_onset);
sets{end+1} = 1:numel(opt.RT_correction);
sets{end+1} = [1 numel(opt.block_type)]; %1:numel(opt.block_type);
sets{end+1} = numel(opt.time_der);
sets{end+1} = numel(opt.mvt);
sets{end+1} = 1; %1:numel(opt.concat);

% comment the lines above and uncomment the following if you only want to
% run the pipelines for the published results 
% sets{1} = 1;
% sets{end+1} = 2; 
% sets{end+1} = 1;
% sets{end+1} = 1;
% sets{end+1} = 3;
% sets{end+1} = 3;
% sets{end+1} = 1;
% sets{end+1} = 5;
% sets{end+1} = 2;
% sets{end+1} = 2;
% sets{end+1} = 1;

[a, b, c, d, e, f, g, h, i, j, k] = ndgrid(sets{:}); clear sets
all_GLMs = [a(:), b(:), c(:), d(:), e(:), f(:), g(:), h(:), i(:), j(:), k(:)];

end