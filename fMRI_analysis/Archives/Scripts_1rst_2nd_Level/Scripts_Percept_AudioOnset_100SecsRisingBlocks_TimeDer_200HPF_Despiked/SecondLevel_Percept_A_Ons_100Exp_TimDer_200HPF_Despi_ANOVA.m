%%
clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

cd ..
PresentFolder = pwd;

% Subjects
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];

%% Remove subjects with less than 10 trials per condition
for h = 1:length(SubjectsList)
    
        SubjID = num2str(SubjectsList(h));
        
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Percept_AudioOnset_100ExpBlocks_TimeDer_200HPF_Despiked', filesep);
              
        cd(AnalysisFolder)
        load SOT.mat
        
        Y(:,h) = sum(cellfun('length', Sorted_SOT),2);
        
        cd(PresentFolder)
end
        
        
Y([3:5 8:11],:) = []

for i=1:4
    SubjectsList(Y(i,:)<=10)=[];
    Y(:,(Y(i,:)<=10))=[];
end


%% Remove subjects with less than 10 trials per condition
MATRIX(:,1) = 4*ones(length(SubjectsList)*4,1); 
MATRIX(:,3) = repmat([1 1 2 2]', length(SubjectsList), 1);
MATRIX(:,4) = repmat([1 2 1 2]', length(SubjectsList), 1);

A = repmat([strcat(PresentFolder, filesep)], length(SubjectsList)*4, 1);
B = reshape(repmat(SubjectsList, 4, 1), length(SubjectsList)*4, 1);
A = [A num2str(B)]; clear B
B = repmat([strcat(filesep, 'Analysis_Percept_AudioOnset_100ExpBlocks_TimeDer_200HPF_Despiked', filesep, 'con_000')], length(SubjectsList)*4, 1);
A = [A B];
clear B

C = zeros(length(SubjectsList)*4,1);

for h = 1:length(SubjectsList)
        
        SubjID = num2str(SubjectsList(h));
        
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Percept_AudioOnset_100ExpBlocks_TimeDer_200HPF_Despiked', filesep);
              
        cd(AnalysisFolder)
        load SOT.mat
    
        X(:,h) = sum(~cellfun('isempty', Sorted_SOT),2)>0;
        
        TrialsPerConditionPersubject(:,h) = sum(cellfun('length', Sorted_SOT),2);
                
        cd(PresentFolder)
        
        C(h+3*(h-1):h+3*(h-1)+3) = h*ones(4,1);
                   
end

MATRIX(:,2) = C;

Contrasts = cumsum(X).*X
Contrasts([3:5 8:11],:) = [];
B = reshape(Contrasts, length(SubjectsList)*4, 1);
A = [A num2str(B)]; clear B
B = repmat([strcat('.img,1')], length(SubjectsList)*4, 1);
A = [A B];

ScansList = A;

clear B SOT SubjectFolder ans h SubjID



%% Defines batch
cd SecondLevel;
mkdir Analysis_Percept_AudioOnset_100ExpBlocks_TimeDer_200HPF_Despiked;
cd Analysis_Percept_AudioOnset_100ExpBlocks_TimeDer_200HPF_Despiked;
mkdir RM-ANOVA_McGurk;
cd RM-ANOVA_McGurk;

GroupAnalysisFolder = pwd;


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

matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,3).name = 'Percept';
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,3).dept = 1;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,3).variance = 1;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,3).gmsca = 0;
matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fac(1,3).ancova = 0;

% matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fsuball.specall.scans = ScansList;
% matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fsuball.specall.imatrix = MATRIX;

for i=1:length(SubjectsList)
    
    A = cellstr(ScansList(1+4*(i-1):4+4*(i-1),:));
    for j=1:4
        A{j,1}(A{j,1}==' ') = [];
    end
    
    matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).scans = A;
    matlabbatch{1,1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).conds = [1 1 ; 1 2 ; 2 1 ; 2 2];
end

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

save (strcat('Second_Level_Analysis_Percept_AudioOnset_100ExpBlocks_TimeDer_200HPF_Despiked_jobs'), 'matlabbatch');

spm_jobman('run', matlabbatch)



%% Compute contrasts
load SPM.mat

c = [ 1 1 -1 -1 zeros(1,length(SubjectsList))];
cname = 'Context: CON>INC';
SPM.xCon = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = -1*c;
cname = 'Context: INC>CON';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);



c = [ 1 -1 1 -1 zeros(1,length(SubjectsList))];
cname = 'Percept: Auditory>Fused';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = -1*c;
cname = 'Percept: Fused>Auditory';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);



c = [ 1 0 -1 0 zeros(1,length(SubjectsList))];
cname = 'Auditory in CON > Auditory in INC';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = -1*c;
cname = 'Auditory in INC > Auditory in CON';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ 0 1 0 -1 zeros(1,length(SubjectsList))];
cname = 'Fused in CON > Fused in INC';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = -1*c;
cname = 'Fused in INC > Fused in CON';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);



c = [repmat(1/4,1,4) ones(1,length(SubjectsList))/length(SubjectsList)];
cname = 'All > Baseline';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [repmat(-1/4,1,4) -ones(1,length(SubjectsList))/length(SubjectsList)];
cname = 'All < Baseline';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);



c = [ 1 -1 -1 1 zeros(1,length(SubjectsList))];
cname = 'Interaction';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'F','c', c(:), SPM.xX.xKXs);


spm_contrasts(SPM);


cd(PresentFolder)