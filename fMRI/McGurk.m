function McGurk (Verbosity)

%

% TO DO LISTS :

%	- Do I want to collect more time stamp (audio-start...) and keep having the different sanity check or other reasons ???
%	- Clear a lot of variables before saving
%	- Decide what type of trigger I use : serial or response box-like ?
%	- Code something that extracts the different SOT for the different
%	conditions !!!!!!
%	- Test !!!


% Make sure the script is running on Psychtoolbox-3
AssertOpenGL;

clc;
close all;
sca;
PsychPortAudio('Close');

clear Screen;

% --------------%
%     DEBUG     %
% --------------%

if (nargin < 1) % 0 to hide some errors, check-up, data, figures...
	Verbosity = 0;
end;


if Verbosity==1
	
	SubjID = char('RG');
	Session = 1;
	Run = 1;
	
	FileToLoad = strcat('Session_', num2str(Session),'_Run_', num2str(Run),'.mat');
	
	PsychDebugWindowConfiguration;
	
else

    % --------------------------%
    %     Subject's    info     %
    % --------------------------%

	SubjID = input('Subject''s ID? ','s');
	Session = input('Experiment session number? ');
	Run = input('Experiment run number? ');
	
	FileToLoad = strcat('Session_', num2str(Session),'_Run_', num2str(Run),'.mat');

	% set default values for input arguments
	if (~exist('SubjID'))
		SubjID = char('RG');
	end

	if (~exist('Run'))
		Run = 1;
	end

	Date = clock;	

end


% ---------------------------%
%     CREATE DIRECTORIES     %
% ---------------------------%


% Data recording directories
if exist(strcat('Subjects_Data'),'dir')==0
	mkdir Subjects_Data;
end;
DataDir = strcat(pwd, filesep, 'Subjects_Data');

% Basename for all file names
SavedMat = strcat(DataDir, filesep,'Subject_', SubjID, '_Session_', num2str(Session), '_Run_', num2str(Run), '.mat');

 
% Before overwriting files
if Verbosity==0 && exist(SavedMat,'file')
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

NbMovies = 4;

% Sound
SamplingFreq = 44100;
NbChannels = 2;
LatBias = 0;



McGurkNoiseRange = 	[0.15 0.1 0.3 0.15];
INCNoiseRange = 	[0.1 0.15 0.3 0.45];
CONNoiseRange = 	[0.15 0.15 0.1 0.3];

% Adds some whitenoise to the sound track : 0 -> no noise; 1 -> noise level equivalent to the max intensity present in the orginql soundtrack.
NoiseRange = [CONNoiseRange ; ... % CONGRUENT
	      INCNoiseRange ; ... % INCONGRUENT
	      McGurkNoiseRange];     % McGURK

      
% Stimuli file types
MovieType = '.mov';

% Stimuli directories
ConDir = 'CongMovies';
InconDir = 'IncongMovies';
McDir = 'McGurkMovies';


% Parameters to cut the movies
MovieOrigin = [290  350];
MovieDim2Extract = [160 110];
Scale = 4; % Movie rescale


% Stimuli directories
CongMoviesDir = strcat(pwd, filesep, ConDir, filesep);
IncongMoviesDir = strcat(pwd, filesep, InconDir, filesep);
McMoviesDir = strcat(pwd, filesep, McDir, filesep);

% List the movie files in the movie folders and returns a structure
CongMoviesDirList = dir(strcat(CongMoviesDir,'*', MovieType)); 
IncongMoviesDirList = dir(strcat(IncongMoviesDir,'*', MovieType));
McMoviesDirList = dir(strcat(McMoviesDir,'*', MovieType));      


% CHECKS NOISE LEVELS
fprintf('\n McGurk')
for i=1:NbMovies
	fprintf('\n Movie %s to be played with noise %.2f. \n', McMoviesDirList(i).name, McGurkNoiseRange(i)); 
end
fprintf('\n');
fprintf('\n INC')
for i=1:NbMovies
	fprintf('\n Movie %s to be played with noise %.2f. \n', IncongMoviesDirList(i).name, INCNoiseRange(i)); 
end
fprintf('\n');
fprintf('\n CON')
for i=1:NbMovies
	fprintf('\n Movie %s to be played with noise %.2f. \n', CongMoviesDirList(i).name, CONNoiseRange(i)); 
end
fprintf('\n');
Confirm = input('Are the noise level right? YES [1] or NO [0] ');

