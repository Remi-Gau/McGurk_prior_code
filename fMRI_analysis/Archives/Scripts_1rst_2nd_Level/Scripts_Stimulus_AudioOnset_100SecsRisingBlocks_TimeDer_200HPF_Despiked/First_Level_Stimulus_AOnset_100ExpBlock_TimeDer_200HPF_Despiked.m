%%
clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

% Time Slicing Parameters
NbSlices = 42;
TR = 2.56;
ReferenceSlice = 21;

VideoToAudioOnsetDelay = 1-0.04*8;

%  Folders definitions
cd ..
StartFolder = pwd;

% ConditionsNbRuns
Conditions_Names = {	'McGurk_In_Congruent',	'Congruent_Trials', ...
                        'McGurk_In_Incongruent',	'Incongruent_Trials' };
BlocksNames = {'Congruent', 'Incongruent'};

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
tic

% Subject's Identity
SubjectsList = 41;%[1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];

try

    for h=1:1%length(SubjectsList)


        SubjID=num2str(SubjectsList(h))


        %  Folders definitions
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);

        NiftiSourceFolder = strcat(SubjectFolder, 'Nifti_EPI_Despiked', filesep);

        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Stimulus_AOnset_100ExpBlock_TimeDer_200HPF_Despiked', filesep);

        BehavioralFolder = strcat(SubjectFolder, 'Behavioral', filesep);

        %--------------------------------------------------------------------------
        % Estimate the number of runs and scans
        cd(NiftiSourceFolder)

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

        cd(StartFolder)

        %--------------------------------------------------------------------------
        % Collects the SOTs
        
        fprintf('\nCollects the SOTs.\n\n')

        cd(SubjectFolder)
        cd Behavioral

        Runs_List = dir ('Subject_*.mat');
        Size_Runs_List = size(Runs_List,1);

        NbBlockType = 2;
        NbRegressorPerBlocType = 2;

        SOT = cell(NbRegressorPerBlocType * NbBlockType, Size_Runs_List);
        Block_Durations = cell(2, Size_Runs_List);
        Block_Onset = cell(2, Size_Runs_List);
        Block_2nd_Onset = cell(2, Size_Runs_List);

        for k=1:Size_Runs_List

            load(Runs_List(k).name)
            
            Block_Durations{1,k} = [100 100 100];
            Block_Durations{2,k} = [100 100 100];

            SOT{2, k}= Trials{6,1}(find(Trials{1,1}(:,5)==0))+VideoToAudioOnsetDelay;
            SOT{4, k}= Trials{6,1}(find(Trials{1,1}(:,5)==1))+VideoToAudioOnsetDelay;

            for l=1:length(Trials{1,1}) 
                    if Trials{1,1}(l,5)==2
                        SOT{1 + Trials{1,1}(l,4) * 2, k} = [SOT{1 + Trials{1,1}(l,4) * 2, k} ; Trials{6,1}(l,1)+VideoToAudioOnsetDelay];
                    end

                    if Trials{1,1}(l,2)==1
                        Block_Onset{1 + Trials{1,1}(l,4), k} = [Block_Onset{1 + Trials{1,1}(l,4), k} ; Trials{6,1}(l,1)+VideoToAudioOnsetDelay];
                    end
                    
                    if Trials{1,1}(l,2)==2
                        Block_2nd_Onset{1 + Trials{1,1}(l,4), k} = [Block_2nd_Onset{1 + Trials{1,1}(l,4), k} ; Trials{6,1}(l,1)+VideoToAudioOnsetDelay+1.6];
                    end
            end
            
            Block_Durations{1, k}(diff(Block_Onset{1, k})<125)=200;
            Block_2nd_Onset{1, k}(find(diff(Block_Onset{1, k})<125)+1)=[];
            Block_Onset{1, k}(find(diff(Block_Onset{1, k})<125)+1)=[];           
            if length(Block_Onset{1, k})==2
                Block_Durations{1, k}(Block_Durations{1, k}==100)=[];
            end

            Block_Durations{2, k}(diff(Block_Onset{2, k})<125)=200;
            Block_2nd_Onset{2, k}(find(diff(Block_Onset{2, k})<125)+1)=[];
            Block_Onset{2, k}(find(diff(Block_Onset{2, k})<125)+1)=[];
            if length(Block_Onset{2, k})==2
                Block_Durations{2, k}(Block_Durations{2, k}==100)=[];
            end
  
        end;

        cd ..

        save ('SOT.mat', 'SOT')

        cd (SubjectFolder)
        mkdir Analysis_Stimulus_AOnset_100ExpBlock_TimeDer_200HPF_Despiked;
        
        fprintf('\nSOTs collected.\n\n')
        
                
        %--------------------------------------------------------------------------
        % Specify the batch
        
        fprintf('\nSpecifying the job\n\n')

        matlabbatch ={};


        matlabbatch{1,1}.spm.stats.fmri_spec.dir{1,1} = AnalysisFolder;

        matlabbatch{1,1}.spm.stats.fmri_spec.timing.units = 'secs';
        matlabbatch{1,1}.spm.stats.fmri_spec.timing.RT = TR; 
        matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t = NbSlices;
        matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t0 = 21; % Reference slice

        matlabbatch{1,1}.spm.stats.fmri_spec.fact = struct('name',{},'levels',{});

        matlabbatch{1,1}.spm.stats.fmri_spec.bases.hrf.derivs = [1,0]; % First is time derivative, Second is dispersion

        matlabbatch{1,1}.spm.stats.fmri_spec.volt = 1;

        matlabbatch{1,1}.spm.stats.fmri_spec.global = 'None';

        matlabbatch{1,1}.spm.stats.fmri_spec.mask = {};

        matlabbatch{1,1}.spm.stats.fmri_spec.cvi = 'AR(1)';


        for i = 1:NbRuns
            
            IMAGES_ls = {};
            Mov_Parameter_ls = {};

            Scans = {};
            Mov_Parameter = [];


            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).multi{1} = '';

            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).regress = struct('name',{},'val',{});

            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).hpf = 200;


            % Enter source folder reads the image files
            ImagesFolder = sprintf('%s%d', NiftiSourceFolder, i);
            cd (ImagesFolder)

            % Lists the images
            IMAGES_ls = dir('swdaugf*.img');
            
            % Names them with their absolute pathnames
            for j = 1:NbVols
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).scans{j,1} = [ImagesFolder, filesep, IMAGES_ls(j).name];
            end

            % Lists the realignement parameters file
            Mov_Parameter_ls = dir('rp_*.txt');

            % Names them with its absolute pathname
            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).multi_reg{1} = [ImagesFolder, filesep, Mov_Parameter_ls.name];


            for j = 1:length(Conditions_Names)
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).name = Conditions_Names{j};
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).duration = 0;
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).tmod = 0;
                matlabbatch{1,1}.spm.stat.fmri_spec.sess(1,i).cond(1,j).pmod=struct('name',{},'param',{}, 'poly', {});

                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).onset = SOT{j,i};
            end
            
            
            for j=1:2
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).regress(1,j).name = BlocksNames{j}; 
                
                sf = zeros(NbVols*NbSlices+128,1); % Creates an empty vector
                
                ton = round(Block_Onset{j,i}*NbSlices/TR) + 33; % Onset value after upsampling
                
                ton_2nd = round(Block_2nd_Onset{j,i}*NbSlices/TR) + 33;
                                
                % Define shape of the block

                figure(1+i)
                subplot(2,1,j)
                hold on
                
                for BlockNumber=1:length(Block_Durations{j,i})
                    
                    plot([Block_Onset{j,i}(BlockNumber)/TR Block_Onset{j,i}(BlockNumber)/TR], [0 1], 'r')
                    plot([Block_2nd_Onset{j,i}(BlockNumber)/TR Block_2nd_Onset{j,i}(BlockNumber)/TR], [0 1], '--r')
                    plot([1 NbVols], [0.8 0.8], 'r')
                    
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
                                
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).regress(1,j).val = X2;
                
                
                plot(X2)
                plot(sf((0:(NbVols - 1))*NbSlices + ReferenceSlice + 32,:), 'g')
                
            end

        end

        % FMRI_EST
        
        fprintf('\nEstimating model\n\n')
        
        matlabbatch{1,end+1}={};
        matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = [AnalysisFolder, 'SPM.mat'];     %set the spm file to be estimated
        matlabbatch{1,end}.spm.stats.fmri_est.method.Classical = 1;

        cd(AnalysisFolder)

        save (strcat('First_Level_Analysis_Stimulus_AOnset_100ExpBlock_TimeDer_200HPF_Despiked_', SubjID, '_jobs'));
        

        spm_jobman('run', matlabbatch)


        cd (StartFolder)
        
        fprintf('\nThe analysis of the subject %s is done.\n\n', SubjID);

    end
    
catch
    Report = lasterror
    Report.message
    Report.stack.line
end 

toc