clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

Nb = 1000;

% Time Slicing Parameters
NbSlices = 42;
TR = 2.56;
SliceOfReference = 1;

% Conditions
Conditions_Names = {'Block_CON', 'McGurk_TrialinCON', 'CON_Trial', 'Block_INC', 'McGurk_TrialinINC', 'INC_Trial'};

StartDirectory = pwd;

NbBlockdTotal = 80;
NbSession = 1;

BlockOnset = [0:NbBlockdTotal*NbSession-1]*100;
BlockOnsetCON = BlockOnset([1:2:length(BlockOnset)]);
BlockOnsetINC = BlockOnset([2:2:length(BlockOnset)]);

load('StimOnsetMat.mat')

load('TrialOrderFinal.mat')

[a b] = size(TrialOrder);

AllMcGurkOnset = (TrialOrder==2).*StimOnsetMat;
AllNonMcGurkOnset = (TrialOrder==0).*StimOnsetMat;

McGurkTrialCONOnset = [];
CONOnset = [];
McGurkTrialINCOnset = [];
INCOnset = [];

for i=1:a
    McGurkTrialCONOnset = [McGurkTrialCONOnset AllMcGurkOnset(i,find(AllMcGurkOnset(i,:)))+ BlockOnsetCON(i)];
    CONOnset = [CONOnset AllNonMcGurkOnset(i,find(AllNonMcGurkOnset(i,:)))+ BlockOnsetCON(i)];
    McGurkTrialINCOnset = [McGurkTrialINCOnset AllMcGurkOnset(i,find(AllMcGurkOnset(i,:)))+ BlockOnsetINC(i)];
    INCOnset = [INCOnset AllNonMcGurkOnset(i,find(AllNonMcGurkOnset(i,:)))+ BlockOnsetINC(i)];
end


% Enter source folder reads the image files
% ImagesFolder = sprintf('%s', 'Dummy_Images');
% ImagesFolder = 'F:\REMI\Matlab\DummyScans\';
ImagesFolder = 'C:\Users\Rémi\Documents\MATLAB\DummyScans\';

cd (ImagesFolder)
IMAGES_ls = dir('swauf*.img');

cd (StartDirectory)
   
matlabbatch ={};

matlabbatch{1,1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1,1}.spm.stats.fmri_spec.timing.RT = TR; 
matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t = NbSlices;
matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t0 = 1; % Reference slice

matlabbatch{1,1}.spm.stats.fmri_spec.fact = struct('name',{},'levels',{});

matlabbatch{1,1}.spm.stats.fmri_spec.bases.hrf.derivs = [0,0]; % First is time derivative, Second is dispersion

matlabbatch{1,1}.spm.stats.fmri_spec.volt = 1;

matlabbatch{1,1}.spm.stats.fmri_spec.global = 'None';

matlabbatch{1,1}.spm.stats.fmri_spec.mask = {};

matlabbatch{1,1}.spm.stats.fmri_spec.cvi = 'AR(1)';

AnalysisFolder = [pwd, filesep, 'TEST'];

matlabbatch{1,1}.spm.stats.fmri_spec.dir{1,1} = AnalysisFolder;

matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).multi{1} = '';
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).regress = struct('name',{},'val',{});
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).hpf = 128;

% Names them with their absolute pathnames
for j = 1:NbSession*(100)*NbBlockdTotal/TR+10
    matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).scans{j,1} = [ImagesFolder, filesep, IMAGES_ls(1).name];
end

% Names them with its absolute pathname
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).multi_reg{1} = {};


matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,1).name = Conditions_Names{1};
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,1).duration = 83; % 0 for event design1.0
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,1).tmod = 0;
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,1).pmod=struct('name',{},'param',{}, 'poly', {});
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,1).onset = BlockOnsetCON;

matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,2).name = Conditions_Names{2};
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,2).duration = 0; % 0 for event design
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,2).tmod = 0;
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,2).pmod=struct('name',{},'param',{}, 'poly', {});
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,2).onset = McGurkTrialCONOnset;

matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,3).name = Conditions_Names{3};
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,3).duration = 0; % 0 for event design
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,3).tmod = 0;
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,3).pmod=struct('name',{},'param',{}, 'poly', {});
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,3).onset = CONOnset;



matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,4).name = Conditions_Names{4};
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,4).duration = 83; % 0 for event design1.0
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,4).tmod = 0;
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,4).pmod=struct('name',{},'param',{}, 'poly', {});
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,4).onset = BlockOnsetINC;

matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,5).name = Conditions_Names{5};
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,5).duration = 0; % 0 for event design
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,5).tmod = 0;
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,5).pmod=struct('name',{},'param',{}, 'poly', {});
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,5).onset = McGurkTrialINCOnset;

matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,6).name = Conditions_Names{6};
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,6).duration = 0; % 0 for event design
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,6).tmod = 0;
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,6).pmod=struct('name',{},'param',{}, 'poly', {});
matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,1).cond(1,6).onset = INCOnset;


cd (AnalysisFolder)

save (strcat('First_Level_TEST_jobs'));
save ('Onset.mat', 'CONOnset', 'INCOnset', 'McGurkTrialCONOnset', 'McGurkTrialINCOnset')

spm_jobman('run', matlabbatch)

cd ..