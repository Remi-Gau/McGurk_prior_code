%%

clc
clear

% spm_jobman('initcfg')
% spm_get_defaults;
% global defaults

cd ..
StartFolder = pwd;

% Subjects
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];


ListOfTest = {'McGurk_in_Congruent_trials_Wrong-Visual_answers  '; ... % 1
    'McGurk_in_Congruent_trials_Auditory_answers      '; ...  % 2
    'McGurk_in_Congruent_trials_Fused_answers         '; ... % 3
    'Congruent_trials_Auditory-Visual_answers         '; ... % 4
    'Congruent_trials_Wrong-Fused_answers             '; ...  % 5
    'McGurk_in_Incongruent_trials_Wrong-Visual_answers'; ...  % 6
    'McGurk_in_Incongruent_trials_Auditory_answers    '; ...  % 7
    'McGurk_in_Incongruent_trials_Fused_answers       '; ...  % 8
    'Incongruent_trials_Wrong-Fused_answers           '; ... % 9
    'Incongruent_trials_Visual_answers                '; ...  % 10
    'Incongruent_trials_Auditory_answers              '; ...  % 11
    'Missed_trials                                    '; ...  % 12
%     'CON_Block' % 13
%     'INC_Block' % 14
%     'CON_Block > INC Block' % 15
%     'INC_Block > CON Block' % 16
    
     'INC_Block + CON Block > Baseline' ; ... % 17
     'All Congruent Trials' ; ... % 18
     'All Incongruent Trials' ; ... % 19
     'All McGurk in Congruent Trials' ; ... % 20
     'All McGurk in Incongruent Trials'; ... % 21
     'All non McGurk Auditory answers'; ...  % 22
     'All non McGurk Trials'; ... % 23
     'All events'} ;  % 24
    
%     'CON_Block > INC Block' % 15
%     'INC_Block > CON Block' % 16

%     'All Congruent Trials'; ...  % 17
%     'All Incongruent Trials'; ...  % 18
%     'All McGurk Trials'; ...  % 19
% %     'All Incongruent and McGurk Trials' % 20
%     'Incongruent trials wrong visual fused answers'; ...  % 21
% %     'McGurk trials auditory answers'; ...  % 22
%     'McGurk trials wrong visual fused answers'; ...  % 23
%     'McGurk trials in congruent context : Fused+Auditory'; ...  % 24
%     'McGurk trials in incongruent context: Fused+Auditory'; ...  % 25
%     'McGurk trials auditory answers'; ...  % 26
%     'McGurk trials fused answers'; ...  % 27
%     'McGurk trials non fused answers'; ...  % 28
%     'All Events Trials'}; % 29



ContrastOfInterest = [1:12 17:24];


