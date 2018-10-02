%%
clc
clear

%  Folders definitions
PresentFolder = pwd;

% Subject's Identity and Session number
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98]

%%
for h=1:length(SubjectsList)
    
    SubjID=num2str(SubjectsList(h))
    
    
    SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
    AnalysisFolder = strcat(SubjectFolder, 'Analysis_Concatenated_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', filesep);
    
    cd(AnalysisFolder)
    
    load ('SOT.mat', 'Sorted_SOT')
    
    cellfun('length', Sorted_SOT)
    X = ~cellfun('isempty', Sorted_SOT)
    
    cd(PresentFolder)
    
end

%%
for SubjInd=1:length(SubjectsList)
    
    SubjID=num2str(SubjectsList(SubjInd));
    
    cd(fullfile(pwd, SubjID, 'Behavioral'));

    FilesList = dir('Subject_*.mat');
    
    for FileInd=1:length(FilesList)
        load (FilesList(FileInd).name, 'ExternalVolumeSoundLevel')
        TEMP(FileInd) = ExternalVolumeSoundLevel;
    end
    
    SoundLevel(SubjInd) = mean(TEMP);
    
    clear TEMP
   
    
    cd(PresentFolder)
    
end