if Confirm==0 % Abort experiment if overwriting was not confirmed
	fprintf('Experiment aborted.\n')
	return
end


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
TriggerVersion = 2;

% Fixation block 
FixationTime = 25;

% --------------------------%
%         Keyboard          %
% --------------------------%

% Time available to answer before start of the following movie.
ResponseTimeWindow = 1;

% Switch KbName into unified mode: It will use the names of the OS-X platform on all platforms in order to make this script portable:
KbName('UnifyKeyNames');

[KeyboardNumbers, KeyboardNames] = GetKeyboardIndices;

KeyboardNames
KeyboardNumbers
%ResponseBox = input('Choose device for subject''s Response Box. '); % min(GetKeyboardIndices) % for key presses for the subject
%MacKeyboard = input('Choose device for operator''s Keyboard. '); % max(GetKeyboardIndices) % Mac's keyboard to quit if it is necessary

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



% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% Trials is a {5,1} cell
% {1,1} contains the trial number and the type of stimuli presented on this trial
% Trials(i,1:5) = [i p Choice n m];
% i		 is the trial number
% p		 is the trial number in the current block
% Choice	 contains the type of stimuli presented on this trial : 0--> Congruent, 1--> Incongruent, 2--> Counterphase.
% n 		 is the variable that says what kind of block came before the present one. Equals to 666 if there was no previous block. : 0--> Congruent, 1--> Incongruent, 2--> Counterphase.
% m 		 is the variable that says the length of the block that came before the present one. Equals to 666 if there was no previous block.

% {2,1} contains the name of the stim used
% {3,1} contains the level of noise used for this stimuli
% {4,1} contains the absolute path of the corresponding movie to be played
% {5,1} contains the absolute path of the corresponding sound to be played

load (FileToLoad);

NbTrials=NbTrialsPerRun;

if Verbosity==1
    NbTrials = 50;
    NbTrials=NbTrialsPerRun;
end

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
% oldRes=SetResolution('Resolution', ScreenID,1024,768,75);

% Open 'windowrect' sized window on screen, with black [0] background color:
[win winrect] = Screen('OpenWindow', ScreenID, 0);


Win_W = (winrect(3) - winrect(1));
Win_H = (winrect(4) - winrect(2));

% Define source and destination rectangle for the movie textures.
srcRect = [MovieOrigin  MovieOrigin+MovieDim2Extract];
dstRect = [(Win_W - MovieDim2Extract(1)*Scale)/2     (Win_H - MovieDim2Extract(2)*Scale)/2 ...
           (Win_W - MovieDim2Extract(1)*Scale)/2+MovieDim2Extract(1)*Scale    (Win_H - MovieDim2Extract(2)*Scale)/2+MovieDim2Extract(2)*Scale];

% Scale = Win_H/576*1.35; % Movie rescale
% Elevate = 0.1; % Raise the movie by a factor of "Elevate * Win_H"
	
ifi = Screen('GetFlipInterval', win);
FrameRate = Screen('FrameRate', ScreenID);
if FrameRate == 0
	FrameRate = 1/ifi;
end;

Screen(win,'TextFont', 'Arial');
Screen(win,'TextSize', 40);


Priority(MaxPriority(win));


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
while KbName(keyCode)~=RespB
    [secs, keyCode, deltaSecs] = KbWait(ResponseBox);
    KbName(keyCode)
    RespB
    WaitSecs(0.2);
end

DrawFormattedText(win, 'Press the key for the /D/ responses.', 'center', 'center', 255);
Screen('Flip', win);
while KbName(keyCode)~=RespD
    [secs, keyCode, deltaSecs] = KbWait(ResponseBox);
    KbName(keyCode)
    RespD
    WaitSecs(0.2);
end

DrawFormattedText(win, 'Press the key for the /G/ responses.', 'center', 'center', 255);
Screen('Flip', win);
while KbName(keyCode)~=RespG
    [secs, keyCode, deltaSecs] = KbWait(ResponseBox);
    KbName(keyCode)
    RespG
    WaitSecs(0.2);
end

DrawFormattedText(win, 'Press the key for the /K/ responses.', 'center', 'center', 255);
Screen('Flip', win);
while KbName(keyCode)~=RespK
    [secs, keyCode, deltaSecs] = KbWait(ResponseBox);
    KbName(keyCode)
    RespK
    WaitSecs(0.2);
end

