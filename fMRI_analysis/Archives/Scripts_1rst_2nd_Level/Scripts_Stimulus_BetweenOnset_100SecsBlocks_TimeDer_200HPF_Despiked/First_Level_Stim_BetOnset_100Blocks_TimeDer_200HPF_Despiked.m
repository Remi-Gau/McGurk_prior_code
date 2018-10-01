%%
clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

% Time Slicing Parameters
NbSlices = 42;
TR = 2.56;

VideoToAudioOnsetDelay = (1-0.04*8)/2;

%  Folders definitions
cd ..
StartFolder = pwd;

% ConditionsNbRuns
Conditions_Names = {	'Congruent_Blocks',	'McGurk_In_Congruent',	'Congruent_Trials', ...
                        'Incongruent_Blocks',	'McGurk_In_Incongruent',	'Incongruent_Trials' };

%%
tic

% Subject's Identity
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];

try

    for h=1:length(SubjectsList)


        SubjID=num2str(SubjectsList(h))


        %  Folders definitions
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);

        NiftiSourceFolder = strcat(SubjectFolder, 'Nifti_EPI_Despiked', filesep);

        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Stimulus_BetweenOnset_100Blocks_TimeDer_200HPF_Despiked', filesep);

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
        NbRegressorPerBlocType = 3;

        SOT = cell(NbRegressorPerBlocType * NbBlockType, Size_Runs_List);
        Condition_Duration = cell(NbRegressorPerBlocType * NbBlockType, Size_Runs_List);

        for k=1:Size_Runs_List

            load(Runs_List(k).name)
            
            Condition_Duration{1,k} = [100 100 100];
            Condition_Duration{2,k} = 0;
            Condition_Duration{3,k} = 0;
            Condition_Duration{4,k} = [100 100 100];
            Condition_Duration{5,k} = 0;
            Condition_Duration{6,k} = 0;

            SOT{3, k}= Trials{6,1}(find(Trials{1,1}(:,5)==0))+VideoToAudioOnsetDelay;
            SOT{6, k}= Trials{6,1}(find(Trials{1,1}(:,5)==1))+VideoToAudioOnsetDelay;

            for l=1:length(Trials{1,1}) 
                    if Trials{1,1}(l,5)==2
                        SOT{2 + Trials{1,1}(l,4) * 3, k} = [SOT{2 + Trials{1,1}(l,4) * 3, k} ; Trials{6,1}(l,1)+VideoToAudioOnsetDelay];
                    end

                    if Trials{1,1}(l,2)==1
                        SOT{1 + Trials{1,1}(l,4) * 3, k} = [SOT{1 + Trials{1,1}(l,4) * 3, k} ; Trials{6,1}(l,1)+VideoToAudioOnsetDelay];
                    end
            end
            
            Condition_Duration{1, k}(diff(SOT{1, k})<125)=200;
            SOT{1, k}(find(diff(SOT{1, k})<125)+1)=[];
            if length(SOT{1, k})==2
                Condition_Duration{1, k}(Condition_Duration{1, k}==100)=[];
            end

            Condition_Duration{4, k}(diff(SOT{4, k})<125)=200;
            SOT{4, k}(find(diff(SOT{4, k})<125)+1)=[];
            if length(SOT{4, k})==2
                Condition_Duration{4, k}(Condition_Duration{4, k}==100)=[];
            end
  
        end;

        cd ..

        save ('SOT.mat', 'SOT')

        cd (SubjectFolder)

        mkdir Analysis_Stimulus_BetweenOnset_100Blocks_TimeDer_200HPF_Despiked;
        
        fprintf('\nSOTs collected.\n\n')
        
        
%%
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
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).duration = Condition_Duration{j,i};
                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).tmod = 0;
                matlabbatch{1,1}.spm.stat.fmri_spec.sess(1,i).cond(1,j).pmod=struct('name',{},'param',{}, 'poly', {});

                matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).onset = SOT{j,i};
            end

        end

        % FMRI_EST
        
        fprintf('\nEstimating model\n\n')
        
        matlabbatch{1,end+1}={};
        matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = [AnalysisFolder, 'SPM.mat'];     %set the spm file to be estimated
        matlabbatch{1,end}.spm.stats.fmri_est.method.Classical = 1;

        cd(AnalysisFolder)

        save (strcat('First_Level_Analysis_Stimulus_BetweenOnset_100Blocks_TimeDer_200HPF_Despiked_', SubjID, '_jobs'));
        
%%
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