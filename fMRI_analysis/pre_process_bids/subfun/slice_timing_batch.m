function matlabbatch = slice_timing_batch(matlabbatch,idx,input_files,opt)

nb_runs = numel(input_files);

files_to_slicetime = [];

for iRun = 1:nb_runs
    [filepath, name, ext] = spm_fileparts(input_files{iRun,1});
    
    files_to_slicetime = cat(1, files_to_slicetime, ...
        spm_select('FPList',filepath,['^ug' name '_00.*' ext '*']));

    matlabbatch{idx}.spm.temporal.st.scans{1,iRun} = cellstr(files_to_slicetime);
    
end

matlabbatch{idx}.spm.temporal.st.nslices = opt.nb_slices;
matlabbatch{idx}.spm.temporal.st.tr = opt.TR;
matlabbatch{idx}.spm.temporal.st.ta = opt.TA;
matlabbatch{idx}.spm.temporal.st.so = opt.acquisition_order ;
matlabbatch{idx}.spm.temporal.st.refslice = opt.slice_reference;
matlabbatch{idx}.spm.temporal.st.prefix = ['a_' sprintf('%02.0f',opt.slice_reference)];

end