%%
clc; clear all;

TR = 2.56;
NbSlices = 42;
ReferenceSlice = 21;

Condition_Duration = 0;

VideoToAudioOnsetDelay = (1-0.04*8)/2;

%% Define HRF
SPM.xBF.UNITS = 'secs';
SPM.xBF.dt = TR/NbSlices; % Temporal resolution in seconds of the informed basis set you are going to create
SPM.xBF.name = 'hrf';
SPM.xBF.length = 32; % Length of the HRF in seconds
SPM.xBF.order = 2;

SPM.xBF = spm_get_bf(SPM.xBF); % Creates the informed basis set

bf = SPM.xBF.bf;

clear SPM

%%

%  Folders definitions
cd ..
StartingDirectory = pwd;

% Conditions Names
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

clear A j i

%%
% Subject's Identity
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];

tic

for h=1:1 %length(SubjectsList)
    
    SubjID=num2str(SubjectsList(h))
    
    %--------------------------------------------------------------------------
    %  Folders definitions
    cd (StartingDirectory)
    SubjectFolder = fullfile(pwd, SubjID);
    
    NiftiSourceFolder = fullfile(SubjectFolder, 'Nifti_EPI_Despiked');
    
    BehavioralFolder = fullfile(SubjectFolder, 'Behavioral');
    
    AnalysisFolder = fullfile(SubjectFolder, 'Analysis_Percept_BetOnset_100ExpBlock_TimeDer_Despiked_Denoise', filesep);
    
    mkdir(AnalysisFolder)
    
    
    %--------------------------------------------------------------------------
    % Estimate the number of runs and scans
    
    cd (NiftiSourceFolder)
    
    TEMP = dir;
    TEMP2=[];
    TEMP3=[];
    
    for i=3:length(TEMP)
        
        TEMP2 = [TEMP2 TEMP(i).isdir];
        
        cd(TEMP(i).name);
        TEMP3 = [TEMP3 length(dir('swdaugf*.img'))];
        cd ..
        
    end
    
    NbRuns = length(find(TEMP2))
    
    NbVols = min(TEMP3)
    
    clear TEMP TEMP2 TEMP3
    
    %--------------------------------------------------------------------------
        
    cd (BehavioralFolder)
    
    ResultsFile = dir ('Results_*.mat');
    load(ResultsFile(1,1).name, 'TotalTrials');
    
    SOT = cell(size(Conditions_Names,1), NbRuns);
    
    Block_Durations = cell(2, NbRuns);
    Block_Onset = cell(2, NbRuns);
    Block_2nd_Onset = cell(2, NbRuns);
    
    for i=1:NbRuns
        fprintf(strcat('Run ', num2str(i),'\n'))
        
        %% DESIGN - Events
        fprintf('Collects the SOTs.\n')
        A = [TotalTrials{1,1}(TotalTrials{1,1}(:,9)==i,[4 5 8]) TotalTrials{3,1}(TotalTrials{1,1}(:,9)==i,:)];
        
        % Converts
        A(find(A(:,1)==0 & A(:,2)==2) , 5) = 1; % into MC Gurk in Congruent
        A(find(A(:,1)==0 & A(:,2)==0) , 5) = 2; % into Congruent
        A(find(A(:,1)==1 & A(:,2)==2) , 5) = 3; % into MC Gurk in Incongruent
        A(find(A(:,1)==1 & A(:,2)==1) , 5) = 4; % into Incongruent
        
        % A submatrix with the trial type, the response category and
        % the onset
        A = A(:, [5 3 4]);
        
        % collects SOTs
        for j=1:length(Trials_Types)
            for k=1:length(Response_Category)
                SOT{k+length(Response_Category)*(j-1),i} = A(find(A(:,1)==j & A(:,2)==k), 3)+VideoToAudioOnsetDelay;
            end
        end
        clear A

        % Mc Gurk in congruent
        Sorted_SOT{1,1} = sort([SOT{1,i} ; SOT{2,i}]); % Puts the wrong and visual trials together
        Sorted_SOT{1,2} = SOT{3,i}; % Auditory trials
        Sorted_SOT{1,3} = SOT{4,i}; % Fused trials

        % Congruent
        Sorted_SOT{1,4} = sort([SOT{7,i} ; SOT{8,i}]); % Auditory and visual trials
        Sorted_SOT{1,5} = sort([SOT{6,i} ; SOT{9,i}]); % Puts the wrong and fused trials together
        
        % Mc Gurk in incongruent
        Sorted_SOT{1,6} = sort([SOT{11,i} ; SOT{12,i}]);
        Sorted_SOT{1,7} = SOT{13,i};
        Sorted_SOT{1,8} = SOT{14,i};
        
        % Incongruent
        Sorted_SOT{1,9} = sort([SOT{16,i} ; SOT{19,i}]); % Wrong and Fused trials
        Sorted_SOT{1,10} = SOT{17,i};  % Visual trials
        Sorted_SOT{1,11} = SOT{18,i};  % Auditory trials
        
        % Missed trials
        Sorted_SOT{1,12} = sort([SOT{5,i} ; SOT{10,i} ; SOT{15,i} ; SOT{20,i}]); % Missed trials
        
        EmptyCond = cellfun('isempty', Sorted_SOT);
        
        for EmptyCondInd = 1:sum(EmptyCond)
            Sorted_SOT{1,find(EmptyCond,1)} = Sorted_SOT{1,12}(1);
            Sorted_SOT{1,12}(1) = [];
            EmptyCond = cellfun('isempty', Sorted_SOT);
        end
        
        Design{1,i}=Sorted_SOT;

        
        
        %% DATA
        fprintf('Collects data.\n')
        % Enter source folder reads the image files
        ImagesFolder = fullfile(NiftiSourceFolder, num2str(i));
        cd (ImagesFolder)
        
        % Lists the images
        IMAGES_ls = dir('swdaugf*.img');
        
        % Names them with their absolute pathnames
        for j = 1:NbVols
            ImageList{j,1} = fullfile(ImagesFolder, IMAGES_ls(j).name);
        end
        Data{1,i} = single(spm_read_vols(spm_vol(char(ImageList))));
        clear ImageList IMAGES_ls

        

        %% DESIGN - Blocks
        fprintf('Collects block SOTs.\n\n')
        % SOTs for the block and tweak to have long blocks of 100 secs
        Block_Onset{1,i} = TotalTrials{3,1}(TotalTrials{1,1}(:,2)==1 & TotalTrials{1,1}(:,4)==0 & TotalTrials{1,1}(:,9)==i, :)+VideoToAudioOnsetDelay;
        Block_Onset{2,i} = TotalTrials{3,1}(TotalTrials{1,1}(:,2)==1 & TotalTrials{1,1}(:,4)==1 & TotalTrials{1,1}(:,9)==i, :)+VideoToAudioOnsetDelay;
        
        Block_2nd_Onset{1,i} = TotalTrials{3,1}(TotalTrials{1,1}(:,2)==2 & TotalTrials{1,1}(:,4)==0 & TotalTrials{1,1}(:,9)==i, :)+VideoToAudioOnsetDelay;
        Block_2nd_Onset{2,i} = TotalTrials{3,1}(TotalTrials{1,1}(:,2)==2 & TotalTrials{1,1}(:,4)==1 & TotalTrials{1,1}(:,9)==i, :)+VideoToAudioOnsetDelay;
        
        Block_Durations{1,i} = [100 100 100];
        Block_Durations{2,i} = [100 100 100];
        
        Block_Durations{1, i}(diff(Block_Onset{1, i})<125)=200;
        Block_2nd_Onset{1, i}(find(diff(Block_Onset{1, i})<125)+1)=[];
        Block_Onset{1, i}(find(diff(Block_Onset{1, i})<125)+1)=[];
        if length(Block_Onset{1, i})==2
            Block_Durations{1, i}(Block_Durations{1, i}==100)=[];
        end
        
        Block_Durations{2, i}(diff(Block_Onset{2, i})<125)=200;
        Block_2nd_Onset{2, i}(find(diff(Block_Onset{2, i})<125)+1)=[];
        Block_Onset{2, i}(find(diff(Block_Onset{2, i})<125)+1)=[];
        if length(Block_Onset{2, i})==2
            Block_Durations{2, i}(Block_Durations{2, i}==100)=[];
        end
        
        for j=1:2            
            sf = zeros(NbVols*NbSlices+128,1); % Creates an empty vector
            
            ton = round(Block_Onset{j,i}*NbSlices/TR) + 33; % Onset value after upsampling
            
            ton_2nd = round(Block_2nd_Onset{j,i}*NbSlices/TR) + 33;
            
            for BlockNumber=1:length(Block_Durations{j,i})
                
                ExpParam = -log(0.2)/(ton_2nd(BlockNumber)-ton(BlockNumber));
                
                BlockDuration = Block_Durations{j,i}(BlockNumber);
                Block = round(BlockDuration*NbSlices/TR); % number of slices in one block = number of sampling point.
                
                ExpBlock = [1-exp(-ExpParam*(1:Block))];
                
                if size(sf,1) > ton(BlockNumber)
                    sf(ton(BlockNumber):ton(BlockNumber)+Block-1,:) = sf(ton(BlockNumber):ton(BlockNumber)+Block-1,:) + ExpBlock';
                end
            end
            
            sf = sf(1:(NbVols*NbSlices + 32),:);
            
            X1 = conv(sf,bf); % Convolve with HRF
            
            X2 = X1((0:(NbVols - 1))*NbSlices + ReferenceSlice + 32,:); % Downsample

            opt.extraregressors{1,i}(:,j) = X2;
            
        end
        clear X1 X2 sf ExpBlock Block BlockDuration ExpParam ton_2nd ton
        
        
    end
    
    cd(AnalysisFolder)
    save('Denoise.mat', 'Design', 'Condition_Duration', 'TR', 'opt')
    
    Results = GLMdenoisedata(Design, Data, Condition_Duration, TR, 'assume', [], opt,'DenoiseFig')

    fprintf('\nThe analysis of the subject %s is done.\n\n', SubjID);
    
end

clear i j f h k


toc
