clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

cd ..
StartFolder = pwd;
GroupAnalysisFolder = strcat(StartFolder, filesep, 'SecondLevel', filesep, 'Analysis_Percept_BetweenOnset_100SecsBlocks_TimeDer_200HPF_Despiked', filesep, 'Correlation');


ListOfContrastNames = {'McGurk Auditory in CON' ; ...
                       'McGurk Fused in CON' ; ...
                       'McGurk Auditory in INC' ; ...
                       'McGurk Fused in INC' ; ...                      
                       'Non McGurk Auditory in INC' ; ...
                       'Non McGurk Visual in INC'};
                   
ListOfContrastOfInterests = [1 2 6 7 9 10];                  

SubjectsList = [1 13 14 15 24 28 32 41 48 66 69 73 74 82 98 61];

%% Remove subjects with less than 10 trials per condition
for h = 1:length(SubjectsList)

        SubjID = num2str(SubjectsList(h));

        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Percept_BetweenOnset_100SecsBlocks_TimeDer_200HPF_Despiked', filesep);

        cd(AnalysisFolder)
        load SOT.mat
        
        X(:,h) = sum(~cellfun('isempty', Sorted_SOT),2)>0;

        Y(:,h) = sum(cellfun('length', Sorted_SOT),2);

        cd(StartFolder)
end

Contrasts = cumsum(X).*X;

clear X SubjID SubjectFolder AnalysisFolder

%%
cd SecondLevel
mkdir Analysis_Percept_BetweenOnset_100SecsBlocks_TimeDer_200HPF_Despiked;
load('GroupResponsesNoMiss.mat')

cd Analysis_Percept_BetweenOnset_100SecsBlocks_TimeDer_200HPF_Despiked;
mkdir Correlation

CorrelationVectors = [squeeze(GroupResponsesNoMiss(3,3,:)) squeeze(GroupResponsesNoMiss(3,4,:)) ...
                      squeeze(GroupResponsesNoMiss(4,3,:)) squeeze(GroupResponsesNoMiss(4,4,:)) ...
                      squeeze(GroupResponsesNoMiss(2,3,:)) squeeze(GroupResponsesNoMiss(2,2,:))];
                  
for j=1:length(ListOfContrastNames)

    SubjectsListTemp = SubjectsList;
    YTemp = Y(ListOfContrastOfInterests(j),:)
    ContrastsTemp = Contrasts(ListOfContrastOfInterests(j),:);
    CorrelationVectorsTemp = CorrelationVectors(:,j);

    CorrelationVectorsTemp(YTemp<=10)=[];
    SubjectsListTemp(YTemp<=10)=[];
    ContrastsTemp(YTemp<=10)=[];
    YTemp(YTemp<=10)=[];


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
        SubjectAnalysisFolder = strcat(StartFolder, filesep, num2str(SubjID), filesep,'Analysis_Percept_BetweenOnset_100SecsBlocks_TimeDer_200HPF_Despiked', filesep);
        
        A = num2str(ContrastsTemp(i));
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

    cd (StartFolder)
    
    clear A ContrastsFilesList CorrelationVectorsTemp ContrastsTemp YTemp SubjectsListTemp

end