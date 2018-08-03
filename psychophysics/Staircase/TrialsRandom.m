function [Trials] = TrialsRandom (NoiseSoundRange, StimType2Test, NbTrialsPerCondition, McDir, ConDir, InconDir, MovieType, SoundType)

% Randomise the trials for the "McGurk Audio Staircase" experiment
%
%
% Returns a {4,1} cell
% {1,1} contains the trial number and the type of stimuli presented on this trial
% Trials(i,1) = [i q NoiseLevel];
% i		 is the trial number
% q		 is the condition 0 --> CON, 1 --> INC, 2 --> McGurk

% {2,1} contains the name of the stim used
% {3,1} contains the absolute path of the corresponding movie to be played
% {4,1} contains the absolute path of the corresponding sound to be played



% -------------------------------------------------------------------------


if (nargin < 1) || isempty(NoiseSoundRange)==1
    NoiseSoundRange = linspace (0,0.8,14);
end;

if (nargin < 2) || isempty(StimType2Test)==1
    StimType2Test = 3;
end;

if (nargin < 3) || isempty(NbTrialsPerCondition)==1
	NbTrialsPerCondition = 6;
end;

if (nargin < 4) || isempty(McDir)==1
    McDir = 'McGurkMovies';
end;

if (nargin < 5) || isempty(ConDir)==1
    ConDir = 'CongMovies';
end;

if (nargin < 6) || isempty(InconDir)==1
    InconDir = 'IncongMovies';
end;

if (nargin < 7) || isempty(MovieType)==1
    MovieType = '.mov';
end;

if (nargin < 8) || isempty(SoundType)==1
    SoundType = '.wav';
end;




	      
% -------------------------------------------------------------------------

% Initialise some variables or mat or cells
Trials = cell(4,1);
Trials{1,1} = [];

% -------------------------------------------------------------------------

% Stimuli directories
MoviesDir = cell(3,1);

McMoviesDir = strcat(pwd, filesep, McDir, filesep);
MoviesDir{3,1} = McMoviesDir;
CongMoviesDir = strcat(pwd, filesep, ConDir, filesep);
MoviesDir{1,1} = CongMoviesDir;
IncongMoviesDir = strcat(pwd, filesep, InconDir, filesep);
MoviesDir{2,1} = IncongMoviesDir;

fprintf('\nLooking for movies in the directories:\n %s\n\n', McMoviesDir);

% -------------------------------------------------------------------------

A = cell(3,1);
MoviesLists = cell(3,1);

% List the McGurk movies and their absolute pathnames with the same method as above
McMoviesDirList = dir(strcat(McMoviesDir, '*', MovieType));
MoviesLists {3,1} = McMoviesDirList;
if (isempty(McMoviesDirList))
    error('There are no McGurk movie.');
end;
NbMcMovies = size(McMoviesDirList, 1);

McSoundDirList = dir(strcat(McMoviesDir, '*', SoundType));
NbMcSound =  size(McSoundDirList, 1);
if (NbMcSound~=NbMcMovies) % Check if there are actually as many movies as sounds !
    error('Different numbers of sound and movies in the McGurk folder.');
end;

% Cartesian product... Solution found online. Seems also possible to use the ALLCOMB function if it has been downloaded from mathworks exchange.
sets = {1:NbMcMovies, 1:length(NoiseSoundRange)};
[x y] = ndgrid(sets{:});
% List of all possible combinations and repeats the matrix by the amount of times per condition.
Conditions = [x(:) y(:)];

% Repeats the condition matrix as many times as necessary
A {3,1} = repmat(Conditions, NbTrialsPerCondition, 1);

% -------------------------------------------------------------------------

% List the CONGRUENT movies and their absolute pathnames
CongMoviesDirList = dir(strcat(CongMoviesDir,'*', MovieType)); % List the movie files in the congruent movie folder and returns a structure
MoviesLists {1,1} = CongMoviesDirList;
if (isempty(CongMoviesDirList)) % Check if there are actually movie !
    error('There are no congruent movie.');
