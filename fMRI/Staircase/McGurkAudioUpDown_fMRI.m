function McGurkAudioUpDown_fMRI (Verbosity);

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

	Date = clock;	

end

ExternalVolumeSoundLevel = input('External Volume Sound Level ? ');


% Data recording directories
if (exist(strcat('Subjects_Data'),'dir')==0)
	mkdir Subjects_Data;
end;
DataDir = strcat(pwd, filesep, 'Subjects_Data');

% Basename for all file names
SavedMat = strcat(DataDir, filesep, 'Subject_', SubjID, '_StaircaseUpDown_Run_', num2str(Run), '.mat');


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

MaxNbTrialsPerMovie = 60;

% Shorten Movie at the beginning by
MovieBegin = 0.04*8; % in secs
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
MaxNoise2SignalRatio = 0.6 ;

IncrementList=linspace(MaxNoise2SignalRatio/5,0.005,15)

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

[KeyboardNumbers, KeyboardNames] = GetKeyboardIndices;
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

ResponseTimeWindow = 1 ;



% -------------------------------------------------------------------------

% List the McGurk movies and their absolute pathnames with the same method
% as above
McMoviesDir = strcat(pwd, filesep, McDir, filesep);
McMoviesDirList = dir(strcat(McMoviesDir, '*', MovieType));
if (isempty(McMoviesDirList))
    error('There are no McGurk movie.');
end;
NbMcMovies = size(McMoviesDirList, 1);


% Initialise some variables or mat or cells
for i=1:NbMcMovies
    Trials(i).name = McMoviesDirList(i).name;
    Trials(i).results = [];
end


fprintf('\nThis run should last %.0f min.\n\n', ceil( (1.5+ResponseTimeWindow) * MaxNbTrialsPerMovie * NbMcMovies  / 60) );
fprintf('\nThat is about %.0f RT.\n\n', ceil( (1.5+ResponseTimeWindow) * MaxNbTrialsPerMovie * NbMcMovies / 2.56 + (1.5+ResponseTimeWindow) * MaxNbTrialsPerMovie * NbMcMovies / 2.56 * 10/100) );

% -------------------------------------------------------------------------

fprintf('Do you want to continue?\n')
Confirm=input('Type ok to continue. ', 's');
if ~strcmp(Confirm,'ok') % Abort experiment if too long
	fprintf('Experiment aborted.\n')
        return
end


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

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(['Subj ' SubjID ' / Run ' num2str(Run) ])
disp('       READY TO START        ')
disp('Confirm with space bar press.')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

while KbName(KbName(keyCode)) ~= KbName('space')
    [secs, keyCode, deltaSecs] = KbWait(MacKeyboard);
end


WaitSecs(1);


tic

% --------------------------%
%       TRIALS LOOPS        %
% --------------------------%

ContinueXP = ones(1,NbMcMovies);
TrialCounter = zeros(1,NbMcMovies);
Change = ones(1,NbMcMovies);
NoiseSoundLevel = repmat((MaxNoise2SignalRatio-0)/2,1,NbMcMovies);

ListenChar(2);

