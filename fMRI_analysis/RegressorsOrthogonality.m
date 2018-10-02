%%
clear
clc

StartFolder=pwd;

SubjectsList = [1 13 14 15 24 28 32 41 48 66 69 73 74 82 98 61];


%%

Ortho = cell(2, length(SubjectsList));

for i=1:length(SubjectsList)
    
    SubID = SubjectsList(i);
    
    cd (strcat(pwd, filesep, num2str(SubID), filesep, 'Analysis_Stimulus_BetweenOnset_100ExpBlock_TimeDer_200HPF_Despiked'))

    load SPM.mat
    
    NbSession = length(SPM.Sess);
    
    FirstScan = 1;
    LastScan = SPM.nscan(1);
    
    FirstRegressor = 3;
    SecondRegressor = 9;
    
    DesignMatrix = SPM.xX.X;

    for j=1:NbSession

        Orthogonality(j) = [DesignMatrix([FirstScan:LastScan],FirstRegressor)' * ...
                            DesignMatrix([FirstScan:LastScan],SecondRegressor) / ...
                            (sum(DesignMatrix([FirstScan:LastScan],FirstRegressor).^2) * ... 
                            sum(DesignMatrix([FirstScan:LastScan],SecondRegressor).^2) )^.5];
                        
        FirstScan = LastScan+1;
        LastScan = LastScan+SPM.nscan(j);
        
        FirstRegressor = FirstRegressor + 16 ;
        SecondRegressor = SecondRegressor +16 ;
    end
    
    Ortho{1,i} = Orthogonality;
    A(i) = mean(Orthogonality);
    
    clear SPM
    
    cd(StartFolder)
    
end

A