function [opt] = get_metadata_func(BIDS, subjects, task)
% get_metadata_func(BIDS, subjects)

subjs_ls = spm_BIDS(BIDS, 'subjects');

hdr = spm_vol(subjects{1}.func{1, 1});

opt.nb_slices = hdr(1).dim(3);

opt.epi_res = diag(hdr(1).mat);
opt.epi_res(end) = [];
opt.epi_res = abs(min(opt.epi_res));
opt.norm_res = [2 opt.epi_res];
% opt.norm_res = [2 -3];


metadata = spm_BIDS(BIDS, 'metadata', 'sub', subjs_ls{1}, 'type', 'bold', ...
    'task', task, 'run', '01');

opt.nb_slices = numel(metadata.SliceTiming);
opt.TR = metadata.RepetitionTime;
opt.TA = opt.TR - (opt.TR/opt.nb_slices);
opt.acquisition_order = metadata.SliceTiming*1000;
opt.slice_reference = [1 floor(opt.nb_slices/2)];
end

