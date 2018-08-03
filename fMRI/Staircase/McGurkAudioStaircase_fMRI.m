function McGurkAudioStaircase_fMRI (Verbosity);

%

% TO DO LISTS :

clc;
close all;
sca;
PsychPortAudio('Close');


if (nargin < 1) % 0 to hide some errors, check-up, data, figures...
	Verbosity = 0; 
end;


% Make sure the script is running on Psychtoolbox-3
AssertOpenGL;

% Switch KbName into unified mode: It will use the names of the OS-X platform on all platforms in order to make this script portable:
KbName('UnifyKeyNames');



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

	% set default values for input arguments
	if (~exist('SubjID'))
		SubjID = char('RG');
	end

	if (~exist('Run'))
		Run = 1;
	end
	
	FileToLoad = strcat('Run_', num2str(Run),'.mat');

	Date = clock;	

end

ExternalVolumeSoundLevel = input('External Volume Sound Level ? ');



% Data recording directories
if (exist(strcat('Subjects_Data'),'dir')==0)
	mkdir Subjects_Data;
end;
DataDir = strcat(pwd, filesep, 'Subjects_Data');

% Basename for all file names
SavedMat = strcat(DataDir, filesep, 'Subject_', SubjID, '_AudioStaircase_Run_', num2str(Run), '.mat');


% Before overwriting files
if exist(SavedMat,'file')
    fprintf('The files\n')
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

% Stimuli file types
MovieType = '.mov';
SoundType = '.wav';

McDir = 'McGurkMovies';
ConDir = 'CongMovies';
InconDir = 'IncongMovies';


% Shorten Movie at the beginning by
MovieBegin = 0.04*10; % in s8

MovieLength = 38; % in frames


% Parameters to cut the movies
height = 576;
width = 720;

% Horizontal Offset
HorizonOffset = 18;



% Sound
SamplingFreq = 44100;
NbChannels = 2;
LatBias = 0;

NbLevels = 8;
% Adds some whitenoise to the sound track : 0 -> no noise; 1 -> noise level
% equivqlent to the max intensity present in the orginal soundtrack
NoiseSoundRange = [ linspace(0, 0.3, NbLevels); ...
                    linspace(0, 0.3, NbLevels); ...
                    linspace(0, 0.3, NbLevels); ...
                    linspace(0, 0.3, NbLevels); ...
                    linspace(0, 0.3, NbLevels); ...
                    linspace(0, 0.5, NbLevels); ...
                    linspace(0, 0.5, NbLevels); ...
                    linspace(0, 0.5, NbLevels)]; 


if MovieBegin~=0
    SoundBegin = MovieBegin;
else
    SoundBegin=1/SamplingFreq;
end


% --------------------------%
%         Keyboard          %
% --------------------------%

% Switch KbName into unified mode: It will use the names of the OS-X platform on all platforms in order to make this script portable:
KbName('UnifyKeyNames');

[KeyboardNumbers, KeyboardNames] = GetKeyboardIndices
%ResponseBox = input('Choose device for subject''s Response Box. '); % min(GetKeyboardIndices) % for key presses for the subject
%MacKeyboard = input('Choose device for operator''s Keyboard. '); % max(GetKeyboardIndices) % Mac's keyboard to quit if it is necessary

MacKeyboard = max(GetKeyboardIndices); % Mac's keyboard to quit if it is necessary
ResponseBox = min(GetKeyboardIndices); % For key presses for the subject

% Defines keys
Esc = KbName('ESCAPE'); % Quit keyCode

RespOTHER = 'space';


% On the left keypad
RespB = '7&';
RespD = '8*';
RespG = '9(';

% On the right keypad
RespK = '4$';
RespP = '3#';
RespT = '2@';

if MacKeyboard==ResponseBox & ismac==1
    RespB = 'LeftControl';
    RespD = 'LeftAlt';
    RespG = 'LeftGUI';
    RespK = 'RightGUI';
    RespP = 'RightAlt';
    RespT = 'LeftArrow';
end

ResponseTimeWindow = 1.1;


% -------------------------------------------------------------------------

StimType2Test = input('Which category to test : 1 = CON ; 2 = INC ; 3 = McGurk ? ');

if StimType2Test==3
    NbTrialsPerCondition=4;
else
    NbTrialsPerCondition=3;
end


[Trials] = TrialsRandom (NoiseSoundRange, StimType2Test, NbTrialsPerCondition, McDir, ConDir, InconDir, MovieType, SoundType)
% Returns a {4,1} cell
% {1,1} contains the trial number and the type of stimuli presented on this trial
% Trials(i,1) = [i NoiseLevelIndex];
% i		 is the trial number

% {2,1} contains the name of the stim used
% {3,1} contains the absolute path of the corresponding movie to be played
% {4,1} contains the absolute path of the corresponding sound to be played


