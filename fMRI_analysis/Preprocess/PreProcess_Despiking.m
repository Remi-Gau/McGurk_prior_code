%% INIT
clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

% Global Parameters

% Time Slicing Parameters
NbSlices = 42;
TR = 2.56;
TA = TR - (TR/NbSlices);
SliceOfReference = 21;
AcquisitionOrder = 1:1:NbSlices;

% Smoothing Parameters
FWHM = 8;


% Subject's Identity and Session number
SubjID = input('Subject''s ID? ','s');


%  Folders definitions
RootFolder = pwd;

SubjectFolder = strcat(pwd, filesep, SubjID, filesep);

NiftiSourceFolder = strcat(SubjectFolder, 'Nifti_EPI_Despiked', filesep);

ReferenceImageFolder = strcat(NiftiSourceFolder, '1');

SubjectStructuralFolder = strcat(pwd, filesep, SubjID, filesep, 'Structural');


cd(NiftiSourceFolder)

TEMP = dir;
TEMP2=[];
TEMP3=[];

for i=3:length(TEMP)
    
    TEMP2 = [TEMP2 TEMP(i).isdir];
    
    cd(TEMP(i).name);
    TEMP3 = [TEMP3 length(dir('gf*.img'))];
    cd ..
    
end
    
NbRuns = length(find(TEMP2))

NbVols = min(TEMP3)

clear TEMP TEMP2 TEMP3

cd(RootFolder)



%% UNWARP & REALIGN
% -------------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------------------

% --------------------------%
%      UNWARP & REALIGN     %
% --------------------------%

tic

matlabbatch = {};
ImagesFiles2Process={};

for i = 1:NbRuns
	
	DICOM_Files = {};

	% Enter source folder reads the files
	SourceImagesFolder = sprintf('%s%d', NiftiSourceFolder, i);
	cd (SourceImagesFolder)
	ImagesFiles2ProcessList = dir('gf*.img');

	for j = 1:NbVols                           
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

cd(RootFolder)

toc



%% SLICE TIMING
% -------------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------------------

% --------------------------%
%       SLICE   TIMING      %
% --------------------------%

tic

matlabbatch = {};
ImagesFiles2Process={};

for i = 1:NbRuns

	% Enter source folder reads the files
	SourceImagesFolder = sprintf('%s%d', NiftiSourceFolder, i);
	cd (SourceImagesFolder)
	ImagesFiles2ProcessList = dir('ugf*.img');
	
	for j = 1:NbVols                       
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

fprintf('\n\n')
disp('%%%%%%%%%%%%%%%%%%')
disp('   SLICE TIMING   ')
disp('%%%%%%%%%%%%%%%%%%')

spm_jobman('run',matlabbatch)

cd(RootFolder)

toc



%% COREGISTER
% -------------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------------------

% --------------------------%
%        COREGISTER         %
% --------------------------%

tic

matlabbatch = {};
ImagesFiles2Process={};


cd(ReferenceImageFolder)
filesdir = dir('mean*.img');
Mean_img = [ReferenceImageFolder, filesep, filesdir.name, ',1']

cd(SubjectStructuralFolder)
filesdir = dir('s*.img');
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

toc



%% SEGMENT
% -------------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------------------

% --------------------------%
%         SEGMENT           %
% --------------------------%

tic

matlabbatch = {};
ImagesFiles2Process={};


cd(SubjectStructuralFolder)
filesdir = dir('s*.img');
StructuralScan = [SubjectStructuralFolder, filesep, filesdir.name, ',1'];

% % --------------------------%
% %     DEFINES    BATCH      %
% % --------------------------%

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

toc



%% DESPIKING
% -------------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------------------

% --------------------------%
%        DESPIKING          %
% --------------------------%

tic

for i = 1:NbRuns

	% Enter source folder reads the files
	SourceImagesFolder = sprintf('%s%d', NiftiSourceFolder, i);
	cd (SourceImagesFolder)
	ImagesFiles2ProcessList = dir('augf*.img');
	
    Images2Despike = {''};
    
	for j = 1:NbVols                       
		Images2Despike{j,1} = strcat(SourceImagesFolder, filesep, ImagesFiles2ProcessList(j).name);
    end
    
    Images2Despike = char(Images2Despike)
    
    art_despike(Images2Despike,3,4)
	
end

toc



%% NORMALISE
% -------------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------------------

% --------------------------%
%        NORMALISE          %
% --------------------------%

tic

matlabbatch = {};
ImagesFiles2Process={};


cd(SubjectStructuralFolder)

filesdir = dir('*seg_sn.mat');
SegmentName = [SubjectStructuralFolder, filesep, filesdir.name];

filesdir = dir('s*.img');
StructuralScan = [SubjectStructuralFolder, filesep, filesdir.name, ',1'];


cd(ReferenceImageFolder)

filesdir = dir('mean*.img');
Mean_img = [ReferenceImageFolder, filesep, filesdir.name, ',1'];

matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).matname{1} = SegmentName;
matlabbatch{1,1}.spm.spatial.normalise.write.subj(1,1).resample = {};


for i = 1:NbRuns
	
	% Enter source folder reads the files
	SourceImagesFolder = sprintf('%s%d', NiftiSourceFolder, i)
	
	cd (SourceImagesFolder)
	
	ImagesFiles2ProcessList = dir('daugf*.img');

	for j = 1:NbVols
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

toc



%% SMOOTH
% -------------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------------------------------------------------------------

% --------------------------%
%          SMOOTH           %
% --------------------------%

tic

matlabbatch = {};
ImagesFiles2Process={};


for i = 1:NbRuns

	% Enter source folder reads the files
	SourceImagesFolder = sprintf('%s%d', NiftiSourceFolder, i)
	cd (SourceImagesFolder)
	ImagesFiles2ProcessList = dir('wdaugf*.img');
	
	for j = 1:NbVols
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

toc

cd (RootFolder)
