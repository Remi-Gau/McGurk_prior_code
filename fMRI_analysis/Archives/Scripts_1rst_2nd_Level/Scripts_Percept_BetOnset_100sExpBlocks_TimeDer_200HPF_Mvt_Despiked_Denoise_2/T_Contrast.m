clc
clear

spm_jobman('initcfg')
spm_get_defaults;
global defaults


%  Folders definitions
cd ..
PresentFolder = pwd;

% Conditions Names
Trials_Types = { 'McGurk_in_Congruent',	'Congruent', 'McGurk_in_Incongruent', 'Incongruent' };

Response_Category = {'Wrong', 'Visual', 'Auditory', 'Fused', 'Missed'};

A =  cell(length(Trials_Types)*length(Response_Category),1);

for i=1:length(Trials_Types)
    for j=1:length(Response_Category)
        A{j+length(Response_Category)*(i-1),1} = strcat(Trials_Types{1,i}, '_trials_', Response_Category{1,j}, '_answers');
    end
end

A{1,1} = 'McGurk_in_Congruent_trials_Wrong-Visual_answers';
A{8,1} = 'Congruent_trials_Auditory-Visual_answers';
A{10,1} = 'Congruent_trials_Wrong-Fused_answers';
A{11,1} = 'McGurk_in_Incongruent_trials_Wrong-Visual_answers';
A{16,1} = 'Incongruent_trials_Wrong-Fused_answers';
A{20,1} = 'Missed_trials';

A([2 5 6 7 9 12 15 19], :) = [];

Conditions_Names = char(A)

clear A i j



% Subject's Identity and Session number
SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98]

