clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

cd ..
PresentFolder = pwd;

% Subjects
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];

%% Conditions Names
BlocksNames = {'Congruent', 'Incongruent'};

Trials_Types = { 'McGurk_in_Congruent',	'Congruent', 'McGurk_in_Incongruent', 'Incongruent' };

Response_Category = {'Wrong', 'Visual', 'Auditory', 'Fused', 'Missed'};

A =  cell(length(Trials_Types)*length(Response_Category),1);

for i=1:length(Trials_Types)
    for j=1:length(Response_Category)
        A{j+length(Response_Category)*(i-1),1} = strcat(Trials_Types{1,i}, '_trials_', Response_Category{1,j}, '_answers');
    end
end

A{1,1} = 'McGurk_in_Congruent_trials_Wrong-Visual_answers';
A{8,1} = 'Congruent_trials_Auditory-Visual_answers';
A{10,1} = 'Congruent_trials_Wrong-Fused_answers';
A{11,1} = 'McGurk_in_Incongruent_trials_Wrong-Visual_answers';
A{16,1} = 'Incongruent_trials_Wrong-Fused_answers';
A{20,1} = 'Missed_trials';

A([2 5 6 7 9 12 15 19], :) = [];

Conditions_Names = char(A)

clear A j i Response_Category Trials_Types



%%
ListOfTest = cellstr( Conditions_Names([2 3 7 8],:));
          
ListOfContrastNames = ListOfTest;
ContrastOfInterest = [2 3 7 8]';
    
for h=1:length(SubjectsList)
        
        SubjID=num2str(SubjectsList(h));
        
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Concatenated_RT_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', filesep);
              
        cd(AnalysisFolder)
        load SOT.mat
           
        Y(:,h) = sum(cellfun('length', Sorted_SOT),2);
     
        cd(PresentFolder)
                   
end

SubjectsListTemp = SubjectsList;
YTemp = Y(ContrastOfInterest, :);
SubjectsListTemp = SubjectsListTemp(~any(YTemp<10, 1))

clear B SOT X h Sorted_SOT

cd SecondLevel
mkdir(fullfile(pwd,'Analysis_Concatenated_RT_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked','Beta'));
cd ..

GroupAnalysisFolder = strcat(pwd, filesep, 'SecondLevel', filesep, 'Analysis_Concatenated_RT_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', filesep, 'Beta', filesep);


for j=1:length(ListOfTest)

    matlabbatch = {};

    matlabbatch{1,1}.spm.stats.factorial_design.cov = struct('name',{},'levels',{});

    matlabbatch{1,1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.masking.em = cell(1,1);

    matlabbatch{1,1}.spm.stats.factorial_design.globalc.g_omit = 1;

    matlabbatch{1,1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1,1}.spm.stats.factorial_design.globalm.glonorm = 1;



    cd (GroupAnalysisFolder)

    if exist(ListOfTest{j},'dir')==0
        mkdir (ListOfTest{j});
    end;

    cd (ListOfTest{j})

    matlabbatch{1,1}.spm.stats.factorial_design.dir = {pwd};

    for i=1:length(SubjectsListTemp)
        
        A = strcat(PresentFolder, filesep, num2str(SubjectsListTemp(i)), filesep, ...
            'Analysis_Concatenated_RT_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', filesep, ...
            'con_00');
        
        B = num2str(ContrastOfInterest(j));
        B(B==' ')='0';
        if size(B,2)==1
            B=[['0'] B];
        end

        matlabbatch{1,1}.spm.stats.factorial_design.des.t1.scans{i,1} = strcat(A, B(1,:) ,'.img,1');
       
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

    save (strcat('Second_Level_TTest_', (ListOfTest{j}) , '_jobs'));

    spm_jobman('run', matlabbatch)


    % Load the right SPM.mat
    cd (ListOfTest{j})
    load SPM.mat
                   
    cname = ListOfContrastNames{j};
    c = 1;
    SPM.xCon = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);


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
    

    cd (PresentFolder)

end