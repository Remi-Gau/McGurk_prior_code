clear

clc

OUTPUT_DIR = 'D:\Dropbox\BIDS\McGurk\derivatives\spm8_artrepair';
subj_ls = dir(OUTPUT_DIR);

for iSubj=1:numel(subj_ls)
    
    subj_dir = fullfile(OUTPUT_DIR, subj_ls(iSubj).name, 'func');
    
    img_ls = spm_select('FPList', fullfile(subj_dir), '^.*run-.*\.nii$');
    
    for iRun=1:size(img_ls,1)
        
        mkdir(fullfile(subj_dir,['run' num2str(iRun)]))
        
        files_to_move = spm_select('FPList', fullfile(subj_dir), ...
            ['^.*run-.*' num2str(iRun) '.*$'] )
        
        for iFile = 1:size(files_to_move,1)
            movefile(files_to_move(iFile,:), ...
            fullfile(subj_dir,['run' num2str(iRun)]) )
        end
    end
    
end