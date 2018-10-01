clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

cd ..
StartFolder = pwd;

ListOfContrastNames = {'Percent_MG_A_CON_VS_CON_Block' ; ...
                       'Percent_MG_F_CON_VS_CON_Block' ; ...
                       'Percent_MG_A_INC_VS_INC_Block' ; ...
                       'Percent_MG_F_INC_VS_INC_Block'; ...
                       'Difference_Percent_MG_A_INC-MG_A_CON_VS_INC>CON_Block' ; ...
                       'Difference_Percent_MG_F_INC-MG_F_CON_VS_INC>CON_Block'; ...
                       %
                       'Percent_MG_F_VS_MG_trials'; ...
                       'Percent_MG_F_VS_(MG_A>MG_F)'; ...
                       %
                       'Difference_Percent_MG_F_VS_(INC_A>CON_A)'; ...
                       'Difference_Percent_MG_F_VS_(MG_A+MG_F)_INC>(MG_A+MG_F)_CON'; ...
                    %  'Difference Percent MG_F VS (MG_A+MG_F)_INC>(MG_A+MG_F)_CON'; 32
                   
                       'Percent MG_F_INC VS MG_A_INC'; ... % Contrast: 7 
                       'Percent MG_F_INC VS (MG_A+MG_F)_INC'; ... % Contrast: 25
                   
                       'Difference Percent MG_F VS MG_A_INC>MG_A_CON'}; % Contrast: 35
                   
                   
                   
                   
                   
ListOfContrastOfInterests = [13 13 14 14 16 16 19 31 30 32 7 25 35];                  

SubjectsList = [1 13 14 15 24 28 32 41 48 66 69 73 74 82 98 61];

%% Remove subjects with less than 10 trials per condition
for h = 1:length(SubjectsList)

        SubjID = num2str(SubjectsList(h));

        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', filesep);

        cd(AnalysisFolder)
        load SOT.mat
        
        X(:,h) = sum(~cellfun('isempty', Sorted_SOT),2)>0;

        Y(:,h) = sum(cellfun('length', Sorted_SOT),2);
        
%         load SPM
%         
%         {SPM.xCon(ListOfContrastOfInterests).name}'
%         
%         clear SPM

        cd(StartFolder)
end

%%
Y(end+1:end+4,:) = 20*ones(4,length(SubjectsList));

ConditionsToCheck = {~Y(13,:) < 10;
                     ~Y(13,:) < 10;
                     ~Y(14,:) < 10;
                     ~Y(14,:) < 10;
                     ~Y(16,:) < 10;
                     ~Y(16,:) < 10;
                     ~sum(Y([1:3 6:8],:)) < 10;
                     ~any([sum(Y([2 7],:)) ; sum(Y([3 8],:))] < 10);
                     ~any([Y(4,:) ; Y(11,:)] < 10);
                     ~any([sum(Y([2 3],:)); sum(Y([7 8],:))] < 10);
                     ~Y(7,:) < 10;
                     ~any([Y(7,:); Y(8,:)] < 10);
                     ~any([Y(7,:); Y(2,:)] < 10)};
              

clear X SubjID SubjectFolder AnalysisFolder

%%
cd SecondLevel
mkdir Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked;
load('GroupResponsesNoMiss.mat')

% Files to load
MatFilesList = dir ('Results*.mat');
SizeMatFilesList = size(MatFilesList,1);

A = zeros(1,SizeMatFilesList);

for Subject=1:SizeMatFilesList
    load(MatFilesList(Subject).name, 'McGURKinConPerSess', 'McGURKinINCPerSess')
    A(Subject) = sum(McGURKinConPerSess(4,:) + McGURKinINCPerSess(4,:)) / ...
                sum(sum(McGURKinConPerSess(1:4,:) + McGURKinINCPerSess(1:4,:)));
end

%%

cd Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked;
mkdir Correlation

cd Correlation
GroupAnalysisFolder =pwd;

CorrelationVectors = [squeeze(GroupResponsesNoMiss(3,3,:)) squeeze(GroupResponsesNoMiss(3,4,:)) ...
                      squeeze(GroupResponsesNoMiss(4,3,:)) squeeze(GroupResponsesNoMiss(4,4,:)) ...
                      squeeze(GroupResponsesNoMiss(4,3,:))-squeeze(GroupResponsesNoMiss(3,3,:)) ...
                      squeeze(GroupResponsesNoMiss(4,4,:))-squeeze(GroupResponsesNoMiss(3,4,:)) ...
                      A' ...
                      A' ...
                      squeeze(GroupResponsesNoMiss(4,4,:))-squeeze(GroupResponsesNoMiss(3,4,:)) ...
                      squeeze(GroupResponsesNoMiss(4,4,:))-squeeze(GroupResponsesNoMiss(3,4,:)) ...
                      squeeze(GroupResponsesNoMiss(4,4,:)) squeeze(GroupResponsesNoMiss(4,4,:)) ...
                      squeeze(GroupResponsesNoMiss(4,4,:))-squeeze(GroupResponsesNoMiss(3,4,:))];
                 
%%                  
for j=1:length(ListOfContrastNames)

    SubjectsListTemp = SubjectsList(ConditionsToCheck{j})
    CorrelationVectorsTemp = CorrelationVectors(ConditionsToCheck{j},j);


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
    
    clear A ContrastsFilesList CorrelationVectorsTemp ContrastsTemp YTemp SubjectsListTemp
    
    
    
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

end