while any(ContinueXP)

	% Check for experiment abortion from operator
    [keyIsDown,secs,keyCode] = KbCheck(MacKeyboard);
	if (keyIsDown==1 && keyCode(Esc))
		break;
	end;
    
    % Choose a movie
    Choice = ceil(rand*NbMcMovies);
    while ~ContinueXP(Choice)
        Choice = ceil(rand*NbMcMovies);
    end
        
    
    TrialCounter(Choice) = TrialCounter(Choice) + 1;
		
	% Reinitialises the pressed variables
	pressed = 0 ; RT = []; Resp = [];

    
    Stim = McMoviesDirList(Choice).name;
    MovieName = [McMoviesDir Stim];
    SoundName = strcat(MovieName(1:end-4), SoundType); % Notes the name of the sound file corresponding to the movie
    
    
  	% SOUND    
	% Read the wav file and adds some noise
	[Y,FS,NBITS]=wavread(SoundName);
	Z = transpose(Y);
	SoundLength = length(Z)/FS;
	clear Y;
    
    
	
   	A = NoiseSoundLevel(Choice) * ( 2 * max(max(Z)) * rand(1, length(Z)) - max(max(Z)) );
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
		EndMovie = Screen('Flip', win); % Actually show the image to the subject
        
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
		RT = 666;
		Resp = 666 ;
    end
    
    % --------------------------%
    %     Sorting   Answers     %
    % --------------------------%
    
    switch Trials(Choice).name(8) % Compare the consonant in the original sound track
        case 'B'
            switch KbName( Resp ) % Check responses given
                case RespB
                RespCode = 1; % McGurk did not work
                
                case RespD
                RespCode = 2; % McGurk worked
                
                otherwise % Missed
                RespCode = 3;
                
            end

        case 'P'
            switch KbName( Resp ) % Check responses given
                case RespP
                RespCode = 1;
                
                case RespT
                RespCode = 2;
                
                otherwise
                RespCode = 3;
                
            end
    end
    
    
   	% Close the movie but before we note the number of frame dropped during
   	% the whole presentation of the movie
   	DroppedFrames = Screen('PlayMovie', movie, 0);
   	Screen('CloseMovie', movie);
         
   	% Stop sound, collect onset timestamp of sound
   	T_AudioOnset = PsychPortAudio('Stop', SoundHandle, 1); 		 	
    	 
	% APPENDS RESULTS to the Trials{1,1} matrix and to Trials{2,1}    
    Trials(Choice).results = [Trials(Choice).results ; sum(TrialCounter) TrialCounter(Choice) NoiseSoundLevel(Choice) RT Resp RespCode]; % Notes the trial number and the Noiselevel used for this trial
    
    % Check if there has been a change of response between this last trial
    % and the previous one, if so we have to decrease the quantity by which
    % the sound level will be incremented
    if TrialCounter(Choice)>1
        
        % make dure that the two last trials compared do not include any
        % missed answers
        TEMP = find(Trials(Choice).results(:,6)~=3); 
        TEMP = TEMP(end-1:end);
        
        if Trials(Choice).results(TEMP(1),6)~=Trials(Choice).results(TEMP(2),6)
            Change(Choice)=Change(Choice)+1;
        end
        
    end
    
    % Defines the noise sound level for the next trial of this movie
    if Change(Choice)<=length(IncrementList)
        switch RespCode
                case 1 % The McGurk effect did not work and we have to increase the noise level
                    NoiseSoundLevel(Choice) = NoiseSoundLevel(Choice)+IncrementList(Change(Choice));
                case 2 % The McGurk effect did work and we have to decrease the noise level
                    NoiseSoundLevel(Choice) = NoiseSoundLevel(Choice)-IncrementList(Change(Choice));
                case 3 % This trial was missed and we keep the same noise level
                    NoiseSoundLevel(Choice) = NoiseSoundLevel(Choice);
        end
    else % This movie will not be played anymore because, we have "hopefully" found the right level. 
        ContinueXP(Choice)=0
    end
    
    % If Noise sound level for a movie is too high or too low, this movie
    % will not be played anymore
    if NoiseSoundLevel(Choice)>MaxNoise2SignalRatio || NoiseSoundLevel(Choice)<0
        ContinueXP(Choice)=0
    end
    
    % Make sure that the trial loop does not exceed a given number of
    % trials by limiting how many times a given movie can be played
    if TrialCounter(Choice)>MaxNbTrialsPerMovie
        ContinueXP(Choice)=0
    end
    
    % Save regularly
    if mod(sum(TrialCounter),15)==0
            save (SavedMat); 
    end
    
end



% We are done we the experiment proper.
% Close everything
KbQueueRelease(ResponseBox);
PsychPortAudio('Close');
ShowCursor;
sca;
clear Screen;
ListenChar

catch
save (SavedMat); 
KbQueueRelease(ResponseBox);
PsychPortAudio('Close');
ShowCursor;
sca;
clear Screen;
ListenChar
psychrethrow(psychlasterror);
end;

toc

% Plot figures and display results
for i=1:NbMcMovies
    figure(i)
    plot(Trials(i).results(:,3))
    
    t=title(Trials(i).name);
	set(t,'fontsize',15);
    set(gca,'tickdir', 'out', 'ticklength', [0.005 0], 'fontsize',13)
	axis 'tight'
    
    Trials(i).results
end

% Print figures
cd Subjects_Data

figure(1) 
print(gcf, 'Figures_UpDown.ps', '-dpsc2'); % Print figures in ps format
for i=2:(NbMcMovies-1)
    figure(i)
    print(gcf, 'Figures_UpDown.ps', '-dpsc2', '-append'); 
end

for i=1:(NbMcMovies)
    figure(i)
    print(gcf, strcat('Fig_UpDown', num2str(i) ,'.eps'), '-depsc'); % Print figures in vector format
end

cd ..

% --------------------------%
%       SAVING DATA         %
% --------------------------%

% Saving the data
save (SavedMat)
