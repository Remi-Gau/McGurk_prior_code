%%
clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

% -------------------------------------------------------------------------
%%
% -------------------------------------------------------------------------
% Time Slicing Parameters
NbSlices = 42;
TR = 2.56;
ReferenceSlice = 21;

VideoToAudioOnsetDelay = (1-0.04*8)/2;


% -------------------------------------------------------------------------
%% Define HRF
% -------------------------------------------------------------------------
SPM.xBF.UNITS = 'secs';
SPM.xBF.dt = TR/NbSlices; % Temporal resolution in seconds of the informed basis set you are going to create
SPM.xBF.name = 'hrf';
SPM.xBF.length = 32; % Length of the HRF in seconds
SPM.xBF.order = 2;

SPM.xBF = spm_get_bf(SPM.xBF); % Creates the informed basis set

bf = SPM.xBF.bf;

clear SPM


% -------------------------------------------------------------------------
%%
% -------------------------------------------------------------------------
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

Condition_Duration = 0;


clear A j i


% -------------------------------------------------------------------------
%%
% -------------------------------------------------------------------------
% Subject's Identity
SubjectsList = [69 73 74 82 98]; % 1 13 15 24 28 32 41 48 61  

tic

try

    for h=1:length(SubjectsList)

        SubjID=num2str(SubjectsList(h))

% -------------------------------------------------------------------------
        %  Folders definitions
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);

        NiftiSourceFolder = strcat(SubjectFolder, 'Nifti_EPI_Despiked', filesep);
        
        BehavioralFolder = strcat(SubjectFolder, 'Behavioral', filesep);

        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Concatenated_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked', filesep);
        
        cd(SubjectFolder)
        mkdir Analysis_Concatenated_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked


% --------------------------------------------------------------------------
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
       
% -------------------------------------------------------------------------
        % Collects the SOTs
        
        fprintf('\nCollects the SOTs.\n\n')
             
        cd (BehavioralFolder)

        ResultsFile = dir ('Results_*.mat');
        load(ResultsFile(1,1).name, 'TotalTrials');

        SOT = cell(length(Response_Category)*length(Trials_Types), NbRuns); 
        
        Sorted_SOT = cell(size(Conditions_Names,1),NbRuns);
        
        Block_Durations = cell(2, NbRuns);
        Block_Onset = cell(2, NbRuns);
        Block_2nd_Onset = cell(2, NbRuns);
        
        BlockRegressor = cell(2,1);
        
        ImageList = cell(NbRuns,1);
        ImageListTemp = {};
        Mov_Parameter = [];

        for i=1:NbRuns
            
            A = [TotalTrials{1,1}(TotalTrials{1,1}(:,9)==i,[4 5 8]) TotalTrials{3,1}(TotalTrials{1,1}(:,9)==i,:)];
            
            % Converts
            A(find(A(:,1)==0 & A(:,2)==2) , 5) = 1; % into MC Gurk in Congruent
            A(find(A(:,1)==0 & A(:,2)==0) , 5) = 2; % into Congruent
            A(find(A(:,1)==1 & A(:,2)==2) , 5) = 3; % into MC Gurk in Incongruent
            A(find(A(:,1)==1 & A(:,2)==1) , 5) = 4; % into Incongruent
            
            % A submatrix with the trial type, the response category and
            % the onset
            A = A(:, [5 3 4]);

            
