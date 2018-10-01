clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

cd ..
StartFolder = pwd;

Design = 'Percent_Fused_VS_Block';

SubjectsList = [1 13 14 15 24 28 32 41 48 66 69 73 74 82 98 61];

A={};
for i=1:length(SubjectsList)
A{end+1,1} = fullfile(StartFolder, num2str(SubjectsList(i)), 'Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', ...
            'con_0013.img,1');
A{end+1,1} = fullfile(StartFolder, num2str(SubjectsList(i)), 'Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', ...
            'con_0014.img,1');       
end

ScansList = char(A)


%%
cd SecondLevel
mkdir Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked;
load('GroupResponsesNoMiss.mat')

CorrelationVectors = [squeeze(GroupResponsesNoMiss(3,3,:)) squeeze(GroupResponsesNoMiss(3,4,:))];


%%
cd Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked;
mkdir Correlation
cd Correlation
mkdir Percent_Fused_VS_Block
cd Percent_Fused_VS_Block

GroupAnalysisFolder = pwd;


%%
matlabbatch{1,1}.spm.stats.factorial_design.dir{1,1} = GroupAnalysisFolder;

matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,1).name = 'Subject';
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,1).dept = 0;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,1).variance = 0;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,1).gmsca = 0;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,1).ancova = 0;

matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,2).name = 'Context';
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,2).dept = 1;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,2).variance = 1;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,2).gmsca = 0;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,2).ancova = 0;


for i=1:length(SubjectsList)
    
    A = cellstr(ScansList(1+4*(i-1):4+4*(i-1),:));
    for j=1:4
        A{j,1}(A{j,1}==' ') = [];
    end
    
    matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).scans = A;
    matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).conds = [1 1 ; 1 2];
end

matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.maininters{1,1}.fmain.fnum = 1;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.maininters{1,2}.inter.fnums = [2;3];

matlabbatch{1,1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1,1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1,1}.spm.stats.factorial_design.masking.em = {''};

matlabbatch{1,1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1,1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1,1}.spm.stats.factorial_design.globalm.glonorm = 1;


% Estimate model
%matlabbatch{1,end+1}={};
%matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = strcat(GroupAnalysisFolder, filesep, (ListOfContrastNames), filesep, 'SPM.mat');     %set the spm file to be estimated
%matlabbatch{1,end}.spm.stats.fmri_est.method.Classical = 1;

save (strcat('Correlation_MultiReg_', (Design) , '_jobs'), 'matlabbatch');

spm_jobman('run', matlabbatch)


% Load the right SPM.mat

load SPM.mat

c = [ 0 1 ];
cname = '+ve correlation';
SPM.xCon = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ 0 -1 ];
cname = '-ve correlation';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);


% Evaluate

spm_contrasts(SPM);

clear A ContrastsFilesList CorrelationVectorsTemp ContrastsTemp YTemp SubjectsListTemp



%%

% Make a masked image of the subject structural
imgsMat{1,1} = strcat(pwd, filesep, 'mask.hdr');
imgsMat{2,1} = strcat('/home/SHARED/Experiment/IRMf/Pilot_5', filesep, 'GroupAverage', filesep, 'MeanStructural.nii');

imgsInfo = spm_vol(char(imgsMat));

volumes = spm_read_vols(imgsInfo);

Mask = volumes(:,:,:,1);

GroupAverage = volumes(:,:,:,2);

GroupAverage(Mask==0)=GroupAverage(Mask==0)*0.5;


% spm_write_vol: writes an image volume to disk
newImgInfo = imgsInfo(2);

% Change the name in the header
newImgInfo.fname = strcat(pwd, filesep, 'MeanStructuralMasked.nii');
newImgInfo.private.dat.fname = newImgInfo.fname;

spm_write_vol(newImgInfo, GroupAverage);


cd (StartFolder)
