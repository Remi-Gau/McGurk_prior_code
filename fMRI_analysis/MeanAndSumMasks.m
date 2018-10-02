%%
clc
clear

% Subject's Identity
SubjectsList = [1 13 14 15 24 32 41 48 61 66 69 73 74 82 98];

%  Folders definitions
StartFolder = pwd;

Analysis = 'Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked';


%%
for i=1:size(SubjectsList, 2)
    
    SubjID=num2str(SubjectsList(i));
                     
    MaskList{i,1} = fullfile(StartFolder, SubjID, Analysis, 'mask.img');   
    
    cd(StartFolder)    
end

%%
imgsMat = char(MaskList);

% spm_vol: read hdr information from the images. 
imgsInfo = spm_vol(imgsMat);

% spm_read_vols: using the header information given by spm_vol reads in entire image volumes
volumes = spm_read_vols(imgsInfo);

MeanMask = mean(volumes,4);

SumMask = sum(volumes,4);


% spm_write_vol: writes an image volume to disk
newImgInfo = imgsInfo(1);

% Change the name in the header
newImgInfo.fname = strcat(pwd, filesep, 'MeanMask.nii');
newImgInfo.private.dat.fname = newImgInfo.fname;

spm_write_vol(newImgInfo, MeanMask);


% spm_write_vol: writes an image volume to disk
newImgInfo = imgsInfo(1);

% Change the name in the header
newImgInfo.fname = strcat(pwd, filesep, 'SumMask.nii');
newImgInfo.private.dat.fname = newImgInfo.fname;

spm_write_vol(newImgInfo, SumMask);



