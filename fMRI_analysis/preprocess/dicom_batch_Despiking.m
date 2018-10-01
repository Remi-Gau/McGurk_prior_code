%%
clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

matlabbatch = {};
ImagesFiles2Process={};

Vols2Drop = 5;

%%
% Subject's Identity
SubjectsList = input('Subject''s ID? ');

% SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98]; 

ProcessStructural = 0; % input('Shall the structural be processed ? ');

RootFolder = pwd;

for k = 1:length(SubjectsList)
    %%
    SubjID = num2str(SubjectsList(k))
    
    SubjectFolder = strcat(pwd, filesep, SubjID, filesep)
    DICOMSourceFolder = strcat(SubjectFolder, 'RAW_EPI_Check', filesep);
    NiftiSourceFolder = strcat(SubjectFolder, 'Nifti_EPI_Despiked', filesep);

    cd (SubjectFolder)

    %% Checks the number of sessions and volumes/session
    cd(DICOMSourceFolder)

    TEMP = dir;
    TEMP2=[];
    TEMP3=[];

    for i=3:length(TEMP)

        TEMP2 = [TEMP2 TEMP(i).isdir];

        cd(TEMP(i).name);
        TEMP3 = [TEMP3 length(dir('*.ima'))];
        cd ..

    end

    NbRuns = length(find(TEMP2))

    NbVols = min(TEMP3)

    clear TEMP TEMP2 TEMP3

    cd(RootFolder)

    %% Creates destination folders
    cd (SubjectFolder)

    mkdir Nifti_EPI_Despiked;
    cd Nifti_EPI_Despiked

    for i=1:NbRuns
        mkdir (num2str(i));
    end

    cd(RootFolder)

    %% Preapres the batch
    % run through the sessions 

    for i = 1:NbRuns

        % Clear the files so it is fresh in every run
        clear ImagesFiles2Process 

        % Enter source folder reads the files
        SourceImagesFolder = sprintf('%s%d', DICOMSourceFolder, i);
        cd (SourceImagesFolder)
        ImagesFiles2ProcessList = dir('*.ima');                                

        for j = 1+Vols2Drop:NbVols
            ImagesFiles2Process{j-Vols2Drop,1} = [SourceImagesFolder, filesep, ImagesFiles2ProcessList(j).name];
        end


        % Destination Folder
        DestinationImagesFolder = sprintf('%s%d', NiftiSourceFolder, i);

        % --------------------------%
        %     DEFINES    BATCH      %
        % --------------------------%

        % Puting this list to the jobs var
        matlabbatch{1,i}.spm.util.dicom.data = ImagesFiles2Process;		
        % Don't use spm folder structure
        matlabbatch{1,i}.spm.util.dicom.root = 'flat';				

        % Set the output directory in the jobs var
        matlabbatch{1,i}.spm.util.dicom.outdir{1} = DestinationImagesFolder; 

        % No IC nameing
        matlabbatch{1,i}.spm.util.dicom.convopts.format = 'img';		
        % Set the format to 2 files
        matlabbatch{1,i}.spm.util.dicom.convopts.icedims = 0;

        cd (SubjectFolder)

      end

    %% An extra-turn for the STRUCTURAL scan !!
    if ProcessStructural

        clear ImagesFiles2Process 

        % Don't use spm folder structure
        matlabbatch{1,NbRuns+1}.spm.util.dicom.root = 'flat';				
        % No IC nameing
        matlabbatch{1,NbRuns+1}.spm.util.dicom.convopts.format = 'img';		
        % Set the format to 2 files
        matlabbatch{1,NbRuns+1}.spm.util.dicom.convopts.icedims = 0;

        cd Structural

        % Set the output directory in the jobs var
        matlabbatch{1,NbRuns+1}.spm.util.dicom.outdir{1} = pwd; 

        cd DICOM
        ImagesFiles2ProcessList = dir('*.ima');
        for j = 1:length(ImagesFiles2ProcessList)
            ImagesFiles2Process{j,1} = [pwd, filesep, ImagesFiles2ProcessList(j).name];
        end

        % Puting this list to the jobs var
        matlabbatch{1,NbRuns+1}.spm.util.dicom.data = ImagesFiles2Process;

        cd (SubjectFolder)

    end

    %% Saves and does the job
    save (strcat('DICOM_Despiking', SubjID, '_matlabbatch'), 'matlabbatch');  

    fprintf('\n\n')
    disp('%%%%%%%%%%%%%%%%%%')
    disp('   DICOM IMPORT   ')
    disp('%%%%%%%%%%%%%%%%%%')

    spm_jobman('run', matlabbatch)

    cd (RootFolder)

end