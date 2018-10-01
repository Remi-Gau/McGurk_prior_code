clc
clear

spm_get_defaults;
global defaults 

matlabbatch = {};
ImagesFiles2Process={};

NbRuns = 8;
Vols2Drop = 5;
NbVols = 318;


SubjID = input('Subject''s ID? ','s');

A = pwd;
SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
SourceFolder = strcat(SubjectFolder, 'Nifti_EPI', filesep);

SubjectStructuralFolder = strcat(pwd, filesep, SubjID, filesep, 'Structural');
cd(SubjectStructuralFolder)
filesdir = dir('*seg_sn.mat');
SegmentName = [SubjectStructuralFolder, filesep, filesdir.name];
filesdir = dir('s*.img');
StructuralScan = [SubjectStructuralFolder, filesep, filesdir.name, ',1'];

ReferenceImageFolder = strcat(SourceFolder, '1');
cd(ReferenceImageFolder)
filesdir = dir('mean*.img');
Mean_img = [ReferenceImageFolder, filesep, filesdir.name, ',1'];

matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).matname{1} = SegmentName;
matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).resample = {};


for i = 1:NbRuns
	
	% Enter source folder reads the files
	SourceImagesFolder = sprintf('%s%d', SourceFolder, i)
	cd (SourceImagesFolder)
	ImagesFiles2ProcessList = dir('auf*.img');

	for j = 1:NbVols-Vols2Drop
	    realignedfiles{j,i} = [SourceImagesFolder, filesep, ImagesFiles2ProcessList(j).name, ',1'];
	    matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).resample = [matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).resample; realignedfiles{j,i}];
	end

end


% --------------------------%
%     DEFINES    BATCH      %
% --------------------------%

matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).resample = [matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).resample; Mean_img];
matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).resample = [matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).resample; StructuralScan];

matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).roptions.preserve = 0;
matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).roptions.bb = [-78,-112,-50;78,76,85];
matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).roptions.vox = [2 2 2];
matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).roptions.interp = 1;
matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).roptions.wrap = [0 0 0];
matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).roptions.prefix = 'w';

cd(SubjectFolder)

save (strcat('Normalise_', SubjID, '_matlabbatch'));

fprintf('\n\n')
disp('%%%%%%%%%%%%%%%%')
disp('   NORMALISE    ')
disp('%%%%%%%%%%%%%%%%')

spm_jobman('run',matlabbatch)

cd (A)