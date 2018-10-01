clc
clear

spm_get_defaults;
global defaults 

matlabbatch = {};
ImagesFiles2Process={};

SubjID = input('Subject''s ID? ','s');

A = pwd;
SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
SubjectStructuralFolder = strcat(pwd, filesep, SubjID, filesep, 'Structural');
ReferenceImageFolder = strcat(pwd, filesep, SubjID, filesep, 'Nifti_EPI', filesep, '1');

cd(ReferenceImageFolder)
filesdir = dir('mean*.img');
Mean_img = [ReferenceImageFolder, filesep, filesdir.name, ',1']

cd(SubjectStructuralFolder)
filesdir = dir('*.img');
StructuralScan = [SubjectStructuralFolder, filesep, filesdir.name, ',1']


% --------------------------%
%     DEFINES    BATCH      %
% --------------------------%

matlabbatch{1,1}.spm.spatial.coreg.estimate.ref{1,1} = Mean_img;                
matlabbatch{1,1}.spm.spatial.coreg.estimate.source{1,1} = StructuralScan;

matlabbatch{1,1}.spm.spatial.coreg.estimate.other{1,1} = '';                              
matlabbatch{1,1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1,1}.spm.spatial.coreg.estimate.eoptions.sep = [4,2];
matlabbatch{1,1}.spm.spatial.coreg.estimate.eoptions.tol = [repmat(0.02, 1, 3), repmat(0.001, 1, 3), repmat(0.01, 1, 3), repmat(0.001, 1, 3)];
matlabbatch{1,1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7,7];

cd (SubjectFolder)

save (strcat('Coregister_', SubjID, '_matlabbatch'));

fprintf('\n\n')
disp('%%%%%%%%%%%%%%%%')
disp('   COREGISTER   ')
disp('%%%%%%%%%%%%%%%%')

spm_jobman('run',matlabbatch)

cd (A)