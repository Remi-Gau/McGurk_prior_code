function McGurkAudioStaircase (Verbosity);

%

% TO DO LISTS :
%	- analyse responses to stim : simplify
%	- do back up regularly in case of crash and make a fixcrash
%	- randomise trials like for the visual version



% Make sure the script is running on Psychtoolbox-3
AssertOpenGL;

% Switch KbName into unified mode: It will use the names of the OS-X platform on all platforms in order to make this script portable:
KbName('UnifyKeyNames');

clc;
close all;
sca;
PsychPortAudio('Close');

clear Screen;

% PsychDebugWindowConfiguration;
% Screen('Preference', 'SkipSyncTests', 1)

% --------------------------%
%     Subject's    info     %
% --------------------------%

SubjID = input('Subject''s ID? ','s')
Run = input('Experiment run number? ')

% set default values for input arguments
if (~exist('SubjID'))
    SubjID = char('RG');
end

if (~exist('Run'))
    Run = 666;
end

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

if (nargin < 1) % 0 to hide some errors, check-up, data, figures...
	Verbosity = 0; 
end;

Scale = 2; % Movie scale relative to original one

NbTrialsPerCondition = 5 ;

% Stimuli file types
MovieType = '.mov';
SoundType = '.wav';

McDir = 'McGurkMovies';

% Sound
SamplingFreq = 44100;
NbChannels = 2;
NoiseSoundRange = linspace (0,0.8,10); % Adds some whitenoise to the sound track : 0 -> no noise; 1 -> noise level equivqlent to the max intensity present in the orginal soundtrack
LatBias = 0;


% --------------------------%
%         Keyboard          %
% --------------------------%

[a,b] = GetKeyboardIndices
deviceIndex = input('Choose keyboard ')

% deviceIndex = [];

esc = KbName('ESCAPE');

ResponseTimeWindow = 1;


% -------------------------------------------------------------------------


[Trials] = TrialsRandom (NoiseSoundRange, NbTrialsPerCondition, McDir, MovieType, SoundType, Verbosity);
% Returns a {4,1} cell
% {1,1} contains the trial number and the type of stimuli presented on this trial
% Trials(i,1) = [i NoiseLevelIndex];
% i		 is the trial number

% {2,1} contains the name of the stim used
% {3,1} contains the absolute path of the corresponding movie to be played
% {4,1} contains the absolute path of the corresponding sound to be played


NbTrials=length(Trials{1,1}(:,1));


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

% Let the subjects choose his response keys
DrawFormattedText(win, 'Press a key for the /B/ responses.', 'center', 'center', 255);
Screen('Flip', win);
KbWait;
[ keyIsDown, t, keyCode ] = KbCheck;
RespB = KbName(keyCode);
WaitSecs(0.5);


DrawFormattedText(win, 'Press a key for the /D/ responses.', 'center', 'center', 255);
Screen('Flip', win);
KbWait;
[ keyIsDown, t, keyCode ] = KbCheck;
RespD = KbName(keyCode);
WaitSecs(0.5);


DrawFormattedText(win, 'Press a key for the /P/ responses.', 'center', 'center', 255);
Screen('Flip', win);
KbWait;
[ keyIsDown, t, keyCode ] = KbCheck;
RespP = KbName(keyCode);
WaitSecs(0.5);


DrawFormattedText(win, 'Press a key for the /T/ responses.', 'center', 'center', 255);
Screen('Flip', win);
KbWait;
[ keyIsDown, t, keyCode ] = KbCheck;
RespT = KbName(keyCode);
WaitSecs(0.5);


DrawFormattedText(win, 'Press a key for OTHER responses.', 'center', 'center', 255);
Screen('Flip', win);
KbWait;
[ keyIsDown, t, keyCode ] = KbCheck;
RespOTHER = KbName(keyCode);
WaitSecs(0.5);


% Create the keyboard queue to collect responses.
KbQueueCreate(deviceIndex);
KbQueueStart(deviceIndex);

