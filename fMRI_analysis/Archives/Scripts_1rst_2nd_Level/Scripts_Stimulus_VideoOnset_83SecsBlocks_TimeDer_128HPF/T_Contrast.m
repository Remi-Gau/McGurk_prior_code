

clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

% Subject's Identity and Session number
SubjID = input('Subject''s ID? ','s');

NbSession = 8;

NbCondition = 6;

RealParam = 6;

NbBlockTypes = 2;

%  Folders definitions
PresentFolder = pwd;

SubjectFolder = strcat(pwd, filesep, SubjID, filesep);

DICOMSourceFolder = strcat(SubjectFolder, 'RAW_EPI', filesep);

AnalysisFolder = strcat(SubjectFolder, 'Analysis', filesep);


cd(DICOMSourceFolder)

TEMP = dir;
TEMP2=[];

for i=3:length(TEMP)
    
    TEMP2 = [TEMP2 TEMP(i).isdir];
    
end
    
NbSession = length(find(TEMP2))

clear TEMP TEMP2

cd(PresentFolder)


% Load the right SPM.mat
cd(AnalysisFolder)
load SPM.mat


% Defines the contrasts

c = [ repmat([repmat([0 0 1 0 1 0], 1, NbBlockTypes) zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
cname = 'Activation All';
SPM.xCon = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);
 
c = [ repmat([repmat([0 0 1 0 0 0], 1, NbBlockTypes) zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
cname = 'McGurk Activation All';
SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ repmat([0 0 1 0 0 0 zeros(1,6) zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
cname = 'McGurk in Congruent';
SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ repmat([zeros(1,6) 0 0 1 0 0 0 zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
cname = 'McGurk in Incongruent';
SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ repmat([0 0 1 0 0 0  0 0 -1 0 0 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
cname = 'McGurkCon > McGurkInc ';
SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ repmat([0 0 -1 0 0 0  0 0 1 0 0 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
cname = 'McGurkInc > McGurkCon ';
SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ repmat([1 0 0 0 0 0  1 0 0 0 0 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
cname = 'All Block';
SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ repmat([1 0 0 0 0 0  0 0 0 0 0 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
cname = 'CON Block';
SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ repmat([0 0 0 0 0 0  1 0 0 0 0 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
cname = 'INC Block';
SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ repmat([1 0 0 0 0 0  -1 0 0 0 0 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
cname = 'CON Block > INC Block';
SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ repmat([-1 0 0 0 0 0  1 0 0 0 0 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
cname = 'INC Block > CON Block';
SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

c = [ repmat([0 0 0 0 1 0  0 0 0 0 0 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
cname = 'CON Trials activation';
SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs)

c = [ repmat([0 0 0 0 0 0  0 0 0 0 1 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
cname = 'INC Trials activation';
SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs)




% Evaluate
spm_contrasts(SPM);



cd (PresentFolder)


return



