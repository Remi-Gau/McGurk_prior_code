%%
clc
clear

% spm_jobman('initcfg')
% spm_get_defaults;
% global defaults

PresentFolder = pwd;

% Subjects
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];


%% Creates contrast list

A = repmat([strcat(PresentFolder, filesep)], length(SubjectsList)*4, 1);
B = reshape(repmat(SubjectsList, 4, 1), length(SubjectsList)*4, 1);
A = [A num2str(B)]; clear B
B = repmat([strcat(filesep, 'Analysis_83SecsBlocks_TimeDer_200HPF', filesep, 'con_00')], length(SubjectsList)*4, 1);
A = [A B]; clear B
B = repmat(['03';'12';'04';'13'],length(SubjectsList),1);
A = [A B]; clear B
B = repmat([strcat('.img,1')], length(SubjectsList)*4, 1);
A = [A B]; clear B

ScansList = cellstr(A);

ScansList{1,1}(ScansList{1,1} == ' ') = [];
ScansList{2,1}(ScansList{2,1} == ' ') = [];
ScansList{3,1}(ScansList{3,1} == ' ') = [];
ScansList{4,1}(ScansList{4,1} == ' ') = [];


%% Creates condition matrix
MATRIX(:,1) = 4*ones(length(SubjectsList)*4,1); 
MATRIX(:,3) = repmat([1 1 2 2]', length(SubjectsList), 1);
MATRIX(:,4) = repmat([1 2 1 2]', length(SubjectsList), 1);

C = zeros(length(SubjectsList)*4,1);
for h = 1:length(SubjectsList)    
        C(h+3*(h-1):h+3*(h-1)+3) = h*ones(4,1);             
end
MATRIX(:,2) = C;


clear B SOT SubjectFolder ans h SubjID


%% Defines batch
cd SecondLevel;
mkdir Analysis_83SecsBlocks_TimeDer_200HPF;
cd Analysis_83SecsBlocks_TimeDer_200HPF;
mkdir RM-ANOVA;
cd RM-ANOVA;

GroupAnalysisFolder = pwd;


matlabbatch{1,1}.spm.stats.factorial_design.dir{1,1} = GroupAnalysisFolder;

matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,1).name = 'Subject';
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,1).dept = 0;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,1).variance = 0;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,1).gmsca = 0;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,1).ancova = 0;

matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,2).name = 'Context';
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,2).dept = 1;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,2).variance = 0;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,2).gmsca = 0;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,2).ancova = 0;

matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,3).name = 'Stimulus Type';
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,3).dept = 1;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,3).variance = 0;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,3).gmsca = 0;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,3).ancova = 0;

matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fsuball.specall.scans = ScansList;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fsuball.specall.imatrix = MATRIX;

matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.maininters{1,1}.fmain.fnum = 1;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.maininters{1,2}.inter.fnums = [2;3];

%matlabbatch{1}.spm.stats.factorial_design.cov.c = {};
%matlabbatch{1}.spm.stats.factorial_design.cov.cname = {};
%matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = {};
%matlabbatch{1}.spm.stats.factorial_design.cov.iCC = {};

matlabbatch{1,1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1,1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1,1}.spm.stats.factorial_design.masking.em = {''};

matlabbatch{1,1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1,1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1,1}.spm.stats.factorial_design.globalm.glonorm = 1;

    
%% Estimate model
matlabbatch{1,end+1}={};
matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = strcat(GroupAnalysisFolder, filesep, 'SPM.mat');     %set the spm file to be estimated
matlabbatch{1,end}.spm.stats.fmri_est.method.Classical = 1;

cd(GroupAnalysisFolder)

clear A B C MATRIX 

save (strcat('Second_Level_Analysis_83SecsBlocks_TimeDer_200HPF_RM_ANOVA_jobs'), 'matlabbatch');

spm_jobman('run', matlabbatch)



%% Compute contrasts
load SPM.mat

c = [ 1 1 -1 -1 zeros(1,length(SubjectsList))];
cname = 'Context: CON > INC';
SPM.xCon = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = -1*c;
cname = 'Context: INC > CON';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ 1 -1 1 -1 zeros(1,length(SubjectsList))];
cname = 'Stimulus type: McGurk > Non McGurk';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = -1*c;
cname = 'Stimulus type: Non McGurk > McGurk';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ 1 -1 -1 1 zeros(1,length(SubjectsList))];
cname = 'Interaction 1';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = -1*c;
cname = 'Interaction 2';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);


spm_contrasts(SPM);


cd(PresentFolder)