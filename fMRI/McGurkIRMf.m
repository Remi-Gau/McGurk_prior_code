function McGurk (Verbosity)

%

% TO DO LISTS :

%	- Do I want to collect more time stamp (audio-start...) and keep having the different sanity check or other reasons ???
%	- Clear a lot of variables before saving
%	- Decide what type of trigger I use : serial or response box-like ?
%	- Code something that extracts the different SOT for the different
%	conditions !!!!!!
%	- Test !!!


clc;
close all;
sca;
PsychPortAudio('Close');

clear Screen;

% Make sure the script is running on Psychtoolbox-3
AssertOpenGL;

% --------------%
%     DEBUG     %
% --------------%

if (nargin < 1) % 0 to hide some errors, check-up, data, figures...
	Verbosity = 0;
end;


if Verbosity==1
	
	SubjID = char('RG');
	Run = 1;
	
	FileToLoad = strcat('Run_', num2str(Run),'.mat');
	
	PsychDebugWindowConfiguration;
	
else

    % --------------------------%
    %     Subject's    info     %
    % --------------------------%

	SubjID = input('Subject''s ID? ','s');
	Run = input('Experiment run number? ');
	
	FileToLoad = strcat('Run_', num2str(Run),'.mat');

	% set default values for input arguments
	if (~exist('SubjID'))
		SubjID = char('RG');
	end

	if (~exist('Run'))
		Run = 1;
	end

	Date = clock;	

end


ExternalVolumeSoundLevel = input('External Volume Sound Level ? ');


% ---------------------------%
%     CREATE DIRECTORIES     %
% ---------------------------%


% Data recording directories
if exist(strcat('Subjects_Data'),'dir')==0
	mkdir Subjects_Data;
end;
DataDir = strcat(pwd, filesep, 'Subjects_Data');

% Basename for all file names
SavedMat = strcat(DataDir, filesep, 'Subject_', SubjID, '_Run_', num2str(Run), '.mat');

 
% Before overwriting files
if exist(SavedMat,'file')
    fprintf('The files\n ')
    disp(SavedMat)
    fprintf('already exists. Do you want to overwrite?\n')
    Confirm=input('Type ok for overwrite. ', 's');
    if ~strcmp(Confirm,'ok') % Abort experiment if overwriting was not confirmed
        fprintf('Experiment aborted.\n')
        return
    end
end


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


% --------------------------%
%      Global Variables     %
% --------------------------%

% Sound
SamplingFreq = 44100;
NbChannels = 2;
LatBias = 0;


McGurkNoiseRange = 	[.0 .0 .0 .25 repmat(0,1,4)];
INCNoiseRange = 	[.0 .0 .0 .0 .0 .0 .0 .0];
CONNoiseRange = 	[INCNoiseRange([4 6 8 1 5 2 7 3])];

% Adds some whitenoise to the sound track : 0 -> no noise; 1 -> noise level equivalent to the max intensity present in the orginql soundtrack.
NoiseRange = [CONNoiseRange ; ... % CONGRUENT
	          INCNoiseRange ; ... % INCONGRUENT
	          McGurkNoiseRange];     % McGURK

      
% Shorten Movie at the beginning by
MovieBegin = 0.04*8; % in secs

MovieLength = 38; % in frames

if MovieBegin~=0
    SoundBegin = MovieBegin;
else
    SoundBegin=1/SamplingFreq;
end


% Parameters to cut the movies
height = 576;
width = 720;

% Horizontal Offset
HorizonOffset = 18;


% --------------------------%
%     fMRI parameters       %
% --------------------------%

NbVolToDiscard = 5;

TR = 2.56;
NbTR = 305;

NbSlices=42;

% Wait for trigger with serial port trigger or from keyboard-like trigger
% 1 --> keyboard-like trigger
% 2 --> serial port trigger
TriggerVersion = 1;

% Fixation block 
FixationTime = 35;

% --------------------------%
%         Keyboard          %
% --------------------------%

% Switch KbName into unified mode: It will use the names of the OS-X platform on all platforms in order to make this script portable:
KbName('UnifyKeyNames');

[KeyboardNumbers, KeyboardNames] = GetKeyboardIndices;

KeyboardNames
KeyboardNumbers

MacKeyboard = max(GetKeyboardIndices) % Mac's keyboard to quit if it is necessary
ResponseBox = min(GetKeyboardIndices) % For key presses for the subject