DrawFormattedText(win, 'Press the key for the /P/ responses.', 'center', 'center', 255);
Screen('Flip', win);
while KbName(keyCode)~=RespP
    [secs, keyCode, deltaSecs] = KbWait(ResponseBox);
    KbName(keyCode)
    RespP
    WaitSecs(0.2);
end

DrawFormattedText(win, 'Press the key for the /T/ responses.', 'center', 'center', 255);
Screen('Flip', win);
while KbName(keyCode)~=RespT
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
disp(['Subj ' SubjID ' / Session ' num2str(Session) ' / Run ' num2str(Run) ])
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

NoVols = 0;

% VERSION 1 = use the trigger signal
if TriggerVersion == 1
	while NoVols <= NbVolToDiscard+1 
		[secs, keyCode, deltaSecs] = KbWait(ResponseBox);
		if (keyCode(Trigger))
			NoVols = NoVols + 1;
			fprintf('\n Trigger for volume #%i received. \n', NoVols);
			WaitSecs(0.5);
        end
        if NoVols==1
            tic;
        end
	end
% VERSION 2 = use the trigger signal from the serial port
elseif TriggerVersion == 2
	% Let us make sure that the trigger buffer is empty
	[IOData, treceived] = IOPort('Read', myport);
	while NoVols <= NbVolToDiscard+1
		% with real pulse
		[IOData, secs] = IOPort('Read', myport, 1, 1);
		if isempty(IOData) == 0
			NoVols = NoVols + 1;
			fprintf('\n Serial Port trigger for volume #%i received. \n', NoVols);
			WaitSecs(0.5);
        end
        if NoVols==1
            tic;
        end
	end
end


StartExpTime = secs;

% --------------------------%
%       TRIALS LOOPS        %
% --------------------------%

for j=1:NbTrials
    
    if mod(j,10)==0
        fprintf('\n Trial number #%i. \n', j);
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
    	
   	% Fill up audio buffer with the sound
	PsychPortAudio('FillBuffer', SoundHandle, Z);
	
	Screen('Flip', win);


	% --------------------------%
	%          MOVIE            %
	% --------------------------%
	% Open the movie file
    % The special flags = 2 is play a soundless movie, but that is what we want as PsychPortAudio takes care of playing the sound.
    % As the movies are around 2 secs long, the preload is set to 3 to load the whole movie in the RAM.
	[movie movieduration fps width height] = Screen('OpenMovie', win, MovieName,[], 3, 2); 
	
	% Calculate display rectangle
    % Movie size is 720*576
	% srcRect = [0 0 width height];
	% dstRect = [((Win_W - Scale*width)/2) ((Win_H - Scale*height)/2)-Elevate*Win_H ((Win_W + Scale*width)/2) ((Win_H + Scale*height)/2)-Elevate*Win_H];
    
	% Start playback engine
	Screen('PlayMovie', movie, 1, [], 0);
	
	% Wait for next movie frame, retrieve texture handle to it
	[tex, pts] = Screen('GetMovieImage', win, movie); % Gets the first movie frame and turns into a PTB texture
	
	Screen('DrawTexture', win, tex, srcRect, dstRect); % Draw the texture to the screen
	
	Screen('Close', tex); % Let go of the texture 
	Screen('DrawingFinished', win);
	
	% Reinitialises keyboard queue
        KbQueueFlush(ResponseBox);
	
    % --------------------------%
	%           PLAY            %
	% --------------------------%
        
	% START SOUND : no start time is specified hoping that movie and sound are going to start sufficiently in synch.
	PsychPortAudio('Start', SoundHandle, 1, []);	


   	 % START MOVIE : Actually show the first frame of the movie...
	T_VisualOnset = Screen('Flip', win, []); % ... by flipping the screen
	
	[tex, pts] = Screen('GetMovieImage', win, movie); % Gets the second movie frame and turns into a PTB texture


	% Playback loop to play the rest of the movie, that is as long as the texture from GetMovieImage is not <= to 0
	while tex > 0
			
		Screen('DrawTexture', win, tex, srcRect, dstRect); % Draw the texture to the screen
		
		Screen('Close', tex); % Let go of the texture
		
		Screen('DrawingFinished', win);
		
		Screen('Flip', win); % Actually show the image to the subject
        
		[tex, pts] = Screen('GetMovieImage', win, movie); % Gets the next movie frame and turns into a PTB texture        
			
	end;
	
	Screen('Flip', win);
	
	% Adapts the time the black screen + fixation cross has to be displayed to how long the movie lasted : to make sure that the Time(movie)+Time(Fixation)=3
	WaitSecs(2 + ResponseTimeWindow - (GetSecs - T_VisualOnset));

		
    % --------------------------%
	%        RESPONSE           %
	% --------------------------%
	[pressed, firstPress] = KbQueueCheck(ResponseBox);
        
        % extract keypress time if there is one
	if pressed==1
		for i=1:length(firstPress) % make all non pressed keys values equal to 0
			if firstPress(i)==0
				firstPress(i)=Inf;
			end
		end
		[X Y] = min(firstPress) ; % we take the first keypress
		RT = X - T_VisualOnset;
		Resp = Y ;
	else
		RT = 3 ;
		Resp = 999 ;
	end

	
	% --------------------------%
	%  CLOSE TEX & APPENDS      %
	% --------------------------%
       
    % Close the movie but before we note the number of frame dropped during
    % the whole presentation of the movie
    Screen('PlayMovie', movie, 0);
    Screen('CloseMovie', movie);

    % Stop sound
    PsychPortAudio('Stop', SoundHandle, 1) ;

    % APPENDS RESULTS to the Trials{1,1} matrix and Stimulus Onset Time to Trials{6,1}
    Trials{1,1}(j,6:7) = [RT Resp];    	
    Trials{6,1}(j,1) = T_VisualOnset-StartExpTime;
	
	
	% --------------------------%
	%         FIXATION          %
	% --------------------------%
	
	% A fixation of 25 secs at regular intervals and saves
	if mod(j,NbTrialsPerRun/NbFix)==0

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

