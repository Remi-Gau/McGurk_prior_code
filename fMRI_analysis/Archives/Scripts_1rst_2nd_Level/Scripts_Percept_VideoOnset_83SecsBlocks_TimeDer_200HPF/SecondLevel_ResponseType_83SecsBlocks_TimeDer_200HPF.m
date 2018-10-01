clc
clear

%spm fmri

% spm_jobman('initcfg')
% spm_get_defaults;
% global defaults

PresentFolder = pwd;


ListOfTest = {'Blocks', 'Events_Non_McGurk'};

ListOfContrastNames = {'CON > INC', 'INC > CON' , 'Beta estimates' , 'CON' , 'INC' ; ...
                    'CON trials > INC trials', 'INC trials > CON trials', 'Beta estimates' , 'CON trials' , 'INC trials'}

A = repmat([strcat(PresentFolder, filesep)], length(SubjectsList)*4, 1);
B = reshape(repmat(SubjectsList, 4, 1), length(SubjectsList)*4, 1);
A = [A num2str(B)]; clear B
B = repmat([strcat(filesep, 'Analysis_ResponseType_TimeDerivative', filesep, 'con_000')], length(SubjectsList)*4, 1);
A = [A B];
clear B

% Subjects
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];


for h=1:length(SubjectsList)
        
        SubjID=num2str(SubjectsList(h))
        
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_ResponseType_TimeDerivative', filesep);
              
        cd(AnalysisFolder)
        load SOT.mat
    
        X(:,h) = sum(~cellfun('isempty', Sorted_SOT),2)>0;
     
        cd(PresentFolder)
                   
end

Contrasts = cumsum(X).*X
Contrasts([1:3 5:8 10:12],:) = [];
B = reshape(Contrasts, length(SubjectsList)*4, 1);
A = [A num2str(B)]; clear B
B = repmat([strcat('.img,1')], length(SubjectsList)*4, 1);
A = [A B];

ScansList = cellstr(A);

ScansList{1,1}(ScansList{1,1} == ' ') = [];
ScansList{2,1}(ScansList{2,1} == ' ') = [];
ScansList{3,1}(ScansList{3,1} == ' ') = [];
ScansList{4,1}(ScansList{4,1} == ' ') = []

return

cd SecondLevel
mkdir ResponseType_TimeDerivative;
cd ..

GroupAnalysisFolder = strcat(pwd, filesep, 'SecondLevel', filesep, 'ResponseType_TimeDerivative', filesep);


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

        SubjectAnalysisFolder = strcat(A, filesep, num2str(SubjID), filesep,'Analysis_ResponseType_TimeDerivative', filesep);

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