% -------------------------------------------------------------------------
            % collects SOTs for the events
            % adds audio delay and divide by TR to get SOT in scans rather
            % than seconds
            for j=1:length(Trials_Types)
                for k=1:length(Response_Category)
                    SOT{k+length(Response_Category)*(j-1),i} = (A(find(A(:,1)==j & A(:,2)==k), 3)+VideoToAudioOnsetDelay)/TR;
                end
            end
            
            clear A
            
            % Mc Gurk in congruent
            Sorted_SOT{1,i} = sort([SOT{1,i} ; SOT{2,i}]); % Puts the wrong and visual trials together
            Sorted_SOT{2,i} = SOT{3,i}; % Auditory trials
            Sorted_SOT{3,i} = SOT{4,i}; % Fused trials            
            
            % Congruent
            Sorted_SOT{4,i} = sort([SOT{7,i} ; SOT{8,i}]); % Auditory and visual trials
            Sorted_SOT{5,i} = sort([SOT{6,i} ; SOT{9,i}]); % Puts the wrong and fused trials together
            
            % Mc Gurk in incongruent
            Sorted_SOT{6,i} = sort([SOT{11,i} ; SOT{12,i}]);
            Sorted_SOT{7,i} = SOT{13,i};
            Sorted_SOT{8,i} = SOT{14,i};
            
            % Incongruent
            Sorted_SOT{9,i} = sort([SOT{16,i} ; SOT{19,i}]); % Wrong and Fused trials
            Sorted_SOT{10,i} = SOT{17,i};  % Visual trials
            Sorted_SOT{11,i} = SOT{18,i};  % Auditory trials
            
            % Missed trials
            Sorted_SOT{12,i} = sort([SOT{5,i} ; SOT{10,i} ; SOT{15,i} ; SOT{20,i}]); % Missed trials
           

% -------------------------------------------------------------------------            
            % BLOCKS
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

            
% -------------------------------------------------------------------------            
            % Creates the user defined regressors for the blocks
            for j=1:2
                
                sf = zeros(NbVols*NbSlices+128,1); % Creates an empty vector                
                ton = round(Block_Onset{j,i}*NbSlices/TR) + 33; % Onset value after upsampling
                ton_2nd = round(Block_2nd_Onset{j,i}*NbSlices/TR) + 33;
                
                % Define shape of the block                
%                 figure(1+i)
%                 subplot(2,1,j)
%                 hold on
                
                for BlockNumber=1:length(Block_Durations{j,i})
                    
%                     plot([Block_Onset{j,i}(BlockNumber)/TR Block_Onset{j,i}(BlockNumber)/TR], [0 1], 'r')
%                     plot([Block_2nd_Onset{j,i}(BlockNumber)/TR Block_2nd_Onset{j,i}(BlockNumber)/TR], [0 1], '--r')
%                     plot([1 NbVols], [0.8 0.8], 'r')
                    
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
                
%                 plot(X2)
%                 plot(sf((0:(NbVols - 1))*NbSlices + ReferenceSlice + 32,:), 'g')
                
                % Concatenate block regressors
                BlockRegressor{j,1} = [BlockRegressor{j,1} ; X2];
                
                clear X2 X1 sf ton ton_2nd ExpParam Block ExpBlock

            end
                        
% -------------------------------------------------------------------------
            % Enter source folder reads the image files
            ImagesFolder = sprintf('%s%d', NiftiSourceFolder, i);
            cd (ImagesFolder)
            
            % Lists the images and concatenate their absolute names
            
            IMAGES_ls = dir('swdaugf*.img');
            ImageListTemp{i} = strcat(repmat(ImagesFolder, NbVols, 1), filesep, char(IMAGES_ls.name));
 
                        
            % Lists and reads the realignement parameters file and
            % concatenate the RP
            Mov_Parameter_ls = dir('rp_*.txt');            
            Mov_Parameter_Sesion = load(Mov_Parameter_ls.name);
            Mov_Parameter = [Mov_Parameter ; Mov_Parameter_Sesion];
            
            clear Mov_Parameter_Sesion ImagesFolder Mov_Parameter_ls IMAGES_ls
            
        end
        
        ImageList = char(ImageListTemp);
        
%         figure(NbRuns+2)
%         hold on
%         subplot(211)
%         plot(BlockRegressor{1,1})
%         subplot(212)
%         plot(BlockRegressor{2,1})
        
        
        % Concatenate SOTs for the events
        A = cell(size(Sorted_SOT,1),1);
        for i=1:size(Sorted_SOT,1)     
            
            for j=1:NbRuns
                if max(Sorted_SOT{i,j})>NbVols
                    max(Sorted_SOT{i,j})
                    fprintf('\n Oops. Program stopped because there was a mistake in the SOT specification. \n\n')
                    return
                end
                A{i} = [A{i} ; Sorted_SOT{i,j}+NbVols*(j-1)];                
            end