Screen('Flip', win);

WaitSecs(0.5);


% --------------------------%
%       TRIALS LOOPS        %
% --------------------------%

VBL=[]; % Collects all the vbl of the trial

ListenChar(2);

for j=1:NbTrials

	% Check for experiment abortion 
    	[keyIsDown,secs,keyCode]=KbCheck;
	if (keyIsDown==1 && keyCode(esc))
		break;
	end;
		
    	% Reinitialises the pressed variables
	pressed = 0 ;
	
   	% Reinitialises the matrix that are going to the collect the
  	% theoretical and actual display time of each movie frame
	ptsS = [];
	vblS = [];
	
	
	% Gets the stimuli name from the Trial cell given by the TrialsRandom function
	MovieName = [deblank(Trials{3,1}(j,:))];
	SoundName = [deblank(Trials{4,1}(j,:))];	

    
  	% SOUND    
	% Read the wav file and adds some noise
	[Y,FS,NBITS]=wavread(SoundName);
	Z = transpose(Y);
	SoundLength = length(Z)/FS;
	clear Y;
    
    
    	NoiseSoundLevel = NoiseSoundRange(Trials{1,1}(j,2));
   	A = NoiseSoundLevel * ( 2 * max(max(Z)) * rand(1, length(Z)) - max(max(Z)) );
   	A = [A ; A];
   	Z = A + Z;
    	clear A;
    	
   	% Fill up audio buffer with the sound
	PsychPortAudio('FillBuffer', SoundHandle, Z);
	
	vbl = Screen('Flip', win);
	VBL = [VBL; vbl];



   	% MOVIE
	% Open the movie file
    	% The special flags = 2 is play a soundless movie, but that is what we want as PsychPortAudio takes care of playing the sound.
    	% As the movies are around 2 secs long, the preload is set to 3 to load the whole movie in the RAM.
	[movie movieduration fps width height] = Screen('OpenMovie', win, MovieName,[], 3, 2); 
	
	% Calculate display rectangle
	srcRect = [0 0 width height];
	dstRect = [((Win_W - Scale*width)/2) ((Win_H - Scale*height)/2) ((Win_W + Scale*width)/2) ((Win_H + Scale*height)/2)];
    
	% Start playback engine
	Screen('PlayMovie', movie, 1, [], 0);
	
	% Wait for next movie frame, retrieve texture handle to it
	[tex, pts] = Screen('GetMovieImage', win, movie); % Gets the first movie frame and turns into a PTB texture
	ptsS = [pts]; % Collects the theoretical time of display of this movie frame in a matrix
	
	Screen('DrawTexture', win, tex, srcRect, dstRect); % Draw the texture to the screen
	Screen('Close', tex); % Let go of the texture 
	Screen('DrawingFinished', win);
	
        
        
	% START SOUND : no start time is specified hoping that movie and sound are going to start sufficiently in synch.
	PsychPortAudio('Start', SoundHandle, 1, []);	
    
  
    
   	% START MOVIE : Actually show the first frame of the movie...
	T_VisualOnset = Screen('Flip', win, []); % ... by flipping the screen
	
	[tex, pts] = Screen('GetMovieImage', win, movie); % Gets the second movie frame and turns into a PTB texture
	
	vbl = T_VisualOnset; % Note the time when the movie started. Used this to calculate RT
	
	ptsS = [ptsS; pts]; % Collects the theoretical time of display of this movie frame in a matrix
	vblS = [vblS ; vbl]; % Collects the actual time of display of this movie frame in a matrix
	VBL = [VBL; vbl];
    
	% Playback loop to play the rest of the movie, that is as long as the texture from GetMovieImage is not <= to 0
	while tex > 0
			
		Screen('DrawTexture', win, tex, srcRect, dstRect); % Draw the texture to the screen
		Screen('Close', tex); % Let go of the texture
		Screen('DrawingFinished', win);
		vbl = Screen('Flip', win); % Actually show the image to the subject
        
		[tex, pts] = Screen('GetMovieImage', win, movie); % Gets the next movie frame and turns into a PTB texture
		
        ptsS = [ptsS; pts]; % Collects the theoretical time of display of the next movie frame
        vblS = [vblS; vbl]; % Collects the actual time of display of this movie frame
        VBL = [VBL; vbl];
			
	end;

	vbl = Screen('Flip', win);
	VBL = [VBL; vbl];
	

	% --------------------------%
	%        RESPONSE           %
	% --------------------------%
	% If the subject has not pressed a key during the movie, we wait until he/she does so.
	LoopStart = GetSecs;

	while (pressed==0)
		[pressed, firstPress]=KbQueueCheck(deviceIndex);

		TimeNow = GetSecs;
		if TimeNow > LoopStart + ResponseTimeWindow;
			break;
		end	
	end;

	% extract keypress time if there is one
	if pressed==1
		for i=1:length(firstPress)
			if firstPress(i)==0
				firstPress(i)=Inf;
			end
		end
		
		[X Y] = min(firstPress) ;
		RespTime = X ;
		Resp = Y ;
		
	else
		RespTime = TimeNow ;
		Resp = 999 ;
	end
   
    
   	% Close the movie but before we note the number of frame dropped during
   	% the whole presentation of the movie
   	DroppedFrames = Screen('PlayMovie', movie, 0);
   	Screen('CloseMovie', movie);
         
   	% Stop sound, collect onset timestamp of sound
   	T_AudioOnset = PsychPortAudio('Stop', SoundHandle, 1);

	% Does some maths !
	RT = RespTime - T_VisualOnset;   		
	
	% Offset between the beginning of the sound and when the first movie frame was shown : hopefully close to zero...
	AV_Offset = T_AudioOnset - T_VisualOnset;
	
  	% Calculates the mean difference between the actual and theorical  movie frame display time
	MovieLag = abs(mean(diff(ptsS(1:end-1)) - diff(vblS(1:end))));
	if (MovieLag>0.05 && Verbosity==1)
   		fprintf('Actual movie framerate of the %f th movie was offset from presented framerate by %f sec!', i, MovieLag);
   	end;  	
    	 

	% APPENDS RESULTS to the Trials{1,1} matrix and to Trials{2,1}
	Trials{1,1}(j, 3:4) = [RT Resp];
	Trials{5,1}(j,:) = [j MovieLag DroppedFrames T_VisualOnset T_AudioOnset AV_Offset];


	% Reinitialises keyboard queue
	KbQueueFlush(deviceIndex);
  
    
    if mod(j,NbTrials/10)==0
        if (IsOctave==0)
            save (SavedMat, 'Trials', 'NbTrials', 'SubjID', 'Run', 'VBL', 'RespB', 'RespD', 'RespP', 'RespT', 'RespOTHER', 'NoiseSoundRange'); 
        else
            save ('-mat7-binary', SavedMat, 'Trials', 'NbTrials', 'SubjID', 'Run', 'VBL', 'RespB', 'RespD', 'RespP', 'RespT', 'RespOTHER', 'NoiseSoundRange');
        end;
    end;
    
