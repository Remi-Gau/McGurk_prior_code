clc
clear

spm_get_defaults;
global defaults 

matlabbatch = {};
ImagesFiles2Process={};

NbRuns = 8;
Vols2Drop = 5;
NbVols = 318;

FWHM = 8;

SubjID = input('Subject''s ID? ','s');

A = pwd;
SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
SourceFolder = strcat(SubjectFolder, 'Nifti_EPI', filesep);
 

for i = 1:NbRuns

	% Enter source folder reads the files
	SourceImagesFolder = sprintf('%s%d', SourceFolder, i)
	cd (SourceImagesFolder)
	ImagesFiles2ProcessList = dir('wauf*.img');
	
	for j = 1:NbVols-Vols2Drop
	    Files2Smooth{j,i} = [SourceImagesFolder, filesep, ImagesFiles2ProcessList(j).name, ',1'];
	end
	
	matlabbatch{1,1}.spm.spatial.smooth.data = Files2Smooth;

end


% --------------------------%
%     DEFINES    BATCH      %
% --------------------------%

matlabbatch{1,1}.spm.spatial.smooth.fwhm = [FWHM FWHM FWHM];                                 
matlabbatch{1,1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1,1}.spm.spatial.smooth.prefix = 's';

cd (SubjectFolder)

save (strcat('Smooth_', SubjID, '_matlabbatch'));

fprintf('\n\n')
disp('%%%%%%%%%%%%%%%%')
disp('     SMOOTH     ')
disp('%%%%%%%%%%%%%%%%')

spm_jobman('run',matlabbatch)

cd (A)
