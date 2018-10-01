%%
clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

%%

% Subject's Identity and Session number
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];

% Time Slicing Parameters
NbSlices = 42;
ReferenceSlice = 1;
TR = 2.56;

%  Folders definitions
StartDirectory = pwd;

% ConditionsNbRuns
Conditions_Names = {	'Congruent_Blocks',     'McGurk_In_Congruent',      'Congruent_Trials', ...
                        'Incongruent_Blocks',	'McGurk_In_Incongruent',	'Incongruent_Trials' };
                    
Conditions_Duration = [83 0 0 83 0 0];

BlockDuration = 83;
                    
%%

ExpParam = 0.00845;

% Define HRF
SPM.xBF.UNITS = 'secs';
SPM.xBF.dt = TR/NbSlices; % Temporal resolution in seconds of the informed basis set you are going to create
SPM.xBF.name = 'hrf';
%SPM.xBF.T = NbSlices;
%SPM.xBF.T0 = 1;
SPM.xBF.length = 32; % Length of the HRF in seconds
SPM.xBF.order = 2;

SPM.xBF = spm_get_bf(SPM.xBF); % Creates the informed basis set

bf = SPM.xBF.bf;

% Define shape of the block
Block = round(BlockDuration*NbSlices/TR); % number of slices in one block = number of sampling point.

ExpBlock = [1-exp(-ExpParam*(1:Block))];

figure(2)
hold off
plot(ExpBlock)
hold on
plot([1 length(ExpBlock)], [0.75 0.75], 'r')
plot([round(10*NbSlices/TR) round(10*NbSlices/TR)], [0 1], 'r')

clear SPM

%%

tic