end;



% We are done we the experiment proper.
% Close everything
KbQueueRelease(deviceIndex);
PsychPortAudio('Close');
ShowCursor;
sca;
clear Screen;
ListenChar

catch
KbQueueRelease(deviceIndex);
PsychPortAudio('Close');
ShowCursor;
sca;
clear Screen;
ListenChar
psychrethrow(psychlasterror);
end;

% Saving the data
if (IsOctave==0)
    save (SavedMat, 'Trials', 'NbTrials', 'SubjID', 'Run', 'VBL', 'RespB', 'RespD', 'RespP', 'RespT', 'RespOTHER', 'NoiseSoundRange');
else
    save ('-mat7-binary', SavedMat, 'Trials', 'NbTrials', 'SubjID', 'Run', 'VBL', 'RespB', 'RespD', 'RespP', 'RespT', 'RespOTHER', 'NoiseSoundRange');
end;

% --------------------------%
%     Sorting   Answers     %
% --------------------------%
for i=1:NbTrials
	switch Trials{2,1}(i,8)

		case 'B'
			switch KbName( Trials{1,1}(i,4) ) % Check responses given
				case RespB
				Trials{1,1}(i,5) = 2;
			
				case RespD
				Trials{1,1}(i,5) = 3;
				
				otherwise
				Trials{1,1}(i,5) = 4;
			end

		case 'P'
			switch KbName( Trials{1,1}(i,4) ) % Check responses given
				case RespP
				Trials{1,1}(i,5) = 2;
			
				case RespT
				Trials{1,1}(i,5) = 3;
				
				otherwise
				Trials{1,1}(i,5) = 4;
			end
		end
