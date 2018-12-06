clear 
clc

cd ..
StartFolder = pwd;

% Subjects
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];

for SubjInd=1:length(SubjectsList)
        
        SubjID=num2str(SubjectsList(SubjInd));
        
        SubjectFolder = fullfile(StartFolder, SubjID);
        AnalysisFolder = fullfile(SubjectFolder, 'Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked');
        
        cd (AnalysisFolder)
        load SPM.mat
        
        B = char(SPM.xX.name');
        
        for ConInd = length(SPM.xCon)
            SPM.xCon(ConInd).name
            A = find(SPM.xCon(ConInd).c);
            
            B(A,:)
            
        end
end

cd(StartFolder)