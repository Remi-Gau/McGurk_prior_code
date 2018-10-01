clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults


%  Folders definitions
cd ..
PresentFolder = pwd;

% Conditions Names
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

clear A i j

RealParam = 6;

% Subject's Identity and Session number
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98]
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98]

try

    for h=1%:length(SubjectsList)
        
        SubjID=num2str(SubjectsList(h))

        
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        SubjectStructuralFolder = strcat(pwd, filesep, SubjID, filesep, 'Structural', filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Percept_BetweenOnset_83ExpBlocks_TimeDer_200HPF_Despiked', filesep);

        
        cd(AnalysisFolder)
        
        delete spmT*.*
        delete con*.*
        
        load ('SOT.mat', 'Sorted_SOT')
    
        TrialsPerSess = cellfun('length', Sorted_SOT)
        CondExistInSess = ~cellfun('isempty', Sorted_SOT)
                                  

        % Load the right SPM.mat
        cd(AnalysisFolder)
        load SPM.mat
        SPM.swd = pwd;
        save('SPM.mat', 'SPM')
        NbRegressors = size(SPM.xX.X,2);
        
        SPM.xCon = struct([]);

        %% Defines the contrasts for the events
        for i=1:size(CondExistInSess,1)
            
            Weight = sum(CondExistInSess(i,:));
            
            if sum(CondExistInSess(i,:))==0
                Z = [1 zeros(1,size(SPM.xX.X,2)-1)];
                cname = 'Dummy Contrast';   
                
            else
                Z = [];
                
                for j=1:size(CondExistInSess,2)
                    if CondExistInSess(i,j)==0
                        Z = [Z zeros(1,2*length(CondExistInSess(CondExistInSess(:,j)==1))) zeros(1,2) zeros(1,RealParam)];
                    else
                        Z = [Z zeros(1,2*length(CondExistInSess(CondExistInSess(1:i-1,j)==1))) 1/Weight 0 zeros(1,2*length(CondExistInSess(CondExistInSess(i+1:end,j)==1))) zeros(1,2) zeros(1,RealParam)];
                    end
                end
                
                cname = Conditions_Names(i,:);
                
                Z = [Z zeros(1,size(CondExistInSess,2))];
                
            end
            
            if isempty(SPM.xCon)
                SPM.xCon = spm_FcUtil('Set', cname, 'T', 'c', Z(:), SPM.xX.xKXs);
            else
                SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', Z(:), SPM.xX.xKXs);
            end
            
        end
        
        clear Weight
        
        %% Defines the contrasts for the blocks
        Z_CON = [];
        Z_INC = [];
        
        for j=1:size(CondExistInSess,2)
            Z_CON = [Z_CON zeros(1, 2*sum(CondExistInSess(:,j))) 1  0  zeros(1,RealParam)];
            Z_INC = [Z_INC zeros(1, 2*sum(CondExistInSess(:,j))) 0  1  zeros(1,RealParam)];
        end
                       
        Z_CON = [Z_CON zeros(1,size(CondExistInSess,2))];
        Z_INC = [Z_INC zeros(1,size(CondExistInSess,2))];
        
        cname = 'CON_Block';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', Z_CON(:), SPM.xX.xKXs);
        
        cname = 'INC_Block';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', Z_INC(:), SPM.xX.xKXs);
        
        cname = 'CON_Block > INC Block';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', Z_CON(:)-Z_INC(:), SPM.xX.xKXs);
        
        cname = 'INC_Block > CON Block';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', Z_INC(:)-Z_CON(:), SPM.xX.xKXs);
        
        cname = 'INC_Block + CON Block > Baseline';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', Z_INC(:)+Z_CON(:), SPM.xX.xKXs);
        
        
        %% Defines the contrasts for the joint events
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
        
%         JointContrastsNames = {'All Congruent Trials' 'All Incongruent Trials' 'All McGurk Trials' 'All Incongruent and McGurk Trials'...
%                                'Incongruent trials wrong visual fused answers' ...
%                                'McGurk trials auditory answers' 'McGurk trials wrong visual fused answers' ...
%                                'McGurk trials in congruent context : Fused+Auditory' 'McGurk trials in incongruent context: Fused+Auditory' 'McGurk trials Fused+Auditory' 'McGurk trials fused answers' 'McGurk trials non fused answers'};
% 
%         ContrasOfInterest = { 4:5 ; 9:11 ; [1:3 6:8] ; [1:3 6:11] ; ...
%                               9:10 ; ...
%                               [2 7] ; [1 3 6 8] ; ...
%                               2:3 ; [7 8] ; [2 3 7 8] ; [3 8] ; [1 2 6 7]};

        JointContrastsNames = { 'All Congruent Trials' 
                                'All Incongruent Trials' 
                                'All McGurk in Congruent Trials'
                                'All McGurk in Congruent Trials'
                                'All non McGurk Auditory answers'
                                'All non McGurk Trials'};

        ContrasOfInterest = { 4:5 ; 
                              9:11 ; 
                              1:3;
                              6:8;
                              [4 11];
                              [4:5 9:11]};

               
        for i=1:length(JointContrastsNames)
            
            % 1 - Do not include regressors if less than 10 events accross
            % all sessions
            Y = sum(TrialsPerSess(ContrasOfInterest{i},:),2)>9;
            
%             Y = TrialsPerSess(ContrasOfInterest{i},:);
%             Y(Y<10)=0;
%             Y = Y/sum(Y(:));
            
            Z = [];
            
            for j=1:size(CondExistInSess,2)
                
                A = zeros(2, size(CondExistInSess,1));
                
                
                for k=1:length(ContrasOfInterest{i})
                    % 1
                    if Y(k)
                    Weight = sum(CondExistInSess(ContrasOfInterest{i}(k),:));
                    A(1,ContrasOfInterest{i}(k))=1/Weight;
                    end
                end

%                 A(1,:) = Y(:,j);
                           
                A(:,CondExistInSess(:,j)==0)=[];
                
                A = reshape(A,1,size(A,1)*size(A,2));
   
                Z = [Z A zeros(1,8)];
                
            end
            
            Z = [Z zeros(1,size(CondExistInSess,2))];

            
            cname = JointContrastsNames{i};
            SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', Z(:), SPM.xX.xKXs);
        end
        
        
        %% Defines the contrasts for the ALL events
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

        
        JointContrastsNames = {'All Events Trials'};

        ContrasOfInterest = {[2:4 7:8 11]};  
        ContrasOfInterest = {1:12};  
        
        Y = TrialsPerSess;
%         Y([1 5 6 9 10 12],:)=0
%         Y(Y<10)=0;
        Y = Y/sum(Y(:));

        for i=1:length(JointContrastsNames)
                       
            Z = [];
            
            for j=1:size(CondExistInSess,2)
                
                A = zeros(2, size(CondExistInSess,1));

                A(1,:) = Y(:,j);
                           
                A(:,CondExistInSess(:,j)==0)=[];
                
                A = reshape(A,1,size(A,1)*size(A,2));
   
                Z = [Z A zeros(1,8)];
                
            end
            
            Z = [Z zeros(1,size(CondExistInSess,2))];

            
            cname = JointContrastsNames{i};
            SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', Z(:), SPM.xX.xKXs);
        end
        
        
        
%% Defines the differential contrasts with all sessions
%         clear ContrasOfInterest Weight
%         DifferentialContrastsNames ={'INC_A > CON_A' ...
%                                      'MG_A > MG_F' ...
%                                      '(MG_A + MG_F)_INC > (MG_A + MG_F)_CON' ...
%                                      '(MG_F - MG_A)_CON' ... 
%                                      '(MG_A - MG_F)_INC' ...
%                                      '(MG_A_)_INC > (MG_A_)_CON'};
%         
%         ContrasOfInterest = { 10   ,  4 ; ...
%                               [2 7], [3 8] ; ...
%                               [7 8], [2 3] ; ...
%                               3,  2 ; ...
%                               7,  8; ...
%                               7, 2};
%                                                    
%         for i=1:length(DifferentialContrastsNames)
%             
%             Z = [];
%             
%             for j=1:2
%                 Weight{1,j} = ones(1,length(ContrasOfInterest{i,j}));
%                 for k=1:length(ContrasOfInterest{i,j})
%                     Weight{1,j}(k) = 1/sum(X(ContrasOfInterest{i,j}(k),:));
%                 end
%             end
%        
%             for j=1:size(X,2)
% 
%                 A = zeros(2, size(X,1));
% 
%                 A(1,ContrasOfInterest{i,1})=Weight{1,1};
%                 A(1,ContrasOfInterest{i,2})=-Weight{1,2};
% 
%                 A(:,X(:,j)==0)=[];
% 
%                 A = reshape(A,1,size(A,1)*size(A,2));
% 
%                 Z = [Z A zeros(1,8)];
% 
%             end
% 
%             Z = [Z zeros(1,size(X,2))];
%             cname = DifferentialContrastsNames{i};
%             
%             SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', Z(:), SPM.xX.xKXs);
%         end
        
        
%% Evaluate
        spm_contrasts(SPM);

        
%% Make a masked image of the subject structural
        imgsMat{1,1} = strcat(pwd, filesep, 'mask.hdr');
        
        try
            
            cd(SubjectStructuralFolder)
            
            StructuralList = dir('ws*.img');        
            imgsMat{2,1} = strcat(pwd, filesep, StructuralList(1).name);
            
            imgsInfo = spm_vol(char(imgsMat));

            volumes = spm_read_vols(imgsInfo);

            A = volumes(:,:,:,1);

            Test = volumes(:,:,:,2);

            Test(A==0)=Test(A==0)*0.5;

            % spm_write_vol: writes an image volume to disk
            newImgInfo = imgsInfo(2);

            % Change the name in the header
            cd(AnalysisFolder)
            
            newImgInfo.fname = strcat(pwd, filesep, 'StructuralMasked.nii');
            newImgInfo.private.dat.fname = newImgInfo.fname;

            spm_write_vol(newImgInfo, Test);
            
        catch ME1
        end
        
        cd(PresentFolder)
        
        fprintf('\nThe analysis of the subject %s is done.\n\n', SubjID);

    end
    
catch ME2
    rethrow(ME2)
end 