% Defines keys
Esc = KbName('ESCAPE'); % Quit keyCode
Trigger = KbName('''"'); % Trigger keyCode

% On the left keypad

RespB = '7&';
RespD = '8*';
RespG = '9(';

% On the right keypad
RespK = '4$';
RespP = '3#';
RespT = '2@';


if MacKeyboard==ResponseBox
    RespB = 'LeftControl';
    RespD = 'LeftAlt';
    RespG = 'LeftGUI';
    RespK = 'RightGUI';
    RespP = 'RightAlt';
    RespT = 'LeftArrow';
end



% --------------------------%
%         Keyboard          %
% --------------------------%
% eye tracking initialization (calibration has been done before!)

EyeTracker = input('Use eyetracker ? YES = 1 ; NO = 0 ');




% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

load (FileToLoad);

% Trials is a {5,1} cell
% {1,1} contains the trial number and the type of stimuli presented on this trial
% Trials(i,1:5) = [i p Choice n m];
% i		 is the trial number
% p		 is the trial number in the current block
% TrialOnset	 is the onset of this movie
% Blocktype	 is the type of the current block
% Choice	 contains the type of stimuli presented on this trial : 0--> Congruent, 1--> Incongruent, 2--> Counterphase.

% {2,1} contains the name of the stim used
% {3,1} contains the level of noise used for this stimuli
% {4,1} contains the absolute path of the corresponding movie to be played
% {5,1} contains the absolute path of the corresponding sound to be played

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


NbTrials = length(Trials{1,1})

if Verbosity==1
	NbTrials = 5;
end

fprintf('\nThis run should last %.0f min.\n\n', ceil( (NbTrials / 12 *100  + 5 * TR + 25) / 60) );
fprintf('\nThis run should last %.0f TR.\n\n', ceil( (NbTrials / 12 *100  + 5 * TR + 25) / TR) );


% CHECKS NOISE LEVELS
fprintf('\n McGURK')
for i=1:NbMcMovies
	fprintf('\n Movie %s to be played with noise %.2f. \n', McMoviesDirList(i).name, McGurkNoiseRange(i)); 
end
fprintf('\n');
fprintf('\n INCONGRUENT')
for i=1:NbIncongMovies
	fprintf('\n Movie %s to be played with noise %.2f. \n', IncongMoviesDirList(i).name, INCNoiseRange(i)); 
end
fprintf('\n');
fprintf('\n CONGRUENT')
for i=1:NbCongMovies
	fprintf('\n Movie %s to be played with noise %.2f. \n', CongMoviesDirList(i).name, CONNoiseRange(i)); 
end
fprintf('\n');
Confirm = input('Are the noise level right? YES [1] or NO [0] ');

if Confirm==0 % Abort experiment if overwriting was not confirmed
	fprintf('Experiment aborted.\n')
	return
end

clear McGurkNoiseRange INCNoiseRange CONNoiseRange


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

try
    
if TriggerVersion == 2
	% IO PORT INIT
	% Opening the port
	portSettings = sprintf('BaudRate = 115200 InputBufferSize = 10000 ReceiveTimeout = 60');
	portSpec = FindSerialPort([], 1);
	% Open port portSpec with portSettings, return handle:
	myport = IOPort('OpenSerialPort', portSpec, portSettings);
	WaitSecs(1);
	IOPort('Read', myport);
end

  
% SOUND INIT
InitializePsychSound(1);
SoundHandle = PsychPortAudio('Open', [], [], 2, SamplingFreq, NbChannels);


% SCREEN INIT
% Choosing the display with the highest display number is a best guess about where you want the stimulus displayed.
% Usually there will be only one screen with id = 0, unless you use a multi-display setup.
ScreenID = max(Screen('Screens'));
oldRes = SetResolution(ScreenID, 800, 600);

% Open 'windowrect' sized window on screen, with black [0] background color:
[win winrect] = Screen('OpenWindow', ScreenID, 0);


Win_W = (winrect(3) - winrect(1));
Win_H = (winrect(4) - winrect(2));


Scale = Win_H/576; % Movie rescale       
Elevate = 0.11; % Raise the movie by a factor of "Elevate * Win_H"
srcRect = [0 0 width height];
dstRect = [((Win_W - Scale*width)/2)-HorizonOffset ((Win_H - Scale*height)/2)-Elevate*Win_H ((Win_W + Scale*width)/2)-HorizonOffset ((Win_H + Scale*height)/2)-Elevate*Win_H];

	
ifi = Screen('GetFlipInterval', win)
FrameRate = Screen('FrameRate', ScreenID)
if FrameRate == 0
	FrameRate = 1/ifi
end;

Screen(win,'TextFont', 'Arial');
Screen(win,'TextSize', 40);


Priority(MaxPriority(win));


if EyeTracker==1
    % initialize iView eye tracker
    host = '10.41.111.213'; % SMI machine ip: '10.41.111.213'
    port = 4444;
    %ivx = iViewXInitDefaults_joana(ScreenID, win, [], [], host, port);
    ivx = iviewxinitdefaults2(win, 9,[], host, port); % original: ivx=iviewxinitdefaults(window, 9 , host, port);
    % ivx=iviewxinitdefaults(window, 9 , host, port)
    
    ivx.backgroundColour = 0; 
    [Success, ivx]=iViewX_joana('openconnection', ivx);
    [Success, ivx]=iViewX_joana('checkconnection', ivx);
    %if Success ~= 1;
    %    error('connection to eye tracker failed');
    %end
end


% Hide the mouse cursor
HideCursor;

	
% --------------------------%
%           START           %
% --------------------------%

fprintf('\n\n')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('   Waiting for keypresses from subject   ')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
fprintf('\n\n')

keyCode=[];

DrawFormattedText(win, 'Press the key for the /B/ responses.', 'center', 'center', 255);
Screen('Flip', win);
[secs, keyCode, deltaSecs] = KbWait(ResponseBox);
while strcmp(KbName(keyCode),RespB)==0
    [secs, keyCode, deltaSecs] = KbWait(ResponseBox);
    KbName(keyCode)
    RespB
    WaitSecs(0.2);
end

DrawFormattedText(win, 'Press the key for the /D/ responses.', 'center', 'center', 255);
Screen('Flip', win);
while strcmp(KbName(keyCode),RespD)==0
    [secs, keyCode, deltaSecs] = KbWait(ResponseBox);
    KbName(keyCode)
    RespD
    WaitSecs(0.2);
end

DrawFormattedText(win, 'Press the key for the /G/ responses.', 'center', 'center', 255);
Screen('Flip', win);
while strcmp(KbName(keyCode),RespG)==0
    [secs, keyCode, deltaSecs] = KbWait(ResponseBox);
    KbName(keyCode)
    RespG
    WaitSecs(0.2);
end

DrawFormattedText(win, 'Press the key for the /K/ responses.', 'center', 'center', 255);
Screen('Flip', win);
while strcmp(KbName(keyCode),RespK)==0
    [secs, keyCode, deltaSecs] = KbWait(ResponseBox);
    KbName(keyCode)
    RespK
    WaitSecs(0.2);
end

DrawFormattedText(win, 'Press the key for the /P/ responses.', 'center', 'center', 255);
Screen('Flip', win);
while strcmp(KbName(keyCode),RespP)==0
    [secs, keyCode, deltaSecs] = KbWait(ResponseBox);
    KbName(keyCode)
    RespP
    WaitSecs(0.2);
end

DrawFormattedText(win, 'Press the key for the /T/ responses.', 'center', 'center', 255);
Screen('Flip', win);
while strcmp(KbName(keyCode),RespT)==0
    [secs, keyCode, deltaSecs] = KbWait(ResponseBox);
    KbName(keyCode)
    RespT
    WaitSecs(0.2);
end


% initialize key presses that are allowed for the experiment
ResponseTargetKeys = [KbName(RespB), KbName(RespD), KbName(RespG), KbName(RespK), KbName(RespP), KbName(RespT)];
KeysOfInterest = zeros(1,256);
KeysOfInterest(ResponseTargetKeys) = 1;

% Create the keyboard queue to collect responses.
KbQueueCreate(ResponseBox, KeysOfInterest);
KbQueueStart(ResponseBox);


Screen('Flip', win);

WaitSecs(0.5);



disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(['Subj ' SubjID ' / Run ' num2str(Run) ])
disp('       READY TO START        ')
disp('Confirm with space bar press.')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

while KbName(KbName(keyCode)) ~= KbName('space')
    [secs, keyCode, deltaSecs] = KbWait(MacKeyboard);
end


% Suppress keypresses display to matlab prompt
ListenChar(2);


% ----------------------------------------- %
%    WAITING FOR TRIGGER OF DUMMY SCANS     %
% ----------------------------------------- %

% draw fixation at beginning of experiment
DrawFormattedText(win, '+', 'center' , 'center' , 255);
Screen('Flip', win);

fprintf('\n\n')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('  Waiting for dummy scans trigger  ')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

NoVols = 1;

DrawFormattedText(win, num2str(NbVolToDiscard-NoVols), 'center' , 'center' , 255);
Screen('Flip', win);


% VERSION 1 = use the trigger signal
if TriggerVersion == 1
	while NoVols <= NbVolToDiscard 
		[secs, keyCode, deltaSecs] = KbWait(ResponseBox);
		if (keyCode(Trigger))
            
            if NbVolToDiscard-NoVols>0
                DrawFormattedText(win, num2str(NbVolToDiscard-NoVols), 'center' , 'center' , 255);
            else
                DrawFormattedText(win, 'START', 'center' , 'center' , 255);
            end
            
            Screen('Flip', win);
            
			fprintf('\n Trigger for volume #%i received. \n', NoVols);
			WaitSecs(1);
            
            NoVols = NoVols + 1;
        end
        if NoVols==1
            tic;
        end
    end
    
% VERSION 2 = use the trigger signal from the serial port
elseif TriggerVersion == 2
	% Let us make sure that the trigger buffer is empty
	[IOData, treceived] = IOPort('Read', myport);
	while NoVols <= NbVolToDiscard
		% with real pulse
		[IOData, secs] = IOPort('Read', myport, 1, 1);
		if isempty(IOData) == 0
            
            if NbVolToDiscard-NoVols>0
                DrawFormattedText(win, num2str(NbVolToDiscard-NoVols), 'center' , 'center' , 255);
            else
                DrawFormattedText(win, 'START', 'center' , 'center' , 255);
            end
            
			fprintf('\n Serial Port trigger for volume #%i received. \n', NoVols);
			WaitSecs(1);
            
            NoVols = NoVols + 1;
            
        end
        if NoVols==1
            tic;
        end
	end
end



DrawFormattedText(win, '.', 'center' , 'center' , 255);
Screen('Flip', win);

% start eye tracking
if EyeTracker==1;  
    iViewX('clearbuffer', ivx);
    iViewX('startrecording', ivx);
    iViewX('message', ivx, ['Start_Experiment_Subject_', SubjID, '_Run_', num2str(Run)]); 
    iViewX('incrementsetnumber', ivx, 0);
end

StartExpTime = secs;

% --------------------------%
%       TRIALS LOOPS        %
% --------------------------%

% NbTrials = 1;

for j=1:NbTrials
    
    % Display which trial we are in
    if mod(j,12)==1
        fprintf('\n Trial number #%i. \n', j);
    end
    
    % Wait for an interblock interval every 12 trials
    if mod(j,12)==1 && j~=1
        WaitSecs(IBI);
    end
    
	% Check for experiment abortion from operator
    [keyIsDown,secs,keyCode] = KbCheck(MacKeyboard);
	if (keyIsDown==1 && keyCode(Esc))
		break;
	end;
		
    % Reinitialises the "pressed" variables
	pressed = 0 ;
	
    	% Gets the stimuli name from the Trial cell given by the TrialsRandom function
	MovieName = [deblank(Trials{4,1}(j,:))];
	SoundName = [deblank(Trials{5,1}(j,:))];

    
	% --------------------------%
	%          SOUND            %
	% --------------------------%
	% Read the wav file and adds some noise
	[Y,FS,NBITS]=wavread(SoundName);
	Z = transpose(Y);
	SoundLength = length(Z)/FS;
	clear Y;
    
   	A = NoiseRange(Trials{3,1}(j,1),Trials{3,1}(j,2)) * ( 2 * max(max(Z)) * rand(1, length(Z)) - max(max(Z)) );
   	A = [A ; A];
   	Z = A + Z;
    clear A;
    
    Z = Z(: , round(SoundBegin*SamplingFreq):round(SoundBegin*SamplingFreq+MovieLength*0.04*SamplingFreq));
    	
   	% Fill up audio buffer with the sound
	PsychPortAudio('FillBuffer', SoundHandle, Z);
	
	Screen('Flip', win);
    
    DrawFormattedText(win, '.', 'center' , 'center' , 255);
	Screen('Flip', win);


	% --------------------------%
	%          MOVIE            %
	% --------------------------%
	% Open the movie file
    % The special flags = 2 is play a soundless movie, but that is what we want as PsychPortAudio takes care of playing the sound.
    % As the movies are around 2 secs long, the preload is set to 3 to load the whole movie in the RAM.
	[movie movieduration fps width height] = Screen('OpenMovie', win, MovieName,[], 3, 2);
    
    [oldtimeindex] = Screen('SetMovieTimeIndex', movie, MovieBegin);
    
	% Start playback engine
	Screen('PlayMovie', movie, 1, [], 0);
	
	% Wait for next movie frame, retrieve texture handle to it
	[tex, pts] = Screen('GetMovieImage', win, movie); % Gets the first movie frame and turns into a PTB texture
	Screen('DrawTexture', win, tex, srcRect, dstRect); % Draw the texture to the screen
	Screen('Close', tex); % Let go of the texture
    DrawFormattedText(win, '.', 'center' , 'center' , 255);
	Screen('DrawingFinished', win);
	
	% Reinitialises keyboard queue
    KbQueueFlush(ResponseBox);
	
    % --------------------------%
	%           PLAY            %
	% --------------------------%
    
    if EyeTracker==1;   
        str = ['StimOn_Trial', num2str(j), '_Movie_', Trials{2,1}(j,:)];
        iViewX('message', ivx, str);
        iViewX('incrementsetnumber', ivx, j);
    end
        
	% START SOUND : no start time is specified hoping that movie and sound are going to start sufficiently in synch.
	PsychPortAudio('Start', SoundHandle, 1, []);	


   	 % START MOVIE : Actually show the first frame of the movie...
	T_VisualOnset = Screen('Flip', win, []); % ... by flipping the screen
	
	[tex, pts] = Screen('GetMovieImage', win, movie); % Gets the second movie frame and turns into a PTB texture


	% Playback loop to play the rest of the movie, that is as long as the texture from GetMovieImage is not <= to 0
	for h=1:MovieLength
			
		Screen('DrawTexture', win, tex, srcRect, dstRect); % Draw the texture to the screen
		
		Screen('Close', tex); % Let go of the texture
        
        DrawFormattedText(win, '.', 'center' , 'center' , 255);
		
		Screen('DrawingFinished', win);
		
		Screen('Flip', win); % Actually show the image to the subject
        
		[tex, pts] = Screen('GetMovieImage', win, movie); % Gets the next movie frame and turns into a PTB texture        
			
	end;
	
    DrawFormattedText(win, '.', 'center' , 'center' , 255);
    Screen('Flip', win);
    
    % ---------------------%
	%  CLOSE TEX & SOUND   %
	% ---------------------%
       
    % Close the movie but before we note the number of frame dropped during
    % the whole presentation of the movie
    Screen('PlayMovie', movie, 0);
    Screen('CloseMovie', movie);

    % Stop sound
    PsychPortAudio('Stop', SoundHandle, 1) ;
    
    
	
    if Trials{1,1}(j,2)~=12
        WaitSecs( (Trials{1,1}(j+1,3)-Trials{1,1}(j,3)) - (GetSecs - T_VisualOnset) ) ;
    else 
        WaitSecs( BlockDuration-Trials{1,1}(j,3) - (GetSecs - T_VisualOnset));
    end

		
    % --------------------------%
	%        RESPONSE           %
	% --------------------------%
	[pressed, firstPress] = KbQueueCheck(ResponseBox);
        
        % extract keypress time if there is one
	if pressed==1
		for i=1:length(firstPress)
			if firstPress(i)==0
				firstPress(i)=Inf;
			end
		end
		[X Y] = min(firstPress) ;
		RT = X - T_VisualOnset;
		Resp = Y ;
	else
		RT = 999 ;
		Resp = 999 ;
    end
    

    % APPENDS RESULTS to the Trials{1,1} matrix and Stimulus Onset Time to Trials{6,1}
    Trials{1,1}(j,6:7) = [RT Resp];    	
    Trials{6,1}(j,1) = T_VisualOnset-StartExpTime;	
    
    
    if j==NbTrials
        % --------------------------%
        %         FIXATION          %
        % --------------------------%

        % A fixation of 25 secs at regular intervals and saves
        fprintf('\n\n')
        disp('%%%%%%%%%%%%%%')
        disp('   FIXATION   ')
        disp('%%%%%%%%%%%%%%')
        fprintf('\n\n')

        DrawFormattedText(win, '+', 'center' , 'center' , 255);
        Screen('Flip', win);

        save (SavedMat);

        WaitSecs(FixationTime);
    
    end

end


% We are done with the experiment proper.
% Close everything
KbQueueRelease(ResponseBox);
PsychPortAudio('Close');
ShowCursor;
ListenChar()
sca;
clear Screen;

if TriggerVersion==2
	IOPort('ConfigureSerialPort', myport, ['StopBackgroundRead']);
	IOPort('Close', myport);
end

if EyeTracker==1    
    % Stop tracker
    iViewX('stoprecording', ivx);
    
    % Save data file
    TheDate = datestr(now, 'yyyy-mm-dd_HH.MM');
    SaveFile = strcat('"D:\Data\Remi\', 'Subject_', SubjID, '_Run_', num2str(Run), '_', TheDate, '.idf"');
    iViewX('datafile', ivx, SaveFile);
    
    %close iView connection
    iViewX('closeconnection', ivx);
end

catch
	KbQueueRelease(ResponseBox);
	PsychPortAudio('Close');
	ShowCursor;
	ListenChar()
	sca;
	clear Screen;
	psychrethrow(psychlasterror);
	
	if TriggerVersion == 2
		IOPort('ConfigureSerialPort', myport, ['StopBackgroundRead']);
		IOPort('Close', myport);
    end
    
    if EyeTracker==1    
        % Stop tracker
        iViewX('stoprecording', ivx);
        %close iView connection
        iViewX('closeconnection', ivx);
    end
end

% toc

% Saving the data
save (SavedMat);


clear winrect win width tex srcRect secs pts ptb_RootPath ptb_ConfigPath pressed oldtimeindex movie 
clear keyIsDown keyCode j ifi height h fps firstPress dstRect deltaSecs Z Win_W Win_H Verbosity 
clear T_VisualOnset T_AudioOnset SoundName SoundLength SoundHandle SoundBegin ScreenID Scale 
clear SamplingFreq ResponseTargetKeys ResponseBox Resp RT NBITS MovieOrigin MovieOrders MovieName 
clear MovieLength LatBias MacKeyboard KeysOfInterest HorizonOffset Framerate FileToLoad FS Elevate
clear Confirm movieduration FrameRate

% --------------------------%
%     Sorting   Answers     %
% --------------------------%
% This gives a 1 if the answer is the same as the auditory stim :
% In other words :
% For Congruent trials : 1 --> Hit; 0 --> Miss
% For Incongruent trials : 1 --> Hit; 0 --> Miss
% For McGurk trials : 0 --> McGurk effect worked; 1 --> Miss


KbName('UnifyKeyNames');

save(SavedMat);

for i=1:NbTrials

	   switch KbName( Trials{1,1}(i,7) ) % Check responses given
            case RespB
                if Trials{2,1}(i,8)=='B'
                    Trials{1,1}(i,8) = 1;
                elseif Trials{1,1}(i,5)==2
                    Trials{1,1}(i,8) = 1;                
                else
                    Trials{1,1}(i,8) = 0;
                end;

            case RespD
                if Trials{2,1}(i,8)=='D'
                    Trials{1,1}(i,8) = 1;
                elseif Trials{1,1}(i,5)==2 & Trials{2,1}(i,8)~='B'
                    Trials{1,1}(i,8) = 1;  
                else
                    Trials{1,1}(i,8) = 0;
                end;

            case RespG
                if Trials{2,1}(i,8)=='G'
                    Trials{1,1}(i,8) = 1;
                elseif Trials{1,1}(i,5)==2
                    Trials{1,1}(i,8) = 1;
                else
                    Trials{1,1}(i,8) = 0;
                end

            case RespK
                if Trials{2,1}(i,8)=='K'
                    Trials{1,1}(i,8) = 1;
                elseif Trials{1,1}(i,5)==2
                    Trials{1,1}(i,8) = 1;
                else            
                    Trials{1,1}(i,8) = 0;
                end

            case RespP
                if Trials{2,1}(i,8)=='P'
                    Trials{1,1}(i,8) = 1;
                elseif Trials{1,1}(i,5)==2
                    Trials{1,1}(i,8) = 1;                
                else
                    Trials{1,1}(i,8) = 0;
                end;

            case RespT
                if Trials{2,1}(i,8)=='T'
                    Trials{1,1}(i,8) = 1;
                elseif Trials{1,1}(i,5)==2 & Trials{2,1}(i,8)~='P'
                    Trials{1,1}(i,8) = 1;                                
                else
                    Trials{1,1}(i,8) = 0;
                end;

            otherwise
                Trials{1,1}(i,8) = 999;
       end
end


clear i ans NbChannels X Y StartXP


% --------------------------%
%       SAVING DATA         %
% --------------------------%

% Saving the data
save (SavedMat);
