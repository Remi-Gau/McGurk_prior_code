clear
clc

source_dir = 'E:\Archives\Experiment\McGurk\Pilot_5';
subj_ls = dir(source_dir);
subj_ls = cat(1,{subj_ls.name}');
subj_ls([1:2 19:22]) = [];

for iSubj = 1:numel(subj_ls)
    
    sub_id = subj_ls{iSubj};
    subj_dir = fullfile(source_dir, sub_id);
    anat_dir = fullfile(source_dir, sub_id, 'Structural');
    func_dir = fullfile(source_dir, sub_id, 'Nifti_EPI_Despiked');
    
    %%
    func_subdir = dir(func_dir);
    func_subdir(~[func_subdir.isdir]) = [];
    func_subdir(1:2) = [];
    
    for iSubdir = 1:numel(func_subdir)
        
        rp_file = spm_select('FPList', ...
            fullfile(func_dir, func_subdir(iSubdir).name), ...
            '^rp_g.*\.txt$');
        
        rp_output_name = fullfile(...
            func_dir, ...
            ['rp_g' ...
            'sub-' sprintf('%02.0f', str2num(sub_id))...
            '_task-contextmcgurk'...
            '_run-' sprintf('%02.0f', iSubdir)...
            '_bold.txt']);
        
        copyfile(rp_file, rp_output_name);
        
        files_to_convert = spm_select('FPList', ...
            fullfile(func_dir, func_subdir(iSubdir).name), ...
            '^swdaug.*\.img$');
        
        output_name = fullfile(...
            func_dir, ...
            ['swdaug' ...
            'sub-' sprintf('%02.0f', str2num(sub_id))...
            '_task-contextmcgurk'...
            '_run-' sprintf('%02.0f', iSubdir)...
            '_bold.nii']);
        
        matlabbatch = [];
        matlabbatch{1}.spm.util.cat.vols =  cellstr(files_to_convert); %#ok<*SAGROW>
        matlabbatch{1}.spm.util.cat.name = output_name;
        matlabbatch{1}.spm.util.cat.dtype = 0;
        
        %         spm_jobman('run', matlabbatch)
        
        %         gzip(output_name)
        
        
    end
    
    
    %% anat
    clear files_to_convert
    files_to_convert = spm_select('FPList', anat_dir, '^.*sPIEMSI.*\.img$');
    template = 'sPIEMSI';
    if isempty(files_to_convert)
        files_to_convert = spm_select('FPList', anat_dir, '^.*sStruct.*\.img$');
        template = 'sStruct';
        if isempty(files_to_convert)
            files_to_convert = spm_select('FPList', anat_dir, '^.*sVISNEGLECT.*\.img$');
            template = 'sVISNEGLECT';
        end
    end
    
    matlabbatch = [];
    for iImg = 1:size(files_to_convert)
        
        input_file = files_to_convert(iImg,:);
        [filepath, name, ext] = spm_fileparts(input_file);
        idx = strfind(name, template);
        fullname = name(idx:end);
        
        output_name = fullfile(...
            filepath, ...
            [name(1:idx-1) ...
            'sub-' sprintf('%02.0f', str2num(sub_id))...
            '_T1w.nii']);
        
        matlabbatch{iImg}.spm.util.cat.vols =  cellstr(input_file); %#ok<*SAGROW>
        matlabbatch{iImg}.spm.util.cat.name = output_name;
        matlabbatch{iImg}.spm.util.cat.dtype = 0;
    end
    
    if ~isempty(matlabbatch)
        %             spm_jobman('run', matlabbatch)
        
        %             mat_files_to_rename = spm_select('FPList', anat_dir, ['^' fullname '.*\.mat$']);
        %             for iImg = 1:size(mat_files_to_rename)
        %                 copyfile(mat_files_to_rename(iImg,:),...
        %                     strrep(mat_files_to_rename(iImg,:), ...
        %                     fullname, ...
        %                     ['sub-' sprintf('%02.0f', str2num(sub_id)) '_T1w']) );
        %             end
    end
    
    
    
end
