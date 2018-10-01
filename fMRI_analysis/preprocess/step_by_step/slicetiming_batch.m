
clc
clear

spm_get_defaults;
global defaults 

matlabbatch = {};
ImagesFiles2Process={};

NbRuns = 6;
Vols2Drop = 5;
NbVols = 323;

NbSlices = 42;
TR = 2.56;
TA = TR - (TR/NbSlices);
SliceOfReference = 1;
AcquisitionOrder = 1:1:NbSlices;


SubjID = input('Subject''s ID? ','s');

A =pwd;

SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
SourceFolder = strcat(SubjectFolder, 'Nifti_EPI', filesep);


fprintf('\n\n')
disp('%%%%%%%%%%%%%%%%%%')
disp('   SLICE TIMING   ')
disp('%%%%%%%%%%%%%%%%%%')


for i = 1:NbRuns

	% Enter source folder reads the files
	SourceImagesFolder = sprintf('%s%d', SourceFolder, i);
	cd (SourceImagesFolder)
	ImagesFiles2ProcessList = dir('uf*.img');
	
	for j = 1:NbVols-Vols2Drop                         
		DICOM_Files{j,1} = [SourceImagesFolder, filesep, ImagesFiles2ProcessList(j).name, ',1'];
	end
	matlabbatch{1,1}.spm.temporal.st.scans{1,i} = DICOM_Files;
	
end

% --------------------------%
%     DEFINES    BATCH      %
% --------------------------%

matlabbatch{1,1}.spm.temporal.st.nslices = NbSlices;
matlabbatch{1,1}.spm.temporal.st.tr = TR;
matlabbatch{1,1}.spm.temporal.st.ta = TA;
matlabbatch{1,1}.spm.temporal.st.so = AcquisitionOrder ;
matlabbatch{1,1}.spm.temporal.st.refslice = SliceOfReference;
matlabbatch{1,1}.spm.temporal.st.prefix = 'a';
	
cd (SubjectFolder)

save (strcat('SliceTiming_', SubjID, '_matlabbatch'));   

spm_jobman('run',matlabbatch)

cd (A)