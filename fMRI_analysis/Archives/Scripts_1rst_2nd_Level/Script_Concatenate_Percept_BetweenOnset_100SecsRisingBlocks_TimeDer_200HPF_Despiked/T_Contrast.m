clc
clear
 
spm_jobman('initcfg')
spm_get_defaults;
global defaults


%%  Folders definitions
cd ..
StartingDirectory = pwd;


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
% Subject's Identity
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98]

try

    for h=1:length(SubjectsList)
        
        SubjID=num2str(SubjectsList(h))

        
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        SubjectStructuralFolder = strcat(pwd, filesep, SubjID, filesep, 'Structural', filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Concatenated_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', filesep);
        
        cd(AnalysisFolder)
        
        delete spmT*.*
        delete con*.*
        
        load ('SOT.mat', 'Sorted_SOT')
    
        A = cellfun('length', Sorted_SOT)
        
        X = ~cellfun('isempty', Sorted_SOT)
        
        
                                   
        % Load the right SPM.mat
        cd(AnalysisFolder)
        load SPM.mat        
        
        SPM.xCon = struct([]);

        Counter = 1;
        EmptyRegressors = [];
        % Defines the contrasts for the events > baseline
        for i=1:size(X,1)
            % Check if this condition has at least one trial
            % If not it creates a dummy contrast
            if sum(X(i,:))==0
                EmptyRegressors = [EmptyRegressors i];
                cname = 'Dummy contrast';
                c = ones(1, size(SPM.xX.X,2)); 
                if length(SPM.xCon) == 0
                    SPM.xCon = spm_FcUtil('Set', cname, 'T', 'c', c(:), SPM.xX.xKXs);
                else
                    SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T', 'c', c(:), SPM.xX.xKXs);
                end
            else
                
                cname = strcat(Conditions_Names(i,:), ' > Baseline');
                
                c = zeros(1, size(SPM.xX.X,2));
                c(Counter*2-1) = 1; 
                
                if length(SPM.xCon) == 0
                    SPM.xCon = spm_FcUtil('Set', cname, 'T', 'c', c(:), SPM.xX.xKXs);
                else
                    SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T', 'c', c(:), SPM.xX.xKXs);
                end
                
                Counter = Counter + 1;
                
            end
        end

        
        
        % Defines the contrasts for the blocks > baseline
        cname = 'CON_Block';
        A = zeros(1, size(SPM.xX.X,2));
        A(Counter*2-1) = 1;
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', A(:), SPM.xX.xKXs);
        
        cname = 'INC_Block';
        B = zeros(1, size(SPM.xX.X,2));
        B(Counter*2) = 1;
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', B(:), SPM.xX.xKXs);       
        
             
        % Defines the differential contrasts for the events
        DifferentialContrastsNames ={'INC > CON', ...
                                     'INC_A > CON_A' ...
                                     'MG_A > MG_F' ...
                                     '(MG_A + MG_F)_INC > (MG_A + MG_F)_CON' ...
                                     'Interaction : (MG_F - MG_A)_CON > (MG_A - MG_F)_INC'};
        
        ContrasOfInterest = { [9 10 11], [4 5]; ...
                               11  ,  4 ; ...
                              [2 7], [3 8] ; ...
                              [7 8], [2 3] ; ...
                              [3 7], [2 8]};
                          
        TEMP = ones(1,length(X));
        TEMP(EmptyRegressors) = 0;
        TEMP = cumsum(TEMP);
                              
        for i=1:length(DifferentialContrastsNames)
            
            if ~any(X([ContrasOfInterest{i,1} ContrasOfInterest{i,2}]))
                cname = 'Dummy contrast';
                c = ones(1, size(SPM.xX.X,2));
                if length(SPM.xCon) == 0
                    SPM.xCon = spm_FcUtil('Set', cname, 'T', 'c', c(:), SPM.xX.xKXs);
                else
                    SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T', 'c', c(:), SPM.xX.xKXs);
                end
            else
                c = zeros(1, size(SPM.xX.X,2));
                if i==1
                    c(TEMP(ContrasOfInterest{i,1})*2-1) = 1/3; 
                    c(TEMP(ContrasOfInterest{i,2})*2-1) = -1/2; 
                else
                    c(TEMP(ContrasOfInterest{i,1})*2-1) = 1; 
                    c(TEMP(ContrasOfInterest{i,2})*2-1) = -1; 
                end

                cname = DifferentialContrastsNames{i};
                if length(SPM.xCon) == 0
                    SPM.xCon = spm_FcUtil('Set', cname, 'T', 'c', c(:), SPM.xX.xKXs);
                else
                    SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T', 'c', c(:), SPM.xX.xKXs);
                end
            end
        end
        
        % Defines the differential contrasts for the blocks
        cname = 'CON_Block > INC_Block';
        c = [A-B];
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);
        
        cname = 'INC_Block > CON_Block';
        c = -c;
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

        
% -------------------------------------------------------------------------               
        % Evaluate
        spm_contrasts(SPM);

        
        
% -------------------------------------------------------------------------        
        % Make a masked image of the subject structural
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
        
        cd(StartingDirectory)
        
        fprintf('\nThe analysis of the subject %s is done.\n\n', SubjID);

    end
    
catch ME2
    %rethrow(ME1)
    rethrow(ME2)
end 
