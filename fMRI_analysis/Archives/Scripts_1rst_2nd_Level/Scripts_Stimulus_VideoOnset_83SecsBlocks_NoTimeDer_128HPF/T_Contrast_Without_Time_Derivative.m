

clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults

%  Folders definitions
PresentFolder = pwd;

NbCondition = 6;
RealParam = 6;
NbBlockTypes = 2;

% Subject's Identity and Session number
% SubjID = input('Subject''s ID? ','s');

SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];

try

    for h=1:length(SubjectsList)
        
        SubjID=num2str(SubjectsList(h))

        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        NiftiSourceFolder = strcat(SubjectFolder, 'Nifti_EPI', filesep);
        AnalysisFolder = strcat(SubjectFolder, 'Analysis_Without_Temporal_Derivative', filesep);

        
        cd(NiftiSourceFolder)

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

        c = [ repmat([repmat([0 1 1], 1, NbBlockTypes) zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
        cname = 'Activation All';
        SPM.xCon = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

        c = [ repmat([repmat([0 1 0], 1, NbBlockTypes) zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
        cname = 'McGurk Activation All';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

        c = [ repmat([0 1 0 zeros(1,3) zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
        cname = 'McGurk in Congruent';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

        c = [ repmat([zeros(1,3) 0 1 0 zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
        cname = 'McGurk in Incongruent';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

        c = [ repmat([0 1 0  0 -1 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
        cname = 'McGurkCon > McGurkInc ';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

        c = [ repmat([0 -1 0  0 1 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
        cname = 'McGurkInc > McGurkCon ';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

        c = [ repmat([1 0 0  1 0 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
        cname = 'All Block';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);
        
        c = [ repmat([1 0 0  0 0 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
        cname = 'CON Block';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

        c = [ repmat([0 0 0  1 0 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
        cname = 'INC Block';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

        c = [ repmat([1 0 0  -1 0 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
        cname = 'CON Block > INC Block';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

        c = [ repmat([-1 0 0  1 0 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
        cname = 'INC Block > CON Block';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs);

        c = [ repmat([0 0 1  0 0 0  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
        cname = 'CON Trials activation';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs)

        c = [ repmat([0 0 0  0 0 1  zeros(1,RealParam)], 1, NbSession) zeros(1,NbSession) ];
        cname = 'INC Trials activation';
        SPM.xCon(end + 1) = spm_FcUtil('Set', cname, 'T','c', c(:), SPM.xX.xKXs)


        % Evaluate

        spm_contrasts(SPM);

        
        cd (PresentFolder)
        
        fprintf('\nThe analysis of the subject %s is done.\n\n', SubjID);

    end
    
catch
    lasterror
end 
