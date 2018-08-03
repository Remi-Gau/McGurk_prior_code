function McGurk (Verbosity)

% FOR PSYCHOPHYSICS

% TO DO LISTS :
%	- analyse responses to stim : simplify


clc;
close all;
sca;
PsychPortAudio('Close');

clear Screen;


if (nargin < 1) % 0 to hide some errors, check-up, data, figures...
	Verbosity = 0;
end;


% Data recording directories
if (exist(strcat('Subjects_Data'),'dir')==0)
	mkdir Subjects_Data;
end;
DataDir = strcat(pwd, filesep, 'Subjects_Data');


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


% Basename for all file names
SavedMat = strcat(DataDir, filesep, 'Subject_', SubjID, '_Run_', num2str(Run), '.mat');

% Make sure the script is running on Psychtoolbox-3
AssertOpenGL;

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


% Sound
SamplingFreq = 44100;
NbChannels = 2;
LatBias = 0;

McGurkNoiseRange = 	[.0 .1 .1 .25 repmat(0,1,4)];
INCNoiseRange = 	[.0 .1 .1 .25 .25 .1 .1 .0];
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
%         Keyboard          %
% --------------------------%

% Switch KbName into unified mode: It will use the names of the OS-X platform on all platforms in order to make this script portable:
KbName('UnifyKeyNames');

%[KeyboardNumbers, KeyboardNames] = GetKeyboardIndices;
%ResponseBox = input('Choose device for subject''s Response Box. '); % min(GetKeyboardIndices) % for key presses for the subject
%MacKeyboard = input('Choose device for operator''s Keyboard. '); % max(GetKeyboardIndices) % Mac's keyboard to quit if it is necessary

MacKeyboard = max(GetKeyboardIndices); % Mac's keyboard to quit if it is necessary
ResponseBox = min(GetKeyboardIndices); % For key presses for the subject

% Defines keys
Esc = KbName('ESCAPE'); % Quit keyCode

RespOTHER = 'space';

% On the left keypad
RespB = 'LeftControl';
RespD = 'LeftGUI';
RespG = 'LeftAlt';
RespK = 'RightAlt';
RespP = 'RightGUI';
RespT = 'Application';

if MacKeyboard==ResponseBox
    RespD = 'LeftAlt';
    RespG = 'LeftGUI';
    RespK = 'RightGUI';
    RespP = 'RightAlt';
    RespT = 'LeftArrow';
end


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

load (FileToLoad);


NbTrials = length(Trials{1,1})

if Verbosity==1
	NbTrials = 50;
end

fprintf('\nThis run should last %.0f min.\n\n', ceil( 2.4 * NbTrials / 60) );



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


DrawFormattedText(win, 'Press the key for the /B/ responses.', 'center', 'center', 255);
Screen('Flip', win);
[secs, keyCode, deltaSecs] = KbWait(ResponseBox);
while strcmp(KbName(keyCode),RespB)==0
    [secs, keyCode, deltaSecs] = KbWait(ResponseBox);
    KbName(keyCode)
    RespB
    WaitSecs(0.5);
end


DrawFormattedText(win, 'Press the key for the /D/ responses.', 'center', 'center', 255);
Screen('Flip', win);
while strcmp(KbName(keyCode),RespD)==0
    [secs, keyCode, deltaSecs] = KbWait(ResponseBox);
    KbName(keyCode)
    RespD
    WaitSecs(0.5);
end


DrawFormattedText(win, 'Press the key for the /G/ responses.', 'center', 'center', 255);
Screen('Flip', win);
while strcmp(KbName(keyCode),RespG)==0
    [secs, keyCode, deltaSecs] = KbWait(ResponseBox);
    KbName(keyCode)
    RespG
    WaitSecs(0.5);
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

% draw fixation at beginning of experiment
DrawFormattedText(win, '.', 'center' , 'center' , 255);
Screen('Flip', win);

WaitSecs(0.5);

tic

% --------------------------%
%       TRIALS LOOPS        %
% --------------------------%

% NbTrials=24;

ListenChar(2);

for j=1:NbTrials
    
    
    if mod(j,12)==1 && j~=1
        WaitSecs(IBI);
    end
	
	% Check for experiment abortion from operator
    [keyIsDown,secs,keyCode] = KbCheck(MacKeyboard);
	if (keyIsDown==1 && keyCode(Esc))
		break;
	end;
		
    % Reinitialises the pressed variables
	pressed = 0 ;
	
    % Gets the stimuli name from the Trial cell given by the TrialsRandom function
	MovieName = [deblank(Trials{4,1}(j,:))];
	SoundName = [deblank(Trials{5,1}(j,:))];
	


	% --------------------------%
	%          SOUND            %
	% --------------------------%
	% Read the wav file and adds some noise
	[Y,FS,NBITS] = wavread(SoundName);
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
        
	% START SOUND : no start time is specified hoping that movie and sound are going to start sufficiently in synch.
	PsychPortAudio('Start', SoundHandle, 1, []);	

   	 % START MOVIE : Actually show the first frame of the movie...
	T_VisualOnset = Screen('Flip', win, []); % ... by flipping the screen
	
	[tex, pts] = Screen('GetMovieImage', win, movie); % Gets the second movie frame and turns into a PTB texture
    
	% Playback loop to play the rest of the movie, that is as long as the
	% texture from GetMovieImage is not <= to 0
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
    
    
    
    % Close the movie but before we note the number of frame dropped during
    % the whole presentation of the movie
    Screen('PlayMovie', movie, 0);
    Screen('CloseMovie', movie);

    % Stop sound, collect onset timestamp of sound
    T_AudioOnset = PsychPortAudio('Stop', SoundHandle, 1) ; 
	
    
    
    
    
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
       

    % APPENDS RESULTS to the Trials{1,1} matrix
    Trials{1,1}(j,6:7) = [RT Resp];       



    % Saves regularly
    if mod(j,NbTrials/10)==0
            save(SavedMat);
    end
    
    clear Z

    
    
    if j==1
       StartXP=T_VisualOnset;
    end
    
    CollectVisualOnset(j)=T_VisualOnset-StartXP;
    
    
end

toc


% We are done we the experiment proper.
% Close everything
KbQueueRelease(ResponseBox);
PsychPortAudio('Close');
ShowCursor;
sca;
clear Screen;
ListenChar

catch
save(SavedMat);
KbQueueRelease(ResponseBox);
PsychPortAudio('Close');
ShowCursor;
sca;
clear Screen;
ListenChar
psychrethrow(psychlasterror);
end


clear winrect win width tex srcRect secs pts ptb_RootPath ptb_ConfigPath pressed oldtimeindex movie 
clear keyIsDown keyCode j ifi height h fps firstPress dstRect deltaSecs Z Win_W Win_H Verbosity 
clear T_VisualOnset T_AudioOnset SoundName SoundLength SoundHandle SoundBegin ScreenID Scale 
clear SamplingFreq ResponseTargetKeys ResponseBox Resp RT NBITS MovieOrigin MovieOrders MovieName 
clear MovieLength LatBias MacKeyboard KeysOfInterest HorizonOffset Framerate FileToLoad FS Elevate
clear Confirm movieduration MovieDim2Extract FrameRate

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

