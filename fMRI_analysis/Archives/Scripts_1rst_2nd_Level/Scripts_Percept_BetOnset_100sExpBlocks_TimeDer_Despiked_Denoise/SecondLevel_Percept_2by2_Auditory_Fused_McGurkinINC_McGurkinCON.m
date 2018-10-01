%%
clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

cd ..
PresentFolder = pwd;

% Subjects
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98]

%% Remove subjects with less than 10 trials per condition
for h = 1:length(SubjectsList)
    
        SubjID = num2str(SubjectsList(h));
        
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Percept_BetOnset_100ExpBlock_TimeDer_Despiked_Denoise', filesep);
              
        cd(AnalysisFolder)
        load SOT.mat
        
        Y(:,h) = sum(cellfun('length', Sorted_SOT),2);
        
        cd(PresentFolder)
end
        
        
Y=Y([2 3 7 8],:)

for i=1:4
    SubjectsList(Y(i,:)<=10)=[]
    Y(:,(Y(i,:)<=10))=[]
end


%% Remove subjects with less than 10 trials per condition
A = repmat([strcat(PresentFolder, filesep)], length(SubjectsList)*4, 1);
B = reshape(repmat(SubjectsList, 4, 1), length(SubjectsList)*4, 1);
A = [A num2str(B)]; clear B
B = repmat([strcat(filesep, 'Analysis_Percept_BetOnset_100ExpBlock_TimeDer_Despiked_Denoise', filesep, 'con_000')], length(SubjectsList)*4, 1);
A = [A B];
clear B

for h = 1:length(SubjectsList)
        
        SubjID = num2str(SubjectsList(h));
        
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Percept_BetOnset_100ExpBlock_TimeDer_Despiked_Denoise', filesep);
              
        cd(AnalysisFolder)
        load SOT.mat
    
        X(:,h) = sum(~cellfun('isempty', Sorted_SOT),2)>0;
        
        TrialsPerConditionPersubject(:,h) = sum(cellfun('length', Sorted_SOT),2);
                
        cd(PresentFolder)
             
end


Contrasts = [2 3 7 8];
B = repmat(Contrasts', length(SubjectsList), 1);
A = [A num2str(B)]; clear B
B = repmat([strcat('.img,1')], length(SubjectsList)*4, 1);
A = [A B];

ScansList = A

clear B SOT SubjectFolder ans h SubjID



%% Defines batch
cd SecondLevel;
mkdir Analysis_Percept_BetOnset_100ExpBlock_TimeDer_Despiked_Denoise;
cd Analysis_Percept_BetOnset_100ExpBlock_TimeDer_Despiked_Denoise;
mkdir 2x2_ANOVA_Auditory_Fused-McGurkinINC_McGurkinCON;
cd 2x2_ANOVA_Auditory_Fused-McGurkinINC_McGurkinCON;

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

clear A B C 

save (strcat('Second_Level_Analysis_Percept_BetOnset_100ExpBlock_TimeDer_Despiked_Denoise_jobs'), 'matlabbatch');

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

c = [ 0 0 1 -1 zeros(1,length(SubjectsList))];
cname = 'Auditory in INC > Fused in INC';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ 1 -1 0 0 zeros(1,length(SubjectsList))];
cname = 'Auditory in CON > Fused in CON';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);



c = [repmat(1/4,1,4) ones(1,length(SubjectsList))/length(SubjectsList)];
cname = 'All > Baseline';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [repmat(-1/4,1,4) -ones(1,length(SubjectsList))/length(SubjectsList)];
cname = 'All < Baseline';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);



c = [ 1 -1 -1 1 zeros(1,length(SubjectsList))];
cname = 'Interaction';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = -1*c;
cname = 'Interaction';
SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);


spm_contrasts(SPM);


%%
clear jobs

c = [eye(4) repmat(ones(1,length(SubjectsList))/length(SubjectsList), 4, 1)];

jobs{1,1}.spm.stats.con.spmmat = {fullfile(pwd,'SPM.mat')};

jobs{1,1}.spm.stats.con.consess{1,1}.fcon.name = 'Beta estimates';
jobs{1,1}.spm.stats.con.consess{1,1}.fcon.convec{1,1} = c;

spm_jobman('run',jobs);


%% Make a masked image of the subject structural
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


cd (PresentFolder)