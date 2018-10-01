clc
clear

spm_jobman('initcfg');
spm_get_defaults;
global defaults 

matlabbatch = {};
ImagesFiles2Process={};

NbRuns = 6;
Vols2Drop = 5;
NbVols = 323;

SubjID = input('Subject''s ID? ','s');

A = pwd;

SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
SourceFolder = strcat(SubjectFolder, 'Nifti_EPI', filesep);


for i = 1:NbRuns
	
	DICOM_Files = {};

	% Enter source folder reads the files
	SourceImagesFolder = sprintf('%s%d', SourceFolder, i);
	cd (SourceImagesFolder)
	ImagesFiles2ProcessList = dir('*.img');

	for j = 1:NbVols-Vols2Drop                           
		DICOM_Files{j,1} = [SourceImagesFolder, filesep, ImagesFiles2ProcessList(j).name, ',1'];
	end
	
	matlabbatch{1,1}.spm.spatial.realignunwarp.data(1,i).scans = DICOM_Files;
	matlabbatch{1,1}.spm.spatial.realignunwarp.data(1,i).pmscan = '';

end

% --------------------------%
%     DEFINES    BATCH      %
% --------------------------%

matlabbatch{1,1}.spm.spatial.realignunwarp.eoptions.quality = 1;                    
matlabbatch{1,1}.spm.spatial.realignunwarp.eoptions.sep = 4;                        
matlabbatch{1,1}.spm.spatial.realignunwarp.eoptions.fwhm = 5;                      
matlabbatch{1,1}.spm.spatial.realignunwarp.eoptions.rtm = 0; % Register to mean                
matlabbatch{1,1}.spm.spatial.realignunwarp.eoptions.einterp = 2;                    
matlabbatch{1,1}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];                
matlabbatch{1,1}.spm.spatial.realignunwarp.eoptions.weight = {''};                   

matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];             
matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.jm = 0;
matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.sot = [];
matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.rem = 1;
matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.noi = 5;
matlabbatch{1,1}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';

matlabbatch{1,1}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
matlabbatch{1,1}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
matlabbatch{1,1}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
matlabbatch{1,1}.spm.spatial.realignunwarp.uwroptions.mask = 1;
matlabbatch{1,1}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';


cd (SubjectFolder)


save (strcat('Realign&Unwarp_', SubjID, '_matlabbatch'));

fprintf('\n\n')
disp('%%%%%%%%%%%%%%%%')
disp('   REALIGNING   ')
disp('%%%%%%%%%%%%%%%%')

spm_jobman('run',matlabbatch)

cd (A)
