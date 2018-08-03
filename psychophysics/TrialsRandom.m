function [Trials AllMAX AllChoice] = TrialsRandom (NbTrials, Verbosity, BlockLenght, ConToIncong, ConDir, InconDir, McDir, MovieType, SoundType);

% Randomise the trials for the "McGurk" experiment with blocks of stimuli
%
%
% Returns a {4,1} cell
% {1,1} contains the trial number and the type of stimuli presented on this trial
% Trials(i,1:5) = [i p Choice n m];
% i		 is the trial number
% p		 is the trial number in the current block
% Choice	 contains the type of stimuli presented on this trial : 0--> Congruent, 1--> Incongruent, 2--> Counterphase.
% n 		 is the variable that says what kind of block came before the present one. Equals to 666 if there was no previous block. : 0--> Congruent, 1--> Incongruent, 2--> Counterphase.
% m 		 is the variable that says the length of the block that came before the present one. Equals to 666 if there was no previous block.

% {2,1} contains the name of the stim used
% {3,1} contains the absolute path of the corresponding movie to be played
% {4,1} contains the absolute path of the corresponding sound to be played


% TO DO LIST :
%   - what if they are no movie
%   - what if the number and movie and sounds don't match
% 



if (nargin < 1) || isempty(NbTrials) 
    NbTrials = 25;
end;

if (nargin < 2) || isempty(Verbosity) % 0 to hide some errors and some check-up
    Verbosity = 0; 
end;

if (nargin < 3) || isempty(BlockLenght) % Matrix to describe the possible length of the blocks according to condition. These length may vary from n(i,1) to n(i,2)-1.
    BlockLenght= [4 6 8; ... % This row is for congruent blocks
    		  4 6 8; ... % This row is for incongruent blocks
    		  4 5 6];    % This row is for McGurk blocks
end;

if (nargin < 4) || isempty(ConToIncong) 
    ConToIncong = 0;
end;

if (nargin < 5) || isempty(ConDir) 
    ConDir = 'CongMovies';
end;

if (nargin < 6) || isempty(InconDir) 
    InconDir = 'IncongMovies';
end;

if (nargin < 7) || isempty(McDir) 
    McDir = 'McGurkMovies';
end;

if (nargin < 8) || isempty(MovieType) 
    MovieType = '.mov';
end;

if (nargin < 9) || isempty(SoundType) 
    SoundType = '.wav';
end;






	      
% -----------------------------------------------


% Initialise some variables or mat or cells
Trials = cell(4,1);

Choice = round(rand*2); % Tells what block we are in
p = 0; % Trial counter in the current block
MAX = []; % Decides how long the first block will be.
n = 666; % n is the variable that says what kind of block came before the present one.
m = 666; % m is the variable that says the length of the block that came before the present one.

AllMAX=[];
AllChoice=[];

switch Choice % Decide how long this new block will be.
	case 0
		MAX = BlockLenght(1, ceil ( rand * (length(BlockLenght(1,:)) ) ));
	case 1
		MAX = BlockLenght(2, ceil ( rand * (length(BlockLenght(2,:)) ) ));
	case 2
		MAX = BlockLenght(3, ceil ( rand * (length(BlockLenght(3,:)) ) ));
end;

AllMAX = [AllMAX MAX];
AllChoice = [AllChoice Choice];

% -----------------------------------------------


% Stimuli directories
CongMoviesDir = strcat(pwd, filesep, ConDir, filesep);
IncongMoviesDir = strcat(pwd, filesep, InconDir, filesep);
McMoviesDir = strcat(pwd, filesep, McDir, filesep);

fprintf('\nLooking for movies in the directories:\n %s\n %s\n %s\n', CongMoviesDir, IncongMoviesDir, McMoviesDir);


% List the Congruent movies and their absolute pathnames
CongMoviesDirList = dir(strcat(CongMoviesDir,'*', MovieType)); % List the movie files in the congruent movie folder and returns a structure
if (isempty(CongMoviesDirList)) % Check if there are actually movie !
    error('There are no congruent movie.');
end;
NbCongMovies = size(CongMoviesDirList,1);

CongSoundDirList = dir(strcat(CongMoviesDir,'*', SoundType));
NbCongSound =  size(CongSoundDirList,1);
if (NbCongSound~=NbCongMovies) % Check if there are actually as many movies as sounds !
    error('Different numbers of sound and movies in the congruent folder.');
end;


% List the Incongruent movies and their absolute pathnames with the same method as above
IncongMoviesDirList = dir(strcat(IncongMoviesDir,'*', MovieType));
if (isempty(IncongMoviesDirList))
    error('There are no incongruent movie.');
end;
NbIncongMovies = size(IncongMoviesDirList,1);

IncongSoundDirList = dir(strcat(IncongMoviesDir,'*', SoundType));
NbIncongSound =  size(IncongSoundDirList,1);
if (NbIncongSound~=NbIncongMovies) % Check if there are actually as many movies as sounds !
    error('Different numbers of sound and movies in the incongruent folder.');
end;