end;
NbCongMovies = size(CongMoviesDirList,1);

CongSoundDirList = dir(strcat(CongMoviesDir,'*', SoundType));
NbCongSound =  size(CongSoundDirList,1);
if (NbCongSound~=NbCongMovies) % Check if there are actually as many movies as sounds !
    error('Different numbers of sound and movies in the congruent folder.');
end;

sets = {1:NbCongMovies, 1:length(NoiseSoundRange)};
[x y] = ndgrid(sets{:});
Conditions = [x(:) y(:)];

A {1,1} = repmat(Conditions, NbTrialsPerCondition, 1);

% -------------------------------------------------------------------------

% List the INCONGRUENT movies and their absolute pathnames with the same method as above
IncongMoviesDirList = dir(strcat(IncongMoviesDir,'*', MovieType));
MoviesLists {2,1} = IncongMoviesDirList;
if (isempty(IncongMoviesDirList))
    error('There are no incongruent movie.');
end;
NbIncongMovies = size(IncongMoviesDirList,1);

IncongSoundDirList = dir(strcat(IncongMoviesDir,'*', SoundType));
NbIncongSound =  size(IncongSoundDirList,1);
if (NbIncongSound~=NbIncongMovies)
    error('Different numbers of sound and movies in the incongruent folder.');
end;

sets = {1:NbIncongMovies, 1:length(NoiseSoundRange)};
[x y] = ndgrid(sets{:});
Conditions = [x(:) y(:)];

A {2,1} = repmat(Conditions, NbTrialsPerCondition, 1);

% -------------------------------------------------------------------------


% Generate a randomly ordered vector for the trial orders.
% TrialsIndices = [ randperm(length(A{1,1}))' randperm(length(A{2,1}))' randperm(length(A{3,1}))' ];
% TrialCounter = ones (1,3);




% ----- Randomise trials -----

switch StimType2Test
	case 3 
		q = 2;
        
    case 1
		q = 0; 
        
 	case 2	
		q = 1;       
end
   
TrialCounter = 1;
        
TrialsIndices = randperm(length(A{q+1,1}));

for i = 1:(length(A{q+1,1})) ;	 	

    Stim = MoviesLists{q+1,1} ( A{q+1,1} ( TrialsIndices(TrialCounter), 1 ) ).name;
    Mov = [MoviesDir{q+1,1} Stim];
    Sound = strcat(Mov(1:end-4), SoundType); % Notes the name of the sound file corresponding to the movie

    Trials{1,1} = [Trials{1,1} ; i q A{q+1,1}(TrialsIndices(TrialCounter), 2 ) ]; % Notes the trial number and the Noiselevel used for this trial

    if (i==1) % Otherwise the first line of the Trials{2,1} and {3,1} matrixes will be empty rows
        Trials{2,1} = char(Stim(1:end-4)); % Thus creates a first row to the stim matrix
        Trials{3,1} = char(Mov); % Idem but for the movie stim absolute matrix
        Trials{4,1} = char(Sound); % Idem but for the sound stim absolute matrix
    else
        Trials{2,1} = char(Trials{2,1},Stim(1:end-4)); % Appends the stimulus name to the stim matrix
        Trials{3,1} = char(Trials{3,1},Mov); % Appends the stimulus absolute path to the movie stim absolute matrix
        Trials{4,1} = char(Trials{4,1},Sound); % Appends the stimulus absolute path to the sound stim absolute matrix
    end;

    TrialCounter = TrialCounter + 1;
end


fprintf('\nRandomization Done.\n\n');


fprintf('\nThis run should last %.0f min.\n\n', ceil( 2.4 * length(Trials{1,1}(:,1)) / 60) );

fprintf('Do you want to continue?\n')
Confirm=input('Type ok to continue. ', 's');
if ~strcmp(Confirm,'ok') % Abort experiment if too long
	fprintf('Experiment aborted.\n')
        return
end

Trials{1,1}

