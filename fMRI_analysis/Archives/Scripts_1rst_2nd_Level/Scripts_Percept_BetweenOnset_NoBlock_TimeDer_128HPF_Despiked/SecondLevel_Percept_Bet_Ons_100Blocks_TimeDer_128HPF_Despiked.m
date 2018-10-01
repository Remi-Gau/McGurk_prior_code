clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

cd ..
PresentFolder = pwd;

% Subjects
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];


ListOfTest = {'Events_Non_McGurk', 'McGurk_Fused', 'McGurk_Auditory', 'McGurk_CON', 'McGurk_INC', 'NonMcGurk_INC'};

ContrastOfInterest = [4 10 ; 2 7 ; 1 6 ; 1 2 ; 6 7 ; 10 9];

ListOfContrastNames = {'CON trials > INC trials', 'INC trials > CON trials' , 'CON trials > Baseline', 'INC trials > Baseline' , 'CON trials < Baseline', 'INC trials < Baseline' , 'INC trials + CON trials > Baseline' , 'INC trials + CON trials < Baseline' ; ...
                       'McGurk_Fused in CON > McGurk_Fused in INC', 'McGurk_Fused in INC > McGurk_Fused in CON' , 'McGurk_Fused in CON > Baseline', 'McGurk_Fused in INC > Baseline' , 'McGurk_Fused in CON < Baseline', 'McGurk_Fused in INC < Baseline' , 'McGurk_Fused in CON & INC > Baseline' , 'McGurk_Fused in CON & INC < Baseline' ;
                       'McGurk_Auditory in CON > McGurk_Auditory in INC', 'McGurk_Auditory in INC > McGurk_Auditory in CON' , 'McGurk_Auditory in CON > Baseline', 'McGurk_Auditory in INC > Baseline' , 'McGurk_Auditory in CON < Baseline', 'McGurk_Auditory in INC < Baseline' , 'McGurk_Auditory in CON & INC > Baseline' , 'McGurk_Auditory in CON & INC < Baseline';
                       'McGurk_Auditory in CON > McGurk_Fused in CON', 'McGurk_Fused in CON > McGurk_Auditory in CON' , 'McGurk_Auditory in CON > Baseline', 'McGurk_Fused in CON > Baseline' , 'McGurk_Auditory in CON < Baseline', 'McGurk_Fused in CON < Baseline' , 'McGurk_Fused  & McGurk_Auditory in CON > Baseline' , 'McGurk_Fused  & McGurk_Auditory in CON < Baseline' ;
                       'McGurk_Auditory in INC > McGurk_Fused in INC', 'McGurk_Fused in INC > McGurk_Auditory in INC' , 'McGurk_Auditory in INC > Baseline', 'McGurk_Fused in INC > Baseline' , 'McGurk_Auditory in INC < Baseline', 'McGurk_Fused in INC < Baseline' , 'McGurk_Fused  & McGurk_Auditory in INC > Baseline' , 'McGurk_Fused  & McGurk_Auditory in INC < Baseline';
                       'Non McGurk_Auditory in INC > Non McGurk_Fused in INC', 'Non McGurk_Fused in INC > Non McGurk_Auditory in INC' , 'Non McGurk_Auditory in INC > Baseline', 'Non McGurk_Fused in INC > Baseline' , 'Non McGurk_Auditory in INC < Baseline', 'Non McGurk_Fused in INC < Baseline' , 'Non McGurk_Fused & Auditory in INC > Baseline' , 'Non McGurk_Fused & Auditory in INC < Baseline'} ;
                   
for h=1:length(SubjectsList)
        
        SubjID=num2str(SubjectsList(h));
        
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Percept_BetweenOnset_NoBlock_TimeDer_128HPF_Despiked', filesep);
              
        cd(AnalysisFolder)
        load SOT.mat
    
        X(:,h) = sum(~cellfun('isempty', Sorted_SOT),2)>0;
        
        Y(:,h) = sum(cellfun('length', Sorted_SOT),2);
     
        cd(PresentFolder)
                   
