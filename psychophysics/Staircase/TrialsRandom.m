function [Trials] = TrialsRandom (NoiseRange, NbTrialsPerCondition, McDir, MovieType, SoundType, Verbosity);

% Randomise the trials for the "McGurk" experiment with blocks of stimuli
%
%
% Returns a {4,1} cell
% {1,1} contains the trial number and the type of stimuli presented on this trial
% Trials(i,1) = [i NoiseLevel];
% i		 is the trial number

% {2,1} contains the name of the stim used
% {3,1} contains the absolute path of the corresponding movie to be played
% {4,1} contains the absolute path of the corresponding sound to be played


% TO DO LIST :
%   - what if they are no movie




if (nargin < 1) || isempty(NoiseRange)==1
    NoiseRange = linspace (0,1,10);
end;

if (nargin < 2) || isempty(NbTrialsPerCondition)==1 % 0 to hide some errors and some check-up
	NbTrialsPerCondition = 8;
end;

if (nargin < 3) || isempty(McDir)==1
    McDir = 'McGurkMovies';
end;

if (nargin < 4) || isempty(MovieType)==1
    MovieType = '.mov';
end;

if (nargin < 5) || isempty(SoundType)==1
    SoundType = '.wav';
end;

if (nargin < 6) || isempty(Verbosity)==1 % 0 to hide some errors and some check-up
    Verbosity = 0; 
end;

	      
% -----------------------------------------------

% Initialise some variables or mat or cells
Trials = cell(4,1);
Trials{1,1}=[];

% -----------------------------------------------


% Stimuli directories
McMoviesDir = strcat(pwd, filesep, McDir, filesep);

fprintf('\nLooking for movies in the directories:\n %s\n\n', McMoviesDir);

% List the McGurk movies and their absolute pathnames with the same method as above
McMoviesDirList = dir(strcat(McMoviesDir, '*', MovieType));
if (isempty(McMoviesDirList))
    error('There are no McGurk movie.');
end;
NbMcMovies = size(McMoviesDirList, 1);
MovieVector = 1:NbMcMovies;

McSoundDirList = dir(strcat(McMoviesDir, '*', SoundType));
NbMcSound =  size(McSoundDirList, 1);
if (NbMcSound~=NbMcMovies) % Check if there are actually as many movies as sounds !
    error('Different numbers of sound and movies in the McGurk folder.');
end;


fprintf('\nSome movies found.\n\nRandomizing Trials.\n');

% Cartesian product... Solution found online. Seems also possible to use the ALLCOMB function if it has been downloaded from mathworks exchange.
sets = {MovieVector, 1:length(NoiseRange)};
[x y] = ndgrid(sets{:});
% List of all possible combinations and repeats the matrix by the amount of times per condition.
Conditions = [x(:) y(:)];


% Repeats the condition matrix as many times as necessary
A = repmat(Conditions, NbTrialsPerCondition, 1);


% Generate a randomly ordered vector for the trial orders.
TrialsIndices = randperm (length(A));


% ----- Randomise trials -----

for i = 1:length(A) ;
		
	Stim = McMoviesDirList(A(TrialsIndices(i),1)).name;
	
	Mov = [McMoviesDir Stim];

	Sound = strcat(Mov(1:end-4), SoundType); % Notes the name of the sound file corresponding to the movie
	
       
	Trials{1,1} = [Trials{1,1} ; i A(TrialsIndices(i),2)]; % Notes the trial number and the Noiselevel used for this trial
	
	if (i==1) % Otherwise the first line of the Trials{2,1} and {3,1} matrixes will be empty rows
	    	Trials{2,1} = char(Stim(1:end-4)); % Thus creates a first row to the stim matrix
        	Trials{3,1} = char(Mov); % Idem but for the movie stim absolute matrix
        	Trials{4,1} = char(Sound); % Idem but for the sound stim absolute matrix
    	else
            	Trials{2,1} = char(Trials{2,1},Stim(1:end-4)); % Appends the stimulus name to the stim matrix
            	Trials{3,1} = char(Trials{3,1},Mov); % Appends the stimulus absolute path to the movie stim absolute matrix
            	Trials{4,1} = char(Trials{4,1},Sound); % Appends the stimulus absolute path to the sound stim absolute matrix
    	end;
	
end;

fprintf('\nRandomization Done.\n\n');


fprintf('\nThis run should last between %.0f and %.0f min.\n\n', floor(2*length(A)/60), ceil(5*(length(A))/60) );

fprintf('Do you want to continue?\n')
Confirm=input('Type ok to continue. ', 's');
if ~strcmp(Confirm,'ok') % Abort experiment if too long
	fprintf('Experiment aborted.\n')
        return
end