end;


% We are done with the experiment proper.
% Close everything
KbQueueRelease(ResponseBox);
PsychPortAudio('Close');
ShowCursor;
ListenChar()
sca;
clear Screen;

if TriggerVersion == 2
	IOPort('ConfigureSerialPort', myport, ['StopBackgroundRead']);
	IOPort('Close', myport);
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
end

toc

% Saving the data
save (SavedMat);


% --------------------------%
%     Sorting   Answers     %
% --------------------------%
% This gives a 1 if the answer is the same as the auditory stim :
% In other words :
% For Congruent trials : 1 --> Hit; 0 --> Miss
% For Incongruent trials : 1 --> Hit; 0 --> Miss
% For McGurk trials : 0 --> McGurk effect worked; 0 --> Miss


KbName('UnifyKeyNames');

for i=1:NbTrials
	
	switch KbName( Trials{1,1}(i,7) ) % Check responses given
		case RespB
			if Trials{2,1}(i,8)=='B'
				Trials{1,1}(i,8) = 1;
			else
				Trials{1,1}(i,8) = 0;
			end;
			
		case RespD
			if Trials{2,1}(i,8)=='D'
				Trials{1,1}(i,8) = 1;
			else
				Trials{1,1}(i,8) = 0;
			end;
		
        case RespG
            if Trials{2,1}(i,8)=='G'
                Trials{1,1}(i,8) = 1;
            elseif Trials{1,1}(i,3)==2
                Trials{1,1}(i,8) = 1;
            else
                Trials{1,1}(i,8) = 0;
            end

        case RespK
            if Trials{2,1}(i,8)=='K'
                Trials{1,1}(i,8) = 1;
            elseif Trials{1,1}(i,3)==2
                Trials{1,1}(i,8) = 1;
            else            
                Trials{1,1}(i,8) = 0;
            end
			
		case RespP
			if Trials{2,1}(i,8)=='P'
				Trials{1,1}(i,8) = 1;
			else
				Trials{1,1}(i,8) = 0;
			end;
			
		case RespT
			if Trials{2,1}(i,8)=='T'
				Trials{1,1}(i,8) = 1;
			else
				Trials{1,1}(i,8) = 0;
			end;
					
		otherwise
			Trials{1,1}(i,8) = 999;
	end;
end;


% --------------------------%
%       SAVING DATA         %
% --------------------------%

clear KeyboardNames KeyboardNumbers KeysOfInterest MacKeyboard ResponseBox ResponseTargetKeys SamplingFreq Scale SoundHandle ScreenID SoundLength SoundName Resp RT T_VisualOnset TriggerVersion Verbosity Win_H Win_W X Z deltaSecs dstRect firstPress height i j keyCode keyIsDown movie movieduration pressed pts secs srcRect tex width win winrect
% Saving the data
save (SavedMat);

