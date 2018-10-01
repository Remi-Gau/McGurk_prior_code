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
cd(SubjectStructuralFolder)
filesdir = dir('s*.img');
StructuralScan = [SubjectStructuralFolder, filesep, filesdir.name, ',1'];


% --------------------------%
%     DEFINES    BATCH      %
% --------------------------%

matlabbatch{1,1}.spm.spatial.preproc.data{1} = StructuralScan;                             
matlabbatch{1,1}.spm.spatial.preproc.output.GM = [0,0,1];                           
matlabbatch{1,1}.spm.spatial.preproc.output.WM = [0 0 1];
matlabbatch{1,1}.spm.spatial.preproc.output.CSF = [0 0 0];
matlabbatch{1,1}.spm.spatial.preproc.output.biascor = 1;
matlabbatch{1,1}.spm.spatial.preproc.output.cleanup = 0;

matlabbatch{1,1}.spm.spatial.preproc.opts.tpm{1,1} = defaults.preproc.tpm{1};
matlabbatch{1,1}.spm.spatial.preproc.opts.tpm{2,1} = defaults.preproc.tpm{2};
matlabbatch{1,1}.spm.spatial.preproc.opts.tpm{3,1} = defaults.preproc.tpm{3}; 
matlabbatch{1,1}.spm.spatial.preproc.opts.ngaus = [2;2;2;4];
matlabbatch{1,1}.spm.spatial.preproc.opts.regtype = 'mni';
matlabbatch{1,1}.spm.spatial.preproc.opts.warpreg = 1;
matlabbatch{1,1}.spm.spatial.preproc.opts.warpco = 25;
matlabbatch{1,1}.spm.spatial.preproc.opts.biasreg = 0.0001;
matlabbatch{1,1}.spm.spatial.preproc.opts.biasfwhm = 60;
matlabbatch{1,1}.spm.spatial.preproc.opts.samp = 3;
matlabbatch{1,1}.spm.spatial.preproc.opts.msk{1,1} = '';

cd (SubjectFolder)

save (strcat('Segment_', SubjID, '_matlabbatch'));

fprintf('\n\n')
disp('%%%%%%%%%%%%%%%')
disp('    SEGMENT    ')
disp('%%%%%%%%%%%%%%%')

spm_jobman('run',matlabbatch);

cd (A)