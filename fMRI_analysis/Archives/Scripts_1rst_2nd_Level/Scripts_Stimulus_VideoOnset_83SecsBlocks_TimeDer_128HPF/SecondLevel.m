clc
clear

%spm fmri

% spm_jobman('initcfg')
% spm_get_defaults;
% global defaults

A = pwd;

GroupAnalysisFolder = strcat(pwd, filesep, 'SecondLevel', filesep, 'All_With_Derivatives', filesep);

SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];

% Second Level

matlabbatch = {};

matlabbatch{1,1}.spm.stats.factorial_design.cov = struct('name',{},'levels',{})

matlabbatch{1,1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1,1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1,1}.spm.stats.factorial_design.masking.em = cell(1,1);

matlabbatch{1,1}.spm.stats.factorial_design.globalc.g_omit = 1;

matlabbatch{1,1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1,1}.spm.stats.factorial_design.globalm.glonorm = 1;


matlabbatch{1,1}.spm.stats.factorial_design.des.pt.gmsca = 0;
matlabbatch{1,1}.spm.stats.factorial_design.des.pt.ancova = 0;



cd (GroupAnalysisFolder)

if exist(strcat('Events_Non_McGurk'),'dir')==0
    mkdir Events_Non_McGurk;
end;

cd Events_Non_McGurk

matlabbatch{1,1}.spm.stats.factorial_design.dir = {pwd};


for i=1:length(SubjectsList)
    
    SubjID=SubjectsList(i);
    
    SubjectAnalysisFolder = strcat(A, filesep, num2str(SubjID), filesep,'Analysis', filesep);
    
    matlabbatch{1,1}.spm.stats.factorial_design.des.pt.pair(1,i).scans{1,1} = strcat(SubjectAnalysisFolder, 'con_0012.img', ',1');
    matlabbatch{1,1}.spm.stats.factorial_design.des.pt.pair(1,i).scans{2,1} = strcat(SubjectAnalysisFolder, 'con_0013.img', ',1');
    
end



% Estimate model
matlabbatch{1,end+1}={};
matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = strcat(GroupAnalysisFolder, filesep, 'Events_Non_McGurk', filesep, 'SPM.mat');     %set the spm file to be estimated
matlabbatch{1,end}.spm.stats.fmri_est.method.Classical = 1;

cd(GroupAnalysisFolder)

save (strcat('Second_Level_Paired_TTest_','Events_Non_McGurk' , '_jobs'));

spm_jobman('run', matlabbatch)


% Load the right SPM.mat
cd Events_Non_McGurk
load SPM.mat

c = [ 1 -1 zeros(1,length(SubjectsList)) ];
cname = 'CON trials > INC trials';
SPM.xCon = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ -1 1 zeros(1,length(SubjectsList)) ];;
cname = 'INC trials > CON trials';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);


% Evaluate
spm_contrasts(SPM);


cd (A)
