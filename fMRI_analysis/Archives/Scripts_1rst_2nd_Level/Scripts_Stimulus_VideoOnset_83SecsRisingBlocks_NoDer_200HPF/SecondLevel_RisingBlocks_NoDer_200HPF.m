clc
clear

%spm fmri

spm_jobman('initcfg')
spm_get_defaults;
global defaults

A = pwd;

ListOfTest = {'Events_McGurk', 'Blocks', 'Events_Non_McGurk'};

ListOfContrast = {'con_0003.img', 'con_0004.img' ; 'con_0008.img', 'con_0009.img' ; 'con_0012.img', 'con_0013.img'}

ListOfContrastNames = {'McGurkInCON trials > McGurkInINC trials', 'McGurkInINC trials > McGurkInCON trials' ; 'CON > INC', 'INC > CON' ; 'CON trials > INC trials', 'INC trials > CON trials'}

SubjectsList = [1 13 14 15 24 28 32 41 48 66 69 73 74 82 98 61];

cd SecondLevel
if exist('RisingBlocks_NoDer_200HPF','dir')==0
    mkdir RisingBlocks_NoDer_200HPF;
end;
cd ..

GroupAnalysisFolder = strcat(pwd, filesep, 'SecondLevel', filesep, 'RisingBlocks_NoDer_200HPF', filesep);


for j=1:length(ListOfTest)

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

    if exist(ListOfTest{j},'dir')==0
        mkdir (ListOfTest{j});
    end;

    cd (ListOfTest{j})

    matlabbatch{1,1}.spm.stats.factorial_design.dir = {pwd};


    for i=1:length(SubjectsList)

        SubjID=SubjectsList(i);

        SubjectAnalysisFolder = strcat(A, filesep, num2str(SubjID), filesep,'Analysis_Without_Temporal_Derivative', filesep);

        matlabbatch{1,1}.spm.stats.factorial_design.des.pt.pair(1,i).scans{1,1} = strcat(SubjectAnalysisFolder, ListOfContrast{j,1}, ',1');
        matlabbatch{1,1}.spm.stats.factorial_design.des.pt.pair(1,i).scans{2,1} = strcat(SubjectAnalysisFolder, ListOfContrast{j,2}, ',1');

    end



    % Estimate model
    matlabbatch{1,end+1}={};
    matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = strcat(GroupAnalysisFolder, filesep, (ListOfTest{j}), filesep, 'SPM.mat');     %set the spm file to be estimated
    matlabbatch{1,end}.spm.stats.fmri_est.method.Classical = 1;

    cd(GroupAnalysisFolder)

    save (strcat('Second_Level_Paired_TTest_', (ListOfTest{j}) , '_jobs'));

    spm_jobman('run', matlabbatch)


    % Load the right SPM.mat
    cd (ListOfTest{j})
    load SPM.mat

    c = [ 1 -1 zeros(1,length(SubjectsList)) ];
    cname = ListOfContrastNames{j,1};
    SPM.xCon = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

    c = [ -1 1 zeros(1,length(SubjectsList)) ];;
    cname = ListOfContrastNames{j,2};
    SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);


    % Evaluate
    spm_contrasts(SPM);

    cd (A)

end