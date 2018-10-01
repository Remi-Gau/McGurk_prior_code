clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

cd ..
StartFolder = pwd;
GroupAnalysisFolder = strcat(StartFolder, filesep, 'SecondLevel', filesep, 'Analysis_Stimulus_AudioOnset_100SecsBlocks_TimeDer_200HPF_Despiked', filesep, 'RT_Correlation');

ListOfContrast = {'con_0012.img' ; 'con_0013.img' ; 'con_0003.img'; 'con_0004.img' ; 'con_0010.img'; 'con_0005.img'};

ListOfContrastNames = {'CON trials' ; 'INC trials' ; 'McGurk In CON' ;  'McGurk In INC'; 'CON trials VS INC trials' ; 'McGurk In CON VS McGurk In INC'};

SubjectsList = [1 13 14 15 24 28 32 41 48 66 69 73 74 82 98 61];

cd SecondLevel
load('GroupRT_Results.mat')

mkdir Analysis_Stimulus_AudioOnset_100SecsBlocks_TimeDer_200HPF_Despiked;
cd Analysis_Stimulus_AudioOnset_100SecsBlocks_TimeDer_200HPF_Despiked;
mkdir RT_Correlation

CorrelationVectors = [GroupRT_Results ; GroupRT_Results(1,:)-GroupRT_Results(2,:) ; GroupRT_Results(3,:)-GroupRT_Results(4,:) ] ;

for j=1:length(ListOfContrastNames)

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
    matlabbatch{1,1}.spm.stats.factorial_design.des.mreg.mcov.c = CorrelationVectors(j,:);

    for i=1:length(SubjectsList)
        SubjID=SubjectsList(i);
        SubjectAnalysisFolder = strcat(StartFolder, filesep, num2str(SubjID), filesep,'Analysis_TimeDer_200HPF_Despiked', filesep);
        ContrastsFilesList{i,:} = strcat(SubjectAnalysisFolder, ListOfContrast{j,1}, ',1'); 
    end
    
    matlabbatch{1,1}.spm.stats.factorial_design.des.mreg.scans = ContrastsFilesList;


    
    % Estimate model
    matlabbatch{1,end+1}={};
    matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = strcat(GroupAnalysisFolder, filesep, (ListOfContrastNames{j}), filesep, 'SPM.mat');     %set the spm file to be estimated
    matlabbatch{1,end}.spm.stats.fmri_est.method.Classical = 1;

    
    cd (GroupAnalysisFolder)
    mkdir (ListOfContrastNames{j});
    cd (ListOfContrastNames{j})
    
    matlabbatch{1,1}.spm.stats.factorial_design.dir = {pwd};

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

end