% List the McGurk movies and their absolute pathnames with the same method as above
McMoviesDirList = dir(strcat(McMoviesDir,'*', MovieType));
if (isempty(McMoviesDirList))
    error('There are no McGurk movie.');
end;
NbMcMovies = size(McMoviesDirList,1);

McSoundDirList = dir(strcat(McMoviesDir,'*', SoundType));
NbMcSound =  size(McSoundDirList,1);
if (NbMcSound~=NbMcMovies) % Check if there are actually as many movies as sounds !
    error('Different numbers of sound and movies in the incongruent folder.');
end;


fprintf('\nSome movies found.\n\nRandomizing Trials.\n');


% ----- Randomise trials -----

for i = 1:NbTrials ;
		
	q = rand; % And that is going to help us choose one stimulus for a given type of block	
	
	p = p+1;
	
	switch Choice % Choice is a variable that defines the type of block we are in for this iteration of the loop : 0-->Congruent, 1-->Incongruent, 2-->McGurk.
		
		case 0 % For congruent blocks
			Stim = CongMoviesDirList(ceil(q*NbCongMovies)).name; % Chooses a movie
			Mov = [CongMoviesDir Stim]; % Notes its absolute path
	
		case 1 % For incongruent blocks
			Stim = IncongMoviesDirList(ceil(q*NbIncongMovies)).name;
			Mov = [IncongMoviesDir Stim];

		case 2 % For McGurk blocks
			Stim = McMoviesDirList(ceil(q*NbMcMovies)).name;
			Mov = [McMoviesDir Stim];
	end;
	
	Sound = strcat(Mov(1:end-4), SoundType); % Notes the name of the sound file corresponding to the movie

	Trials{1,1}(i,:) = [i p Choice n m]; % Appends the trial number and the trial type to a matrix and the kind and length of the previous trials.
        
	if (i==1) % Otherwise the first line of the Trials{2,1} and {3,1} matrixes will be empty rows
        	Trials{2,1} = char(Stim(1:end-4)); % Thus creates a first row to the stim matrix
        	Trials{3,1} = char(Mov); % Idem but for the movie stim absolute matrix
        	Trials{4,1} = char(Sound); % Idem but for the sound stim absolute matrix
    	else
            Trials{2,1} = char(Trials{2,1},Stim(1:end-4)); % Appends the stimulus name to the stim matrix
            Trials{3,1} = char(Trials{3,1},Mov); % Appends the stimulus absolute path to the movie stim absolute matrix
            Trials{4,1} = char(Trials{4,1},Sound); % Appends the stimulus absolute path to the sound stim absolute matrix
    	end;

	
	if (p==MAX) % After a certain number of trials per block, we change condition

	p = 0; % Reinitialize the block counter.
        
        n = Choice; % Notes down which block we were into before changing
        
        m = MAX; % Notes down how long was the block we were into before changing
		
		if (ConToIncong==0) % In case we cannot go from Con to Incon or vice versa	
			
			switch Choice
				case 0 % If we were in a congruent block, we go to a McGurk block.
				Choice = 2;	
				case 1 % If we were in a congruent block, we go to a McGurk block.
				Choice = 2;
				case 2 % Otherwise, we go from a McGurkBlock to an INC or CONG block with a 50/50 chance
				Choice = round(rand);
			end;
		
		else
			switch Choice
				case 0 % If we were in a congruent block,
				Choice = 1 + round(rand); % we go to an INC or Mc block with a 50/50 chance	
				case 1 % If we were in a incongruent block, 
				Choice = 2*round(rand); % we go to an INC or Mc block with a 50/50 chance
				case 2 % Otherwise, we go from a McGurkBlock to an INC or CONG block with a 50/50 chance
				Choice = round(rand);
			end;
		
		end;
		
		switch Choice % Decide how long this new block will be.
			case 0
			MAX = BlockLenght(1, ceil(rand * (length(BlockLenght(1,:)) ) ));
			case 1
			MAX = BlockLenght(2, ceil(rand * (length(BlockLenght(2,:)) ) ));
			case 2
			MAX = BlockLenght(3, ceil(rand * (length(BlockLenght(3,:)) ) ));
		end;
		
        	AllMAX = [AllMAX MAX];
		AllChoice = [AllChoice Choice];
        
	end;
	
end;

fprintf('\nRandomization Done.\n\n');

% --------------------------%
%  Plot the order of trials %
% --------------------------%

if (Verbosity==1) % To plot the order of trials

Trials

% Plot the change of type of trials
subplot(111);
plot(Trials{1,1}(:,1), Trials{1,1}(:,3), 'r', 'LineWidth', 3);

t=title('Trial type');
set(t,'fontsize',15);

set(gca,'fontsize',15);
axis('tight');
set(gca,'xTick' , floor(1:(NbTrials/10):NbTrials) , 'xTickLabel', floor(1:(NbTrials/10):NbTrials ));
set(gca,'yTick' , 0:2 , 'yTickLabel' , 'Congruent|Incongruent|McGurk' );


end;