try

    for h=1:length(SubjectsList)


        SubjID=num2str(SubjectsList(h))


        %  Folders definitions
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);

        NiftiSourceFolder = strcat(SubjectFolder, 'Nifti_EPI', filesep);

        AnalysisFolder = strcat(SubjectFolder, 'Analysis_RisingBlocks_NoDer_200HPF', filesep);

        BehavioralFolder = strcat(SubjectFolder, 'Behavioral', filesep);

        %--------------------------------------------------------------------------
        % Estimate the number of runs and scans for this subject
        cd(NiftiSourceFolder)

        TEMP = dir;
        TEMP2=[];
        TEMP3=[];

        for i=3:length(TEMP)

            TEMP2 = [TEMP2 TEMP(i).isdir];

            cd(TEMP(i).name);
            TEMP3 = [TEMP3 length(dir('s*.img'))];
            cd ..

        end
        
        NbRuns = length(find(TEMP2))

        NbVols = min(TEMP3)

        clear TEMP TEMP2 TEMP3

        cd(StartDirectory)

        %--------------------------------------------------------------------------
        % Collects the SOTs
        
        fprintf('\nCollects the SOTs.\n\n')

        cd(SubjectFolder)
        cd Behavioral

        Runs_List = dir ('Subject_*.mat');
        Size_Runs_List = size(Runs_List,1);

        NbBlockType = 2;
        NbRegressorPerBlocType = 3;

        SOT = cell(NbRegressorPerBlocType * NbBlockType, Size_Runs_List);

        for k=1:Size_Runs_List

            load(Runs_List(k).name, 'Trials')

            SOT{3, k}= Trials{6,1}(find(Trials{1,1}(:,5)==0));
            SOT{6, k}= Trials{6,1}(find(Trials{1,1}(:,5)==1));

            for l=1:length(Trials{1,1}) 
                    if Trials{1,1}(l,5)==2
                        SOT{2 + Trials{1,1}(l,4) * 3, k} = [SOT{2 + Trials{1,1}(l,4) * 3, k} ; Trials{6,1}(l,1)];
                    end

                    if Trials{1,1}(l,2)==1
                        SOT{1 + Trials{1,1}(l,4) * 3, k} = [SOT{1 + Trials{1,1}(l,4) * 3, k} ; Trials{6,1}(l,1)];
                    end
            end	
        end

        cd ..

        save ('SOT.mat', 'SOT')

        cd (SubjectFolder)

        if exist(strcat('Analysis_RisingBlocks_NoDer_200HPF'),'dir')==0
            mkdir Analysis_RisingBlocks_NoDer_200HPF;
        end;
        
        fprintf('\nSOTs collected.\n\n')

        %--------------------------------------------------------------------------
        % Specify the batch
        
        fprintf('\nSpecifying the job\n\n')

        matlabbatch ={};


        matlabbatch{1,1}.spm.stats.fmri_spec.dir{1,1} = AnalysisFolder;

        matlabbatch{1,1}.spm.stats.fmri_spec.timing.units = 'secs';
        matlabbatch{1,1}.spm.stats.fmri_spec.timing.RT = TR; 
        matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t = NbSlices;
        matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t0 = 1; % Reference slice

        matlabbatch{1,1}.spm.stats.fmri_spec.fact = struct('name',{},'levels',{});

        matlabbatch{1,1}.spm.stats.fmri_spec.bases.hrf.derivs = [0,0]; % First is time derivative, Second is dispersion

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

            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).hpf = 200;


            % Enter source folder reads the image files
            ImagesFolder = sprintf('%s%d', NiftiSourceFolder, i);
            cd (ImagesFolder)

            % Lists the images
            IMAGES_ls = dir('swauf*.img');
            
            % Names them with their absolute pathnames
            for j = 1:NbVols
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).scans{j,1} = [ImagesFolder, filesep, IMAGES_ls(j).name];
            end

            % Lists the realignement parameters file
            Mov_Parameter_ls = dir('rp_f*.txt');

            % Names them with its absolute pathname
            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).multi_reg{1} = [ImagesFolder, filesep, Mov_Parameter_ls.name];

            IndexSOT=[2 3 5 6];
            
            % IndexSOT=1:6; % If normal blocks are to be included as weel.
            
            for j = 1:length(IndexSOT)
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).name = Conditions_Names{IndexSOT(j)};
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).duration = Conditions_Duration(IndexSOT(j));
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).tmod = 0;
                matlabbatch{1,1}.spm.stat.fmri_spec.sess(1,i).cond(1,j).pmod=struct('name',{},'param',{}, 'poly', {});
                
  
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).onset = SOT{IndexSOT(j),i};                
            end
            
            IndexSOT=[1 4];
            for j=1:2
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).regress(1,j).name = Conditions_Names{IndexSOT(j)}; 
                
                ons = SOT{IndexSOT(j),i};
                ton = round(ons*NbSlices/TR) + 33; % Onset value after upsampling
                
                sf = zeros(NbVols*NbSlices+128,1); % Creates an empty vector
                
                for k = 1:length(ton)
                    if size(sf,1) > ton(k)
                        sf(ton(k):ton(k)+Block-1,:) = sf(ton(k):ton(k)+Block-1,:) + ExpBlock';
                    end
                end
                
                sf = sf(1:(NbVols*NbSlices + 32),:); 
                
                X1 = conv(sf,bf); % Convolve with HRF
                
                X2 = X1((0:(NbVols - 1))*NbSlices + ReferenceSlice + 32,:); % Downsample
                                
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).regress(1,j).val = X2;
                
            end

        end

        %% FMRI_EST
        
        fprintf('\nEstimating model\n\n')
        
         matlabbatch{1,end+1}={};
         matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = [AnalysisFolder, 'SPM.mat'];     %set the spm file to be estimated
         matlabbatch{1,end}.spm.stats.fmri_est.method.Classical = 1;

        cd(AnalysisFolder)

        save (strcat('First_Level_RisingBlocks_NoDer_200HPF_', SubjID, '_jobs'));

        spm_jobman('run', matlabbatch)


        cd (StartDirectory)
        
        fprintf('\nThe analysis of the subject %s is done.\n\n', SubjID);

    end
    
catch
    Report = lasterror
end 

toc