NbTrials=length(Trials{1,1}(:,1))

fprintf('\nThis run should last %.0f min.\n\n', ceil( (1.5+ResponseTimeWindow) * NbTrials / 60) );
fprintf('\nThat is about %.0f RT.\n\n', ceil( (1.5+ResponseTimeWindow) * NbTrials / 2.56 + (1.5+ResponseTimeWindow) * NbTrials/2.56 * 10/100) );

fprintf('Do you want to continue?\n')
Confirm=input('Type ok to continue. ', 's');
if ~strcmp(Confirm,'ok') % Abort experiment if too long
	fprintf('Experiment aborted.\n')
        return
end

if Verbosity==1
    NbTrials=5
end

% -------------------------------------------------------------------------


try

    
% SOUND INIT
InitializePsychSound(1);
SoundHandle = PsychPortAudio('Open', [], [], 2, SamplingFreq, NbChannels);


% SCREEN INIT
% Choosing the display with the highest display number is a best guess about where you want the stimulus displayed.
% Usually there will be only one screen with id = 0, unless you use a multi-display setup.
ScreenID = max(Screen('Screens'));

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



% draw fixation at beginning of experiment
DrawFormattedText(win, '.', 'center' , 'center' , 255);
Screen('Flip', win);



disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(['Subj ' SubjID ' / Run ' num2str(Run) ])
disp('       READY TO START        ')
disp('Confirm with space bar press.')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

while KbName(KbName(keyCode)) ~= KbName('space')
    [secs, keyCode, deltaSecs] = KbWait(MacKeyboard);
end




% initialize key presses that are allowed for the experiment
ResponseTargetKeys = [KbName(RespB), KbName(RespD), KbName(RespG), KbName(RespK), KbName(RespP), KbName(RespT)];
KeysOfInterest = zeros(1,256);
KeysOfInterest(ResponseTargetKeys) = 1;

% Create the keyboard queue to collect responses.
KbQueueCreate(ResponseBox, KeysOfInterest);
KbQueueStart(ResponseBox);



WaitSecs(0.5);

tic

% --------------------------%
%       TRIALS LOOPS        %
% --------------------------%

ListenChar(2);

for j=1:NbTrials
    
    % Display which trial we are in
    if ceil(mod(j,NbTrials/10))==1
        fprintf('\n Trial number #%i out of %i. \n', j, NbTrials);
    end

	% Check for experiment abortion from operator
    [keyIsDown,secs,keyCode] = KbCheck(MacKeyboard);
	if (keyIsDown==1 && keyCode(Esc))
		break;
	end;
		
	% Reinitialises the pressed variables
	pressed = 0 ; RT = []; Resp = [];
	
	% Gets the stimuli name from the Trial cell given by the TrialsRandom function
	MovieName = [deblank(Trials{3,1}(j,:))];
	SoundName = [deblank(Trials{4,1}(j,:))];
    NoiseSoundLevel = Trials{1,1}(j,3);

    
  	% SOUND    
	% Read the wav file and adds some noise
	[Y,FS,NBITS]=wavread(SoundName);
	Z = transpose(Y);
	SoundLength = length(Z)/FS;
	clear Y;
    
    
   	A = NoiseSoundLevel * ( 2 * max(max(Z)) * rand(1, length(Z)) - max(max(Z)) );
   	A = [A ; A];
   	Z = A + Z;
    clear A;
    
    Z = Z(: , round(SoundBegin*SamplingFreq):round(SoundBegin*SamplingFreq+MovieLength*0.04*SamplingFreq));
    	
   	% Fill up audio buffer with the sound
    PsychPortAudio('FillBuffer', SoundHandle, Z );
	
    DrawFormattedText(win, '.', 'center' , 'center' , 255);
	Screen('Flip', win);

	
   	% MOVIE
	% Open the movie file
	% The special flags = 2 is play a soundless movie, but that is what we want as PsychPortAudio takes care of playing the sound.
	% As the movies are around 2 secs long, the preload is set to 3 to load the whole movie in the RAM.
	[movie movieduration fps width height] = Screen('OpenMovie', win, MovieName,[], 3, 2);
    
    [oldtimeindex] = Screen('SetMovieTimeIndex', movie, MovieBegin);

    
	% Start playback engine
	Screen('PlayMovie', movie, 1, [], 0);
	
	% Wait for next movie frame, retrieve texture handle to it
    [tex, pts] = Screen('GetMovieImage', win, movie, 1);

	
	Screen('DrawTexture', win, tex, srcRect, dstRect); % Draw the texture to the screen
	Screen('Close', tex); % Let go of the texture
    DrawFormattedText(win, '.', 'center' , 'center' , 255);
	Screen('DrawingFinished', win);
	   
        
	% START SOUND : no start time is specified hoping that movie and sound are going to start sufficiently in synch.
	PsychPortAudio('Start', SoundHandle, 1, []);	

	% Reinitialises keyboard queue
	KbQueueFlush(ResponseBox);
    
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

	WaitSecs(1.5 + ResponseTimeWindow - (GetSecs - T_VisualOnset));
	
	
	% --------------------------%
	%        RESPONSE           %
	% --------------------------%
	
	[pressed, firstPress]=KbQueueCheck(ResponseBox);
	
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
		RT = 666 ;
		Resp = 666 ;
	end
    
    
   	% Close the movie but before we note the number of frame dropped during
   	% the whole presentation of the movie
   	DroppedFrames = Screen('PlayMovie', movie, 0);
   	Screen('CloseMovie', movie);
         
   	% Stop sound, collect onset timestamp of sound
   	T_AudioOnset = PsychPortAudio('Stop', SoundHandle, 1); 		 	
    	 
	% APPENDS RESULTS to the Trials{1,1} matrix and to Trials{2,1}
	Trials{1,1}(j, 4:5) = [RT Resp];
  
    if mod(j,NbTrials/10)==0
            save (SavedMat, 'Trials', 'NbTrials', 'SubjID', 'Run', 'RespB', 'RespG', 'RespK', 'RespD', 'RespP', 'RespT', 'RespOTHER', 'NoiseSoundRange', 'StimType2Test', 'ExternalVolumeSoundLevel'); 
    end;
    
