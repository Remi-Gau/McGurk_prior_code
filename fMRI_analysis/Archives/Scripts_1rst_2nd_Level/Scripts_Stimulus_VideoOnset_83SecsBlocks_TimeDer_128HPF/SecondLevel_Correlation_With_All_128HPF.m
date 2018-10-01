clc
clear

% spm_jobman('initcfg')
% spm_get_defaults;
% global defaults

StartFolder = pwd;
GroupAnalysisFolder = strcat(StartFolder, filesep, 'SecondLevel', filesep, 'All_With_Derivatives', filesep, 'Correlation');

ListOfContrast = {'con_0003.img' ; 'con_0004.img' ; 'con_0005.img'; 'con_0008.img' ; 'con_0009.img' ; 'con_0010.img'};

ListOfContrastNames = {'McGurkInCON trials' ; 'McGurkInINC trials' ; 'McGurkInCON trials > McGurkInINC trials' ; 'CON' ; 'INC' ; 'CON > INC'};

SubjectsList = [1 13 14 15 24 28 32 41 48 66 69 73 74 82 98 61];

cd SecondLevel
load('PercentFused_CON_And_INC.mat', 'PercentFused_CON_And_INC')
mkdir All_With_Derivatives;
cd All_With_Derivatives;
mkdir Correlation

CorrelationVectors = repmat([PercentFused_CON_And_INC(:,1) PercentFused_CON_And_INC(:,2) PercentFused_CON_And_INC(:,1)-PercentFused_CON_And_INC(:,2)], 1, 2);
CorrelationNames = {'% Fused_(CON)', '% Fused_(INC)', '% Fused_(CON) - % Fused_(INC)', '% Fused_(CON)', '% Fused_(INC)', '% Fused_(CON) - % Fused_(INC)'};

for j=1:length(ListOfContrastNames)

    matlabbatch = {};

    matlabbatch{1,1}.spm.stats.factorial_design.cov = struct('name',{},'levels',{});

    matlabbatch{1,1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.masking.em = cell(1,1);

    matlabbatch{1,1}.spm.stats.factorial_design.globalc.g_omit = 1;

    matlabbatch{1,1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.globalm.glonorm = 1;
    
    matlabbatch{1,1}.spm.stats.factorial_design.des.mreg.mcov.cname = CorrelationNames{j};
    matlabbatch{1,1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.des.mreg.mcov.c = CorrelationVectors(:,j);

    for i=1:length(SubjectsList)
        SubjID=SubjectsList(i);
        SubjectAnalysisFolder = strcat(StartFolder, filesep, num2str(SubjID), filesep,'Analysis', filesep);
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