clc
clear

StartingDirectory = pwd;

IndStart = 21;
MovieDuration = 1.6 ; % in secs
SamplesPerMovie = MovieDuration * 50 ; % 50 being the sampling rate

% Subject's Identity
SubjectsList = [1 24 32 41 48 69 73 82 98]; 


for SubjInd=1:1%length(SubjectsList)
    
    SubjID = num2str(SubjectsList(SubjInd))
    
    cd(fullfile(pwd, SubjID))
    
    if exist('EyeTrackerData', 'dir')==0; 
    
    else
        cd EyeTrackerData
        
        ResultsFile = dir ('Subject_*.txt');
        
        for j=1:1%length(ResultsFile)
            
            RunNb = ResultsFile(j).name(end-29);
            
            fid = fopen(ResultsFile(j,1).name);
            [Eye_Tmp] = textscan(fid,'%s %s %s %s %s %s %s %s %s %s %s %s %s', 'headerlines', IndStart, 'returnOnError', 0);
            fclose(fid);

            clear fid
            
            load(fullfile(pwd, '..', 'Behavioral', ['Subject_PIEMSI_' num2str(SubjID) '_Run_' num2str(RunNb) '.mat']), 'Trials')

            BLocTypeTrialType=Trials{1,1}(:,4:5);    

            % ----------------------------------------------------------------------- %
            %                         Separate messages from data
            % ----------------------------------------------------------------------- %
            IndMsg = strcmp('MSG',Eye_Tmp{:,2});
            IndDat = ~IndMsg;


            % ----------------------------------------------------------------------- %
            %                               Identify trials
            % ----------------------------------------------------------------------- %
            % Check the beginning of each trial
            A = char(Eye_Tmp{1,6});
            A = A(:,1:4);
            A = cellstr(A);
            A = strcmp('Stim', A);
            TrialsBegInd = A;
            B = find(A);
            TrialBegIndices = B;

            % Check the lines that are included in each trials
            C = zeros(length(A),1);
            for i=1:length(B)
                C(B(i)+1:B(i)+SamplesPerMovie) = ones(SamplesPerMovie,1);
            end
            C = istrue(C);
            C = [~IndMsg C];
            TrialsDatInd = all(C,2);

            % clear A B C
            
            
            % ----------------------------------------------------------------------- %
            %                               Analyse trials
            % ----------------------------------------------------------------------- %            
            % read gaze data colums:
            % 1-time 
            % 2-type (smp or msg) 
            % 3-trial 
            % 4-xgazeRaw 5-ygazeRaw 
            % 6-pupilWidth  7-pupilHeights 
            % 8-xgazeScreen 9-yGazeScreen
            % 10-timingViolation(0=none,1=yes) 
            % 11-latency

            % Time stamps
            EyeDat.Time = str2num(str2mat(Eye_Tmp{1,1}(TrialsDatInd,:)));
            startRec = str2num(str2mat(Eye_Tmp{1,1}(1,:)));
            EyeDat.Time = (EyeDat.Time - startRec)* 10^-6; % in s, relative to start of recording wich is directly after 4th trigger (iView measures in microseconds)
            
            % Actual sampling rate ; theoretical is 50 Hz
            sr = round(1/nanmedian(diff(EyeDat.Time)));
            if sr~=50
                disp(['Warning actual sampling rate is: ' num2str(sr) ])
            end

            
            % raw data in camera pixel space is used for analysis as it is numerically more
            % stable, whereas calibrated gaze data goes often astray
            EyeDat.x = str2num(str2mat(Eye_Tmp{1,4}(TrialsDatInd,:)));% horizontal eye pos in pixel on camera screen
            EyeDat.xCalib = str2num(str2mat(Eye_Tmp{1,8}(TrialsDatInd,:))) ;% calibrated horizontaleye pos on gaze screen

            EyeDat.y = str2num(str2mat(Eye_Tmp{1,5}(TrialsDatInd,:)));% vertical eye pos on camera screen
            EyeDat.yCalib = str2num(str2mat(Eye_Tmp{1,9}(TrialsDatInd,:))) ;% calibrated vertical eye pos on gaze screen

            EyeDat.WPupil = str2num(str2mat(Eye_Tmp{1,6}(TrialsDatInd,:))); % Width pupil
            EyeDat.HPupil = str2num(str2mat(Eye_Tmp{1,7}(TrialsDatInd,:))); % Height pupil

            EyeDat.Pupil = sqrt((EyeDat.HPupil/2).^2 + (EyeDat.WPupil/2).^2); % pupil radius

            
            %invalid data if pupil is not tracked
            Valid = ((EyeDat.WPupil) ~= 0) & ((EyeDat.HPupil) ~= 0);
            EyeDat.Valid = double(Valid); % valid = 1 = has pupil data, 0 otherwise
            EyeDat.PercValid = sum(EyeDat.Valid == 1)/length(EyeDat.Valid) *100;
            
            disp(['Run: ' num2str(RunNb) ])
            disp(['PercValidData: ' num2str(EyeDat.PercValid) '%' ])          

            
            %% Check distribution of valid samples in trials
            VALID=reshape(EyeDat.Valid, length(EyeDat.Valid)/SamplesPerMovie , SamplesPerMovie);           
            X = reshape(EyeDat.x, length(EyeDat.x)/SamplesPerMovie, SamplesPerMovie);
            Y = reshape(EyeDat.y, length(EyeDat.y)/SamplesPerMovie, SamplesPerMovie);
            
            %%
            CON = find(all(BLocTypeTrialType==repmat([0 0], size(BLocTypeTrialType,1), 1),2));
      
            figure('name', 'CON')
            hold on
            for TrialInd=1:length(CON)
                plot( X(CON(TrialInd),VALID(TrialInd,:)==1), ...
                      Y(TrialInd,VALID(TrialInd,:)==1), 'b')
            end
            
            
            INC = find(all(BLocTypeTrialType==repmat([1 1], size(BLocTypeTrialType,1), 1),2));
      
            figure('name', 'INC')
            hold on
            for TrialInd=1:length(INC)
                plot( X(TrialInd,VALID(TrialInd,:)==1), ...
                      Y(TrialInd,VALID(TrialInd,:)==1), 'r')
            end
            
            % clear sr EyeDat startRec TrialsDatInd IndMsg IndDatn nSample Valid TrialsBegInd
            
            
        end
    end
    
    
    cd(StartingDirectory)
    
    

end