end;



% We are done we the experiment proper.
% Close everything
KbQueueRelease(ResponseBox);
PsychPortAudio('Close');
ShowCursor;
sca;
clear Screen;
ListenChar

catch
KbQueueRelease(ResponseBox);
PsychPortAudio('Close');
ShowCursor;
sca;
clear Screen;
ListenChar
psychrethrow(psychlasterror);
end;

toc

% Saving the data
save (SavedMat, 'Trials', 'NbTrials', 'SubjID', 'Run', 'RespB', 'RespG', 'RespK', 'RespD', 'RespP', 'RespT', 'RespOTHER', 'NoiseSoundRange', 'StimType2Test', 'ExternalVolumeSoundLevel');


% --------------------------%
%     Sorting   Answers     %
% --------------------------%
for i=1:NbTrials
	switch Trials{1,1}(i,2)
		case 2 % if a McGurk Trial
			switch Trials{2,1}(i,8)
				case 'B'
					switch KbName( Trials{1,1}(i,5) ) % Check responses given
						case RespB
						Trials{1,1}(i,6) = 2; % McGurk did not work
						case RespD
						Trials{1,1}(i,6) = 3; % McGurk worked
						otherwise
						Trials{1,1}(i,6) = 4;
					end

				case 'P'
					switch KbName( Trials{1,1}(i,5) ) % Check responses given
						case RespP
						Trials{1,1}(i,6) = 2;
						case RespT
						Trials{1,1}(i,6) = 3;
						otherwise
						Trials{1,1}(i,6) = 4;
					end
			end
		
		otherwise
			switch Trials{2,1}(i,8)
				case 'B'
					if Trials{1,1}(i,5) == KbName(RespB) % Check responses given
						Trials{1,1}(i,6) = 2;
					else
						Trials{1,1}(i,6) = 3;
					end

				case 'D'
					if Trials{1,1}(i,5) == KbName(RespD) % Check responses given
						Trials{1,1}(i,6) = 2;
					else
						Trials{1,1}(i,6) = 3;
					end
				case 'G'
					if Trials{1,1}(i,5) == KbName(RespG) % Check responses given
						Trials{1,1}(i,6) = 2;
					else
						Trials{1,1}(i,6) = 3;
					end
				case 'K'
					if Trials{1,1}(i,5) == KbName(RespK) % Check responses given
						Trials{1,1}(i,6) = 2;
					else
						Trials{1,1}(i,6) = 3;
					end	
				case 'P'
					if Trials{1,1}(i,5) == KbName(RespP) % Check responses given
						Trials{1,1}(i,6) = 2;
					else
						Trials{1,1}(i,6) = 3;
					end
				case 'T'
					if Trials{1,1}(i,5) == KbName(RespT) % Check responses given
						Trials{1,1}(i,6) = 2;
					else
						Trials{1,1}(i,6) = 3;
					end
			end
			

	end
end


% --------------------------%
%       SAVING DATA         %
% --------------------------%

% Saving the data
save (SavedMat, 'Trials', 'NbTrials', 'SubjID', 'Run', 'RespB', 'RespG', 'RespK', 'RespD', 'RespP', 'RespT', 'RespOTHER', 'NoiseSoundRange', 'StimType2Test', 'ExternalVolumeSoundLevel');