end

Contrasts = cumsum(X).*X;

clear B SOT X h Sorted_SOT

cd SecondLevel
mkdir Analysis_Percept_BetweenOnset_NoBlock_TimeDer_128HPF_Despiked;
cd ..

GroupAnalysisFolder = strcat(pwd, filesep, 'SecondLevel', filesep, 'Analysis_Percept_BetweenOnset_NoBlock_TimeDer_128HPF_Despiked', filesep);


for j=1:length(ListOfTest)

    matlabbatch = {};

    matlabbatch{1,1}.spm.stats.factorial_design.cov = struct('name',{},'levels',{});

    matlabbatch{1,1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.masking.em = cell(1,1);

    matlabbatch{1,1}.spm.stats.factorial_design.globalc.g_omit = 1;

    matlabbatch{1,1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.globalm.glonorm = 1;


    matlabbatch{1,1}.spm.stats.factorial_design.des.pt.gmsca = 0;
    matlabbatch{1,1}.spm.stats.factorial_design.des.pt.ancova = 0;



    cd (GroupAnalysisFolder)

    mkdir (ListOfTest{j});


    cd (ListOfTest{j})

    matlabbatch{1,1}.spm.stats.factorial_design.dir = {pwd};
    
    
    SubjectsListTemp = SubjectsList;
    YTemp = Y;
    
    for i=1:2
        SubjectsListTemp(YTemp(ContrastOfInterest(j,i),:)<=10)=[];
        YTemp(:,(YTemp(ContrastOfInterest(j,i),:)<=10))=[];
    end



    for i=1:length(SubjectsListTemp)
        
        A = strcat(PresentFolder, filesep, num2str(SubjectsListTemp(i)), filesep, ...
            'Analysis_Percept_BetweenOnset_NoBlock_TimeDer_128HPF_Despiked', filesep, ...
            'con_00');
        
        B = num2str(Contrasts(ContrastOfInterest(j,:),i));
        B(B==' ')='0';
        if size(B,2)==1
            B=[['0';'0'] B];
        end

        matlabbatch{1,1}.spm.stats.factorial_design.des.pt.pair(1,i).scans{1,1} = strcat(A, B(1,:) ,'.img,1');
        matlabbatch{1,1}.spm.stats.factorial_design.des.pt.pair(1,i).scans{2,1} = strcat(A, B(2,:) ,'.img,1');
        
        clear A B
    end
    
    ListOfTest{j}
    SubjectsListTemp
    length(SubjectsListTemp)



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

    ContrastsValues =   [ 1 -1 zeros(1,length(SubjectsListTemp)); ...
                         -1 1 zeros(1,length(SubjectsListTemp)); ...
                          1 0 ones(1,length(SubjectsListTemp))/length(SubjectsListTemp); ...
                          0 1 ones(1,length(SubjectsListTemp))/length(SubjectsListTemp); ...
                         -1 0 -ones(1,length(SubjectsListTemp))/length(SubjectsListTemp); ...
                          0 -1 -ones(1,length(SubjectsListTemp))/length(SubjectsListTemp); ...
                          0.5 0.5 ones(1,length(SubjectsListTemp))/length(SubjectsListTemp); ...
                          -0.5 -0.5 -ones(1,length(SubjectsListTemp))/length(SubjectsListTemp)];
    
    cname = ListOfContrastNames{j,1};
    c = [1 -1 zeros(1,length(SubjectsListTemp))];
    SPM.xCon = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);                  
                      
    for i=2:size(ContrastsValues,1)  
        cname = ListOfContrastNames{j,i};
        c = ContrastsValues(i,:);
        SPM.xCon(end+1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);
    end


    % Evaluate
    spm_contrasts(SPM);

    cd (PresentFolder)

end