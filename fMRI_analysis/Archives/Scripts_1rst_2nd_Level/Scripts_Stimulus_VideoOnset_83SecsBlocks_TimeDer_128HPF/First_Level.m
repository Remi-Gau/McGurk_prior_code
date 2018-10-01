clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults


% Global Parameters
NbRuns = 7;
Vols2Drop = 5;
NbVols = 325;


% Time Slicing Parameters
NbSlices = 42;
TR = 2.56;
TA = TR - (TR/NbSlices);
SliceOfReference = 1;
AcquisitionOrder = 1:1:NbSlices;


% Smoothing Parameters
FWHM = 8;


% Subject's Identity and Session number
SubjID = input('Subject''s ID? ','s');


%  Folders definitions
A = pwd;

SubjectFolder = strcat(pwd, filesep, SubjID, filesep);

DICOMSourceFolder = strcat(SubjectFolder, 'RAW_EPI', filesep);

NiftiSourceFolder = strcat(SubjectFolder, 'Nifti_EPI', filesep);

AnalysisFolder = strcat(SubjectFolder, 'Analysis', filesep);

BehavioralFolder = strcat(SubjectFolder, 'Behavioral', filesep);

ReferenceImageFolder = strcat(NiftiSourceFolder, '1');

SubjectStructuralFolder = strcat(pwd, filesep, SubjID, filesep, 'Structural');



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

cd(A)



% ConditionsNbRuns
Conditions_Names = {	'Congruent_Blocks',	'McGurk_In_Congruent',	'Congruent_Trials', ...
                        'Incongruent_Blocks',	'McGurk_In_Incongruent',	'Incongruent_Trials' };
                    
Condition_Duration = [83 0 0 83 0 0];


cd(SubjectFolder)

% Collects the SOTs
cd Behavioral

Runs_List = dir ('Subject_*.mat');
Size_Runs_List = size(Runs_List,1);

NbBlockType = 2;
NbRegressorPerBlocType = 3;

NbRuns
% cell(Block_Type_Before, Trial_Position, Block_Type, Run_Number)
SOT = cell(NbRegressorPerBlocType * NbBlockType, Size_Runs_List);
% Collects the SOTs
for k=1:Size_Runs_List
	
    load(Runs_List(k).name)
    
    SOT{3, k}= Trials{6,1}(find(Trials{1,1}(:,5)==0));
    SOT{6, k}= Trials{6,1}(find(Trials{1,1}(:,5)==1));
    
    for l=1:length(Trials{1,1}) 
            if Trials{1,1}(l,5)==2
                SOT{2 + Trials{1,1}(l,4) * 3, k} = [SOT{2 + Trials{1,1}(l,4) * 3, k} ; Trials{6,1}(l,1)];
            end
            
            if Trials{1,1}(l,2)==1
                SOT{1 + Trials{1,1}(l,4) * 3, k} = [SOT{1 + Trials{1,1}(l,4) * 3, k} ; Trials{6,1}(l,1)];
            end
	end	
end;

cd ..

save ('SOT.mat', 'SOT')

cd (SubjectFolder)

if exist(strcat('Analysis'),'dir')==0
	mkdir Analysis;
end;




matlabbatch ={};


matlabbatch{1,1}.spm.stats.fmri_spec.dir{1,1} = AnalysisFolder;

matlabbatch{1,1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1,1}.spm.stats.fmri_spec.timing.RT = TR; 
matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t = NbSlices;
matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t0 = 1; % Reference slice

matlabbatch{1,1}.spm.stats.fmri_spec.fact = struct('name',{},'levels',{});

matlabbatch{1,1}.spm.stats.fmri_spec.bases.hrf.derivs = [1,0]; % First is time derivative, Second is dispersion

matlabbatch{1,1}.spm.stats.fmri_spec.volt = 1;

matlabbatch{1,1}.spm.stats.fmri_spec.global = 'None';

matlabbatch{1,1}.spm.stats.fmri_spec.mask = {};

matlabbatch{1,1}.spm.stats.fmri_spec.cvi = 'AR(1)';



NbRuns


for i = 1:NbRuns
	
	IMAGES_ls = {};
	Mov_Parameter_ls = {};
	
	Scans = {};
	Mov_Parameter = [];
		
	
	matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).multi{1} = '';
	
	matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).regress = struct('name',{},'val',{});
	
	matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).hpf = 128;


	% Enter source folder reads the image files
	ImagesFolder = sprintf('%s%d', NiftiSourceFolder, i)
	cd (ImagesFolder)
	
	% Lists the images
	IMAGES_ls = dir('swauf*.img');
	
	% Names them with their absolute pathnames
	for j = 1:NbVols-Vols2Drop
		matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).scans{j,1} = [ImagesFolder, filesep, IMAGES_ls(j).name];
	end

	% Lists the realignement parameters file
	Mov_Parameter_ls = dir('rp_f*.txt');
	
	% Names them with its absolute pathname
	matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).multi_reg{1} = [ImagesFolder, filesep, Mov_Parameter_ls.name];


	for j = 1:length(Conditions_Names)
		matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).name = Conditions_Names{j};
		matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).duration = Condition_Duration(j); % 0 for event design
		matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).tmod = 0;
		matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).pmod=struct('name',{},'param',{}, 'poly', {});
		
		matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).cond(1,j).onset = SOT{j,i};
	end
	
end

% FMRI_EST
matlabbatch{1,end+1}={};
matlabbatch{1,end}.spm.stats.fmri_est.spmmat{1,1} = [AnalysisFolder, 'SPM.mat'];     %set the spm file to be estimated
matlabbatch{1,end}.spm.stats.fmri_est.method.Classical = 1;

cd(AnalysisFolder)

save (strcat('First_Level', SubjID, '_jobs'));

spm_jobman('run', matlabbatch)
    

cd (A)