%             figure(NbRuns+3)
%             hold on
%             subplot(size(Sorted_SOT,1) ,1,i)
%             B = zeros(1,NbRuns*NbVols);
%             B(1,round(A{i}))=1;
%             stem(1:NbRuns*NbVols,B)
        end
        
        Sorted_SOT = A;
        
        cd (AnalysisFolder)
        
        save ('SOT.mat', 'SOT', 'Sorted_SOT')
        
        fprintf('\nSOTs collected.\n\n')
        
        %clear A ResultsFile i j SOT BlockDuration BlockNumber Block_2nd_Onset Block_Durations Block_Onset
        %clear TotalTrials
        
        
        
        %--------------------------------------------------------------------------
        %% Specify the batch
        
        fprintf('\nSpecifying the job\n\n')

        matlabbatch ={};

        matlabbatch{1,1}.spm.stats.fmri_spec.dir{1,1} = AnalysisFolder;

        matlabbatch{1,1}.spm.stats.fmri_spec.timing.units = 'scans';
        matlabbatch{1,1}.spm.stats.fmri_spec.timing.RT = TR; 
        matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t = NbSlices;
        matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t0 = 21; % Reference slice
        
        matlabbatch{1,1}.spm.stats.fmri_spec.fact = struct('name',{},'levels',{});
        
        matlabbatch{1,1}.spm.stats.fmri_spec.bases.hrf.derivs = [1,0]; % First is time derivative, Second is dispersion
        
        matlabbatch{1,1}.spm.stats.fmri_spec.volt = 1;
        
        matlabbatch{1,1}.spm.stats.fmri_spec.global = 'None';
        
        matlabbatch{1,1}.spm.stats.fmri_spec.mask = {};
        
        matlabbatch{1,1}.spm.stats.fmri_spec.cvi = 'AR(1)';
                 
        matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).multi{1} = '';        
        matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).regress = struct('name',{},'val',{});
        matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).hpf = 200;                   
        matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).multi_reg{1} = '';        
        % Inputs the images
        matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).scans =  cellstr(ImageList);        
        % Inputs conditions
        Counter = 1;
        for j = 1:size(Conditions_Names,1)
            if isempty(Sorted_SOT{j,1})
            else
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,Counter).name = Conditions_Names(j,:);
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,Counter).duration = Condition_Duration;
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,Counter).tmod = 0;
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,Counter).pmod=struct('name',{},'param',{}, 'poly', {});
                
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,Counter).onset = Sorted_SOT{j,1};
                
                Counter = Counter + 1;
            end
        end
        
        
        % Inputs the block regressors
        Counter = 1;
        for j=1:2
            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).regress(1,Counter).name = BlocksNames{j};
            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).regress(1,Counter).val = BlockRegressor{j,1};
            Counter = Counter + 1;
        end
        
        % Inputs the realignement regressors
        for j=1:6
            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).regress(1,Counter).name = strcat('Real_Param_', num2str(j));
            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).regress(1,Counter).val = Mov_Parameter(:,j);
            Counter = Counter + 1;
        end
        
        for j=1:NbRuns-1
            SessionMean=zeros(NbRuns*NbVols,1);
            SessionMean(1+NbVols*(j-1):NbVols*j)=1;
            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).regress(1,Counter).name = strcat('Session_Mean_', num2str(j));
            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).regress(1,Counter).val = SessionMean;
            Counter = Counter + 1;
        end            
        
        %--------------------------------------------------------------------------
        % FMRI_EST
                
        matlabbatch{1,end+1}={};
        matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = [AnalysisFolder, 'SPM.mat'];     %set the spm file to be estimated
        matlabbatch{1,end}.spm.stats.fmri_est.method.Classical = 1;

        cd(AnalysisFolder)
        
        %delete *.*

        save (strcat('First_Level_Analysis_Percept_BetweenOnset_100ExpBlocks_TimeDer_200HPF_Despiked_', SubjID, '_jobs'));

        fprintf('\nSpecifying & estimating model\n\n')
        spm_jobman('run', matlabbatch)


        cd (StartingDirectory)
        
        fprintf('\nThe analysis of the subject %s is done.\n\n', SubjID);

    end
    
catch
    Report = lasterror
    Report.message
    Report.stack.line
end 

toc
