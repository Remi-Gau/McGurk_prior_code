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

A{5,1} = 'McGurk_in_Congruent_trials_Wrong-Visual-Missed_answers';
A{10,1} = 'Congruent_trials_Wrong-Visual-Fused-Missed_answers';
A{15,1} = 'McGurk_in_Incongruent_trials_Wrong-Visual-Missed_answers';
A{20,1} = 'Incongruent_trials_Wrong-Fused-Missed_answers';

A([1 2 6 7 9 11 12 16 19], :) = [];

Conditions_Names = char(A);

clear A i j

RealParam = 6;

% Subject's Identity and Session number
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];


try

    for h=1:length(SubjectsList)
        
        SubjID=num2str(SubjectsList(h))

        
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Percept_BetweenOnset_100SecsBlocks_TimeDer_200HPF_Despiked', filesep);

        
        cd(AnalysisFolder)
        load ('SOT.mat', 'Sorted_SOT')
    
        cellfun('length', Sorted_SOT)
        X = ~cellfun('isempty', Sorted_SOT)
        
        NbRegressors = length(X(X==1))*2+(RealParam+1+4)*size(X,2)
                            

        % Load the right SPM.mat
        cd(AnalysisFolder)
        load SPM.mat

        % Defines the contrasts
        for i=1:size(X,1)       
            if sum(X(i,:))==0
            else
                
                Z = [];
                
                for j=1:size(X,2)
                    if X(i,j)==0
                        Z = [Z zeros(1,2*length(X(X(:,j)==1))) zeros(1,4) zeros(1,RealParam)];
                    else
                        Z = [Z zeros(1,2*length(X(X(1:i-1,j)==1))) 1 0 zeros(1,2*length(X(X(i+1:end,j)==1))) zeros(1,4) zeros(1,RealParam)];
                    end
                end

                Z = [Z zeros(1,size(X,2))];

                cname = Conditions_Names(i,:);
                
                if i==1
                    SPM.xCon = spm_FcUtil('Set', cname, 'T', 'c', Z(:), SPM.xX.xKXs);
                else
                    SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', Z(:), SPM.xX.xKXs);
                end
                
            end
        end
        
        Z_CON = [];
        Z_INC = [];
        
        for j=1:size(X,2)
            Z_CON = [Z_CON zeros(1, 2*sum(X(:,j))) 1 0 0 0 zeros(1,RealParam)];
            Z_INC = [Z_INC zeros(1, 2*sum(X(:,j))) 0 0 1 0 zeros(1,RealParam)];
        end
                       
        Z_CON = [Z_CON zeros(1,size(X,2))];
        Z_INC = [Z_INC zeros(1,size(X,2))];
        
        cname = 'CON_Block';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', Z_CON(:), SPM.xX.xKXs);
        
        cname = 'INC_Block';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', Z_INC(:), SPM.xX.xKXs);
        

        % Evaluate
        spm_contrasts(SPM);

        
        cd (PresentFolder)
        
        fprintf('\nThe analysis of the subject %s is done.\n\n', SubjID);

    end
    
catch
    lasterror
end 
