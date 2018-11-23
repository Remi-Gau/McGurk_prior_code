clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

cd ..
StartFolder = pwd;

ListOfContrastNames = {'McGurk Auditory in CON' ; ...
                       'McGurk Fused in CON' ; ...
                       %
                       'Non McGurk CON'; ...
                       %
                       'McGurk Auditory in INC' ; ...
                       'McGurk Fused in INC' ; ...
                       %
                       'Non McGurk INC Auditory' ; ...
                       'Non McGurk INC Visual'; ...
                       %
                       'RT (INC_A - CON_A) VS INC_A > CON_A'; ...
                       'RT (MG_A - MG_F) VS MG_A > MG_F'; ...
                       'RT (MG_A+MG_F)_INC - (MG_A+MG_F)_CON VS (MG_A+MG_F)_INC > (MG_A+MG_F)_CON'};
                   
ListOfContrastOfInterests = [2 3 4 7 8 11 10 32 33 34];                  

SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];

%% Remove subjects with less than 10 trials per condition
for h = 1:length(SubjectsList)

        SubjID = num2str(SubjectsList(h));

        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', filesep);

        cd(AnalysisFolder)
        load SOT.mat
        
        X(:,h) = sum(~cellfun('isempty', Sorted_SOT),2)>0;

        Y(:,h) = sum(cellfun('length', Sorted_SOT),2);

        cd(StartFolder)
end

Y(end+1:end+4,:) = 20*ones(4,length(SubjectsList));

ConditionsToCheck = {Y(2,:)>10;
                     Y(3,:)>10;
                     Y(4,:)>10;
                     Y(7,:)>10;
                     Y(8,:)>10;
                     Y(11,:)>10;
                     Y(10,:)>10;
                     ~any([Y(4,:) ; Y(11,:)] < 10);
                     ~any([sum(Y([2 7],:)) ; sum(Y([3 8],:))] < 10);
                     ~any([sum(Y([2 3],:)); sum(Y([7 8],:))] < 10)};

clear X SubjID SubjectFolder AnalysisFolder

%%
cd SecondLevel
mkdir Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked;
load('GroupRT.mat')

% Files to load
MatFilesList = dir ('Results*.mat');
SizeMatFilesList = size(MatFilesList,1);

A = cell(SizeMatFilesList,3);

for Subject=1:SizeMatFilesList
    load(MatFilesList(Subject).name, 'TotalTrials')
    B = TotalTrials{1,1}(:,[4 5 6 8]); 
    B(B(:,4)==5,:)=[]; 
    B(B(:,2)<2,:)=[];
    B(:,2)=[];
    
    A{Subject,1} = B;
    A{Subject,2} = [median(B(B(:,3)==3,2)) median(B(B(:,3)==4,2))];
    
    C = B;
    C(C(:,3)<3,:)=[];
    A{Subject,3} = [median(C(C(:,1)==1,2)) median(C(C(:,1)==0,2))];
    
    clear B C
end

%%

cd Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked;
mkdir RT_Correlation

cd RT_Correlation
GroupAnalysisFolder =pwd;

CorrelationVectors = [squeeze(GroupRT(3,3,:)) squeeze(GroupRT(3,4,:)) ...
                      squeeze(GroupRT(1,3,:)) ...
                      squeeze(GroupRT(4,3,:)) squeeze(GroupRT(4,4,:)) ...
                      squeeze(GroupRT(2,3,:)) squeeze(GroupRT(2,2,:)) ...
                      squeeze(GroupRT(2,3,:))-squeeze(GroupRT(1,3,:)) ...
                      diff(cell2mat({A{:,2}}'),1,2) ...
                      diff(cell2mat({A{:,3}}'),1,2)];
                  
for j=1:length(ListOfContrastNames)

    SubjectsListTemp = SubjectsList(ConditionsToCheck{j})
    CorrelationVectorsTemp = CorrelationVectors(ConditionsToCheck{j},j);
    
    SubjectsListTemp(isnan(CorrelationVectorsTemp))=[];
    CorrelationVectorsTemp(isnan(CorrelationVectorsTemp))=[];


    matlabbatch = {};

    matlabbatch{1,1}.spm.stats.factorial_design.cov = struct('name',{},'levels',{});

    matlabbatch{1,1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.masking.em = cell(1,1);

    matlabbatch{1,1}.spm.stats.factorial_design.globalc.g_omit = 1;

    matlabbatch{1,1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.globalm.glonorm = 1;
    
    matlabbatch{1,1}.spm.stats.factorial_design.des.mreg.mcov.cname = ListOfContrastNames{j};
    matlabbatch{1,1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.des.mreg.mcov.c = CorrelationVectorsTemp;

    for i=1:length(SubjectsListTemp)
        SubjID=SubjectsListTemp(i);
        SubjectAnalysisFolder = strcat(StartFolder, filesep, num2str(SubjID), filesep,'Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', filesep);
        
        A = num2str(ListOfContrastOfInterests(j));
        if length(A)==1
            A = ['0' A];
        end
        
        ContrastsFilesList{i,:} = strcat(SubjectAnalysisFolder, 'con_00', A, '.img,1');
    end
       
    matlabbatch{1,1}.spm.stats.factorial_design.des.mreg.scans = ContrastsFilesList;

    
    cd (GroupAnalysisFolder)
    mkdir (ListOfContrastNames{j});
    cd (ListOfContrastNames{j})
    
    matlabbatch{1,1}.spm.stats.factorial_design.dir = {pwd};
    
    % Estimate model
    matlabbatch{1,end+1}={};
    matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = strcat(GroupAnalysisFolder, filesep, (ListOfContrastNames{j}), filesep, 'SPM.mat');     %set the spm file to be estimated
    matlabbatch{1,end}.spm.stats.fmri_est.method.Classical = 1;

    save (strcat('Correlation_MultiReg_', (ListOfContrastNames{j}) , '_jobs'), 'matlabbatch');

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
    
    clear A ContrastsFilesList CorrelationVectorsTemp ContrastsTemp YTemp SubjectsListTemp

end