try
    
    for h=1:length(SubjectsList)
        
        SubjID=num2str(SubjectsList(h))
        
        
        SubjectFolder = strcat(pwd, filesep, SubjID, filesep);
        SubjectStructuralFolder = strcat(pwd, filesep, SubjID, filesep, 'Structural', filesep);
        AnalysisFolder = fullfile(SubjectFolder, 'Analysis_Percept_BetOnset_100ExpBlock_TimeDer_200HPF_Mvt_Despiked_Denoise_2');
        
        
        cd(AnalysisFolder)
        
        delete spmT*.*
        delete con*.*
        
        load ('SOT.mat', 'Sorted_SOT')
        
        cellfun('length', Sorted_SOT)
        X = ~cellfun('isempty', Sorted_SOT)
        
        % Load the right SPM.mat
        cd(fullfile(SubjectFolder, 'Analysis_Percept_BetOnset_100ExpBlock_TimeDer_Despiked_Denoise_2'));
        load ('Denoise.mat', 'DenoiseResults')
        RealParam = 6+DenoiseResults.pcnum;
        
        cd(AnalysisFolder)
        load SPM.mat
        NbRegressors = size(SPM.xX.X,2);
        
        matlabbatch = {};
        
        matlabbatch{1}.spm.stats.con.spmmat = {fullfile(fullfile(pwd, 'SPM.mat'))};
        matlabbatch{1}.spm.stats.con.delete = 1;
        
        %% Defines the contrasts for the events
        for i=1:size(X,1)
            
            Weight = sum(X(i,:));
            
            if sum(X(i,:))==0
                Z = [1 zeros(1,size(SPM.xX.X,2)-1)];
                cname = 'Dummy Contrast';
                
            else
                Z = [];
                
                for j=1:size(X,2)
                    if X(i,j)==0
                        Z = [Z zeros(1,2*length(X(X(:,j)==1))) zeros(1,2) zeros(1,RealParam)];
                    else
                        Z = [Z zeros(1,2*length(X(X(1:i-1,j)==1))) 1/Weight 0 zeros(1,2*length(X(X(i+1:end,j)==1))) zeros(1,2) zeros(1,RealParam)];
                    end
                end
                
                cname = Conditions_Names(i,:);
                
                Z = [Z zeros(1,size(X,2))];
                
            end
            
            matlabbatch{1}.spm.stats.con.consess{1,i}.tcon.name = cname;
            matlabbatch{1}.spm.stats.con.consess{1,i}.tcon.convec = Z;
            matlabbatch{1}.spm.stats.con.consess{1,i}.tcon.sessrep = 'none';
            
        end
        
        clear Weight
        
        %% Defines the contrasts for the blocks
        Z_CON = [];
        Z_INC = [];
        
        for j=1:size(X,2)
            Z_CON = [Z_CON zeros(1, 2*sum(X(:,j))) 1  0  zeros(1,RealParam)];
            Z_INC = [Z_INC zeros(1, 2*sum(X(:,j))) 0  1  zeros(1,RealParam)];
        end
        
        Z_CON = [Z_CON zeros(1,size(X,2))];
        Z_INC = [Z_INC zeros(1,size(X,2))];
        
        cname = 'CON_Block';
        matlabbatch{1}.spm.stats.con.consess{1,end+1}.tcon.name = cname;
        matlabbatch{1}.spm.stats.con.consess{1,end}.tcon.convec = Z_CON;
        matlabbatch{1}.spm.stats.con.consess{1,end}.tcon.sessrep = 'none';
        
        cname = 'INC_Block';
        matlabbatch{1}.spm.stats.con.consess{1,end+1}.tcon.name = cname;
        matlabbatch{1}.spm.stats.con.consess{1,end}.tcon.convec = Z_INC;
        matlabbatch{1}.spm.stats.con.consess{1,end}.tcon.sessrep = 'none';
        
        cname = 'CON_Block > INC Block';
        matlabbatch{1}.spm.stats.con.consess{1,end+1}.tcon.name = cname;
        matlabbatch{1}.spm.stats.con.consess{1,end}.tcon.convec = Z_CON(:)-Z_INC(:);
        matlabbatch{1}.spm.stats.con.consess{1,end}.tcon.sessrep = 'none';
        
        cname = 'INC_Block > CON Block';
        matlabbatch{1}.spm.stats.con.consess{1,end+1}.tcon.name = cname;
        matlabbatch{1}.spm.stats.con.consess{1,end}.tcon.convec = Z_INC(:)-Z_CON(:);
        matlabbatch{1}.spm.stats.con.consess{1,end}.tcon.sessrep = 'none';
        
        
        %% Defines the contrasts for the joint events
        JointContrastsNames = {'All Congruent Trials' 'All Incongruent Trials' 'All McGurk Trials' 'All Incongruent and McGurk Trials'...
            'Incongruent trials wrong visual fused answers' ...
            'McGurk trials auditory answers' 'McGurk trials wrong visual fused answers' ...
            'McGurk trials in congruent context : Fused+Auditory' 'McGurk trials in incongruent context: Fused+Auditory' 'McGurk trials auditory answers' 'McGurk trials fused answers' 'McGurk trials non fused answers'...
            'All Events Trials'};
        
        ContrasOfInterest = { 4:5 ; 9:11 ; [1:3 6:8] ; [1:3 6:11] ; ...
            9:10 ; ...
            [2 7] ; [1 3 6 8] ; ...
            2:3 ; [7 8] ; [2 7] ; [3 8] ; [1 2 6 7]; ...
            1:12};
        
        for i=1:length(JointContrastsNames)
            
            Z = [];
            
            for j=1:size(X,2)
                
                A = zeros(2, size(X,1));
                
                for k=1:length(ContrasOfInterest{i})
                    Weight = sum(X(ContrasOfInterest{i}(k),:));
                    A(1,ContrasOfInterest{i}(k))=1/Weight;
                end
                
                A(:,X(:,j)==0)=[];
                
                A = reshape(A,1,size(A,1)*size(A,2));
                
                Z = [Z A zeros(1,2+RealParam)];
                
            end
            
            Z = [Z zeros(1,size(X,2))];
            
            
            cname = JointContrastsNames{i};
            
            matlabbatch{1}.spm.stats.con.consess{1,end+1}.tcon.name = cname;
            matlabbatch{1}.spm.stats.con.consess{1,end}.tcon.convec = Z(:);
            matlabbatch{1}.spm.stats.con.consess{1,end}.tcon.sessrep = 'none';
        end
        
        %%
        MvtRegressor = [];
        RegBefMvt = 2*sum(X)+2+DenoiseResults.pcnum;
        for j=1:size(RegBefMvt,2)
            MvtRegressor = [MvtRegressor zeros(6,RegBefMvt(j)) eye(6)];
        end
        
        MvtRegressor = [MvtRegressor zeros(6,size(RegBefMvt,2))];
        
        matlabbatch{1}.spm.stats.con.consess{1,end+1}.fcon.name = 'Movement';
        matlabbatch{1}.spm.stats.con.consess{1,end}.fcon.convec = {MvtRegressor};
        matlabbatch{1}.spm.stats.con.consess{1,end}.fcon.sessrep = 'none';
        
        %%
        if DenoiseResults.pcnum~=0
            PC_Regressor = [];
            RegBefPC = 2*sum(X)+2;
            RegPerSess = RegBefPC+DenoiseResults.pcnum+6;
            RegPrevSess = [0 RegPerSess(1:end-1)];

            for j=1:size(RegBefPC,2)
                TEMP = [];
                TEMP = [zeros(DenoiseResults.pcnum,sum(RegPrevSess(1:j))) ...
                    zeros(DenoiseResults.pcnum,RegBefPC(j)) ...
                    eye(DenoiseResults.pcnum)];

                PC_Regressor = [PC_Regressor ; ...
                    TEMP zeros(DenoiseResults.pcnum,NbRegressors-size(TEMP,2))];
            end

            matlabbatch{1}.spm.stats.con.consess{1,end+1}.fcon.name = 'PCs';
            matlabbatch{1}.spm.stats.con.consess{1,end}.fcon.convec = {PC_Regressor};
            matlabbatch{1}.spm.stats.con.consess{1,end}.fcon.sessrep = 'none';
        end
        
        
        %%   Evaluate
        cd(AnalysisFolder)
        
        save (strcat('T_and_F_Contrast_Subject_', SubjID, '_jobs.mat'));
        
        fprintf('\nF Contrast estimation\n\n')
        spm_jobman('run', matlabbatch)
        
        %% Make a masked image of the subject structural
        imgsMat{1,1} = strcat(pwd, filesep, 'mask.hdr');
        
        try
            
            cd(SubjectStructuralFolder)
            
            StructuralList = dir('ws*.img');
            imgsMat{2,1} = strcat(pwd, filesep, StructuralList(1).name);
            
            imgsInfo = spm_vol(char(imgsMat));
            
            volumes = spm_read_vols(imgsInfo);
            
            A = volumes(:,:,:,1);
            
            Test = volumes(:,:,:,2);
            
            Test(A==0)=Test(A==0)*0.5;
            
            % spm_write_vol: writes an image volume to disk
            newImgInfo = imgsInfo(2);
            
            % Change the name in the header
            cd(AnalysisFolder)
            
            newImgInfo.fname = strcat(pwd, filesep, 'StructuralMasked.nii');
            newImgInfo.private.dat.fname = newImgInfo.fname;
            
            spm_write_vol(newImgInfo, Test);
            
        catch ME1
        end
        
        cd(PresentFolder)
        
        fprintf('\nThe analysis of the subject %s is done.\n\n', SubjID);
        
    end
    
catch ME2
    rethrow(ME2)
end
