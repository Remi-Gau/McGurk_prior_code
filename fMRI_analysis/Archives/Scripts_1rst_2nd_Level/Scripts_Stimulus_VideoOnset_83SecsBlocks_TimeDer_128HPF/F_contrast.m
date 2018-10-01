
clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults


% Subject's Identity and Session number
SubjID = input('Subject''s ID? ','s');

NbSession = 7;

NbCondition = 6;

RealParam = 6;

NbBlockTypes = 2;

%  Folders definitions
PresentFolder = pwd;

SubjectFolder = strcat(pwd, filesep, SubjID, filesep);

AnalysisFolder = strcat(SubjectFolder, 'Analysis', filesep);

SPM2Load = strcat(AnalysisFolder, 'SPM.mat');

% Load the right SPM.mat
%cd(AnalysisFolder)
%load SPM.mat





% TrialPositionCON = [ repmat([repmat(	[1 0 0 0 0 0 0 0 0 0 ; ...
% 					 0 0 1 0 0 0 0 0 0 0 ; ...
% 					 0 0 0 0 1 0 0 0 0 0 ; ...
% 					 0 0 0 0 0 0 1 0 0 0 ; ...
% 					 0 0 0 0 0 0 0 0 1 0 ], 1, PreviousBlockType) zeros(5,TrialPosition*(Current_BlockType-1)*PreviousBlockType*2) zeros(5,RealParam)], 1, NbSession) zeros(5,NbSession) ];

Movement=[ zeros(RealParam, 2*NbCondition) eye(RealParam,RealParam) zeros(RealParam, (2*NbCondition+RealParam)*(NbSession-1) ) zeros(RealParam, NbSession) ];

for i=2:NbSession
    Movement = [ Movement ; zeros(RealParam, (2*NbCondition+RealParam)*(i-1)) zeros(RealParam, 2*NbCondition) eye(RealParam,RealParam) zeros(RealParam, (2*NbCondition+RealParam)*(NbSession-i) ) zeros(RealParam, NbSession) ];		
end


				
clear matlabbatch



matlabbatch{1,1}.spm.stats.con.spmmat = {SPM2Load};
matlabbatch{1,1}.spm.stats.con.delete = 0;


matlabbatch{1,1}.spm.stats.con.consess{1,1}.fcon.name = 'Movement';
matlabbatch{1,1}.spm.stats.con.consess{1,1}.fcon.convec{1,1} = Movement ;
matlabbatch{1,1}.spm.stats.con.consess{1,1}.fcon.sessrep = 'none';







cd(SubjectFolder)

save (strcat('Fcon_', SubjID,'_jobs'));

spm_jobman('run', matlabbatch);

cd(PresentFolder)