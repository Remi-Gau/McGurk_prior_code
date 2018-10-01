clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

matlabbatch = {};
ImagesFiles2Process={};

NbRuns = 6;
Vols2Drop = 5;
NbVols = 323;

% 69 : 323 vols


SubjID = input('Subject''s ID? ','s');

A = pwd;

SubjectFolder = strcat(pwd, filesep, SubjID, filesep)
SourceFolder = strcat(SubjectFolder, 'RAW_EPI', filesep);
DestinationFolder = strcat(SubjectFolder, 'Nifti_EPI', filesep);


cd (SubjectFolder)

if exist(strcat('Nifti_EPI'),'dir')==0
	mkdir Nifti_EPI;
end;
cd Nifti_EPI

for i=1:NbRuns
	if exist(strcat('i'),'dir')==0
		mkdir (num2str(i));
	end
end

fprintf('\n\n')
disp('%%%%%%%%%%%%%%%%%%')
disp('   DICOM IMPORT   ')
disp('%%%%%%%%%%%%%%%%%%')


% run through the sessions plus the Anatomy
for i = 1:NbRuns
	
	% Clear the files so it is fresh in every run
	clear ImagesFiles2Process 

	% Enter source folder reads the files
	SourceImagesFolder = sprintf('%s%d', SourceFolder, i);
	cd (SourceImagesFolder)
	ImagesFiles2ProcessList = dir('*.ima');                                
	
	for j = 1+Vols2Drop:NbVols
		ImagesFiles2Process{j-Vols2Drop,1} = [SourceImagesFolder, filesep, ImagesFiles2ProcessList(j).name];
	end

	
	% Destination Folder
	DestinationImagesFolder = sprintf('%s%d', DestinationFolder, i);

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

% An extra-turn for the STRUCTURAL scan !!
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

save (strcat('DICOM_', SubjID, '_matlabbatch'));  

spm_jobman('run', matlabbatch)

cd (A)