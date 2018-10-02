clear all; close all; clc;

%  Folders definitions
StartFolder = pwd;

% Subject's Identity and Session number
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98]

Contrast2Check = [2 3 4 7 8 11 13 14];

for ConInd = 1:length(Contrast2Check)
    
    for SubjInd = 1:length(SubjectsList)
        
        SubjID=num2str(SubjectsList(SubjInd));
        SubjectFolder = fullfile(StartFolder, SubjID);
        %AnalysisFolder = fullfile(SubjectFolder, 'Analysis_Percept_BetOnset_100ExpBlock_TimeDer200HPF_Mvt_Despiked_Denoise_3');
        AnalysisFolder = fullfile(SubjectFolder, 'Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked');
        
        cd(AnalysisFolder)
        
        load SPM.mat

        if size(SPM.xCon(Contrast2Check(ConInd)).c,2)==1
            if SubjInd==1
                fprintf(['\n\n' SPM.xCon(Contrast2Check(ConInd)).name '\n\n'])
            end
            
            SubjID
            
            TEMP=[];
            RegressorsNames=[];
            InputedBetas=[];
            
            TEMP = logical(SPM.xCon(Contrast2Check(ConInd)).c);
            RegressorsNames = char(SPM.xX.name');
            InputedBetas = RegressorsNames(TEMP,:)
        end
        
    end
    
    cd(StartFolder)
    
end