end;


% --------------------------%
%       SAVING DATA         %
% --------------------------%

% Saving the data
if (IsOctave==0)
    save (SavedMat, 'Trials', 'NbTrials', 'SubjID', 'Run', 'VBL', 'RespB', 'RespD', 'RespP', 'RespT', 'RespOTHER', 'NoiseSoundRange');
else
    save ('-mat7-binary', SavedMat, 'Trials', 'NbTrials', 'SubjID', 'Run', 'VBL', 'RespB', 'RespD', 'RespP', 'RespT', 'RespOTHER', 'NoiseSoundRange');
end;



% --------------------------%
%     CREATING FIGURES      %
% --------------------------%

F = 1;

% For Movie Lag
Lags = figure(F);
F = F+1;
plot(Trials{5,1}(:,1), Trials{5,1}(:,2), 'b', 'LineWidth', 3);
t = title('Movie lag.');
set(t,'fontsize',15);


% For dropped frames
DropFra = figure(F);
F = F+1;
plot(Trials{5,1}(:,1), Trials{5,1}(:,3), 'b', 'LineWidth', 3);
t = title('Numnber of dropped frames per movie.');
set(t,'fontsize',15);


% For Audiovisual offset
AVOff = figure(F);
F = F+1;
plot(Trials{5,1}(:,1), Trials{5,1}(:,6), 'b', 'LineWidth', 3);
t = title('AudioVisual Offset');
set(t,'fontsize',15);

for i=1:F-1
	figure(i)
	set(gca,'xTick' , floor(1:(NbTrials/10):NbTrials) , 'xTickLabel', floor(1:(NbTrials/10):NbTrials ));
	set(gca,'fontsize',15);
	axis('tight');
end


% For vbl intervals
AVOff = figure(F);
F = F+1;
plot(diff(VBL), 'b', 'LineWidth', 3);
t = title('VBL intervals');
set(t,'fontsize',15);


% Print figures in ps format
if (IsOctave==0)

	figure(1) 
	print(gcf, 'Figures.ps', '-dpsc2');
	for i=2:F-1
		figure(i)
		print(gcf, 'Figures.ps', '-dpsc2', '-append');
	end;

	if (IsLinux==1)
	        try
		system('ps2pdf Figures.ps Figures.pdf;');
        	catch
	        fprintf('\nCould not convert ps in pdf.\n\n');
        	end;
	end;
    
else
	% Prints the results in a vector graphic file !!!
    	for i=1:F-1
    		figure(i)  	   	
    		print(gcf, strcat('Fig', num2str(i) ,'.svg'), '-dsvg');
	    	print(gcf, strcat('Fig', num2str(i) ,'.pdf'), '-dpdf');
    	end;
    	    	    
    	if (IsLinux==1)
        	try
        	delete Figures.pdf; 
        	system('pdftk Fig?.pdf cat output Figures.pdf');
        	delete Fig?.pdf
        	catch
        	fprintf('\n We are on Linux. :-) But we could not concatenate the pdfs. Maybe check if the software pdftk is installed. \n\n');
        	end;
    	end;
end;	