%%
for SubjInd=1:length(SubjectsList)
    
    SubjID=num2str(SubjectsList(SubjInd));
    
    SubjectFolder = fullfile(StartFolder, SubjID);
    AnalysisFolder = fullfile(SubjectFolder, 'Analysis_Percept_BetweenOnset_83ExpBlocks_TimeDer_200HPF_Despiked');
    
    cd(AnalysisFolder)
    load ('SOT.mat', 'Sorted_SOT')
    
    NbTrials(:,SubjInd) = sum(cellfun('length', Sorted_SOT),2);
    
    NbTrialsDetail{SubjInd} = cellfun('length', Sorted_SOT);
    
    EngouhTrialsPerSession(:,SubjInd) = sum(cellfun('length', Sorted_SOT)>=10,2);
    
    clear Sorted_SOT
    
    %         load SPM.mat
    %         for CondInd=1:12
    %                     CondPresAllSess(CondInd,SubjInd) = ~all(SPM.xCon(CondInd).c');
    %
    %         end
    
end



% % Mc Gurk in congruent
% Sorted_SOT{1,i} % Wrong and visual trials together
% Sorted_SOT{2,i} % Auditory trials OK
% Sorted_SOT{3,i} % Fused trials OK
%
% % Congruent
% Sorted_SOT{4,i} % Auditory and visual trials OK
% Sorted_SOT{5,i} % Wrong and fused trials together
%
% % Mc Gurk in incongruent
% Sorted_SOT{6,i} % Wrong and visual trials together
% Sorted_SOT{7,i} % Auditory trials OK
% Sorted_SOT{8,i} % Fused trials OK
%
% % Incongruent
% Sorted_SOT{9,i} % Wrong and Fused trials OK
% Sorted_SOT{10,i} % Visual trials
% Sorted_SOT{11,i} % Auditory trials OK
%
% % Missed trials
% Sorted_SOT{12,i} % Missed trials OK

Include = NbTrials>=10;

Include(end+1:end+8,:) = ones(8,16);

% Include(end+1,:) = all(Include(4:5,:),1); % 'All Congruent Trials'
% Include(end+1,:) = all(Include(9:11,:),1); % 'All Incongruent Trials'
% Include(end+1,:) = all(Include([1:3 6:8],:),1); % 'All McGurk Trials'
% 
% Include(end+1,:) = all(Include(9:10,:),1); % 'Incongruent trials wrong visual fused answers'
% 
% Include(end+1,:) = all(Include([1 3 6 8],:),1); % 'McGurk trials wrong visual fused answers'
% Include(end+1,:) = all(Include([2 3],:),1); % 'McGurk trials in congruent context : Fused+Auditory'
% Include(end+1,:) = all(Include([7 8],:),1); % 'McGurk trials in incongruent context: Fused+Auditory'
% Include(end+1,:) = all(Include([2 7],:),1); % 'McGurk trials auditory answers'
% Include(end+1,:) = all(Include([3 8],:),1); % 'McGurk trials fused answers'
% Include(end+1,:) = all(Include([1 2 6 7],:),1); % 'McGurk trials non fused answers'
% Include(end+1,:) = all(Include(1:12,:),1); %  'All Events Trials'


%%
mkdir(fullfile(StartFolder, 'SecondLevel', 'Analysis_Percept_BetweenOnset_83ExpBlocks_TimeDer_200HPF_Despiked'))
cd(fullfile(StartFolder, 'SecondLevel', 'Analysis_Percept_BetweenOnset_83ExpBlocks_TimeDer_200HPF_Despiked'));
GroupAnalysisFolder = fullfile(StartFolder, 'SecondLevel', 'Analysis_Percept_BetweenOnset_83ExpBlocks_TimeDer_200HPF_Despiked', 'TTest2');
mkdir(GroupAnalysisFolder)

for TestInd=1:length(ListOfTest)
    
    SubjectsListTemp = SubjectsList(Include(TestInd,:));
    
    ListOfTest{TestInd}
    SubjectsListTemp
    length(SubjectsListTemp)

    
    if length(SubjectsListTemp)>10
        
        matlabbatch = {};
        
        matlabbatch{1,1}.spm.stats.factorial_design.cov = struct('name',{},'levels',{});
        
        matlabbatch{1,1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{1,1}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{1,1}.spm.stats.factorial_design.masking.em = cell(1,1);
        
        matlabbatch{1,1}.spm.stats.factorial_design.globalc.g_omit = 1;
        
        matlabbatch{1,1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{1,1}.spm.stats.factorial_design.globalm.glonorm = 1;
        
        cd (GroupAnalysisFolder)
        
        if exist(ListOfTest{TestInd},'dir')==0
            mkdir (ListOfTest{TestInd});
        end;
        
        cd (ListOfTest{TestInd})
        delete *.*
        
        matlabbatch{1,1}.spm.stats.factorial_design.dir = {pwd};
        
        
        for i=1:length(SubjectsListTemp)
            
            A = strcat(StartFolder, filesep, num2str(SubjectsListTemp(i)), filesep, ...
                'Analysis_Percept_BetweenOnset_83ExpBlocks_TimeDer_200HPF_Despiked', filesep, ...
                'con_00');
            
            B = num2str(ContrastOfInterest(TestInd));
            B(B==' ')='0';
            if size(B,2)==1
                B=['0' B];
            end
            
            matlabbatch{1,1}.spm.stats.factorial_design.des.t1.scans{i,1} = strcat(A, B(1,:) ,'.img,1');
            
            clear A B
        end
        

        

        %% Estimate model
        matlabbatch{1,end+1}={};
        matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = fullfile(pwd, 'SPM.mat');     %set the spm file to be estimated
        matlabbatch{1,end}.spm.stats.fmri_est.method.Classical = 1;
        
        save (strcat('Second_Level_TTest_', (ListOfTest{TestInd}) , '_jobs'));
        
        spm_jobman('run', matlabbatch)
                
        %% Load the right SPM.mat
        load SPM.mat
        
        cname = ListOfTest{TestInd};
        c = 1;
        SPM.xCon = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);
        
        
        % Evaluate
        spm_contrasts(SPM);
        
    end

    cd (StartFolder)
    
end