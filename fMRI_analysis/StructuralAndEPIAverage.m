%%
clc
clear

% Subject's Identity
SubjectsList = [1 13 14 15 24 32 41 48 61 66 69 73 74 82 98];

%  Folders definitions
StartFolder = pwd;



%%
for i=1:size(SubjectsList, 2)
    
    SubjID=num2str(SubjectsList(i));
    
    SubjectStructuralFolder = strcat(pwd, filesep, SubjID, filesep, 'Structural', filesep);
    SubjectMeanEPIFolder = strcat(pwd, filesep, SubjID, filesep, 'Nifti_EPI_Despiked', filesep, '1');
    
    
    cd(SubjectStructuralFolder)
    
    Structural = dir('ws*.img');
                     
	StructuralList{i,1} = strcat(pwd, filesep, Structural(1).name);
    
    
    cd(SubjectMeanEPIFolder)
    
    MeanEPI = dir('wmean*.img');
                     
	MeanEPIList{i,1} = strcat(pwd, filesep, MeanEPI(1).name);
    
    
    
    cd(StartFolder)
    
end

clear MeanEPI Structural


%%
imgsMat = char(StructuralList);

% spm_vol: read hdr information from the images. 
imgsInfo = spm_vol(imgsMat);

% spm_read_vols: using the header information given by spm_vol reads in entire image volumes
volumes = spm_read_vols(imgsInfo);

MeanStructural = mean(volumes,4);

% spm_write_vol: writes an image volume to disk
newImgInfo = imgsInfo(1);

% Change the name in the header
newImgInfo.fname = strcat(pwd, filesep, 'MeanStructural.nii'); 'volume_created.nii';
newImgInfo.private.dat.fname = newImgInfo.fname;

spm_write_vol(newImgInfo, MeanStructural);



%%
imgsMat = char(MeanEPIList);

% spm_vol: read hdr information from the images. 
imgsInfo = spm_vol(imgsMat);

% spm_read_vols: using the header information given by spm_vol reads in entire image volumes
volumes = spm_read_vols(imgsInfo);

MeanEPI = mean(volumes,4);

% spm_write_vol: writes an image volume to disk
newImgInfo = imgsInfo(1);

% Change the name in the header
newImgInfo.fname = strcat(pwd, filesep, 'MeanEPI.nii');
newImgInfo.private.dat.fname = newImgInfo.fname;

spm_write_vol(newImgInfo, MeanEPI);

return

%%

imgsMat{1,1} = strcat(pwd, filesep, 'mask.hdr');
imgsMat{2,1} = strcat(pwd, filesep, 'MeanStructural.nii')

imgsInfo = spm_vol(char(imgsMat));

volumes = spm_read_vols(imgsInfo);

A = volumes(:,:,:,1);

Test = volumes(:,:,:,2);

Test(A==0)=Test(A==0)*0.5;

% spm_write_vol: writes an image volume to disk
newImgInfo = imgsInfo(2);

% Change the name in the header
newImgInfo.fname = strcat(pwd, filesep, 'MeanStructuralMasked.nii');
newImgInfo.private.dat.fname = newImgInfo.fname;

spm_write_vol(newImgInfo, Test);
