function TrialsRandom (SubjID, NoiseRange, BlockRepet, BlockLenght, ConDir, InconDir, McDir, MovieType, SoundType, Verbosity);

% Randomise the trials for the "McGurk" experiment with blocks of stimuli
%
%
% Returns a {5,1,rMAX} cell where rMAX is the total number of run
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


% TO DO LIST :



% -------------------------------- %
%	VERIFY INPUT ARGUMENTS     %
% -------------------------------- %

if (nargin < 1) || isempty(SubjID)==1
    SubjID = char('RG');
end;

if (nargin < 2) || isempty(NoiseRange)==1
    NoiseRange = [0 0.1 0.2 0.3 0.4 0.5];
end;

if (nargin < 3) || isempty(BlockRepet)==1
    BlockRepet = 16; % Must be equal to NbMcMovie^2 !
end;

if (nargin < 4) || isempty(BlockLenght)==1 % Matrix to describe the possible length of the blocks according to condition. Same for all conditions to ensure a balanced design.
    BlockLenght= [1:4; ... % This row is for congruent blocks
    		  1:4; ... % This row is for incongruent blocks
    		  1:4];    % This row is for McGurk blocks
end;

if (nargin < 5) || isempty(ConDir)==1
    ConDir = 'CongMovies';
end;

if (nargin < 6) || isempty(InconDir)==1
    InconDir = 'IncongMovies';
end;

if (nargin < 7) || isempty(McDir)==1
    McDir = 'McGurkMovies';
end;

if (nargin < 8) || isempty(MovieType)==1
    MovieType = '.mov';
end;

if (nargin < 9) || isempty(SoundType)==1
    SoundType = '.wav';
end;

if (nargin < 10) || isempty(Verbosity)==1 % 0 to hide some errors and some check-up
    Verbosity = 0; 
end;

% --------------------------%
%      Global Variables     %
% --------------------------%

rMAX = 6; % Maximum number of run

SavedRunMat = strcat('Subject_', SubjID, '_Run_Matrices.mat');

% Before overwriting files
if exist(SavedRunMat,'file')
    fprintf('The files\n')
    disp(SavedRunMat)
    fprintf('already exists. Do you want to overwrite?\n')
    Confirm=input('Type ok for overwrite. ', 's');
    if ~strcmp(Confirm,'ok') % Abort experiment if overwriting was not confirmed
	return
    end
end

% -------------------------------- %
%	CREATE BLOCK SEQUENCE      %
% -------------------------------- %

BlockOrderOK=0;

% Create a cell that will list the different block length for the different conditons
BLOCKS = cell(3,1);

% Fills the different matrices of the cell for the different conditions (first column for condition and second for block length)
for i=1:3
	BLOCKS{i,1} = repmat( [i-1*ones(length(BlockLenght(i,:)),1) BlockLenght(i,:)'], BlockRepet, 1);
end

while ~BlockOrderOK

	% Creates randomised indices vector for the different conditions
	BlockOrderIndices = [ [randperm(length(BLOCKS{1,1}))]' [randperm(length(BLOCKS{2,1}))]' [randperm(length(BLOCKS{3,1}))]' ];
	% Creates indices counters for the different conditions
	BlockIndex=ones(1,3);

	% p is a variable that assigns a condition on the i^th block
	p = round(1+rand);


	for i=1:sum( length(BLOCKS{1,1})+length(BLOCKS{2,1})+length(BLOCKS{3,1}) )

		BlockOrder(i,:) = BLOCKS{p,1}( BlockOrderIndices(BlockIndex(p),p) , :); % Appends a new block (condition and lenght) to the block order matrix

		BlockIndex(p)=BlockIndex(p)+1; % Increments relevant counter

		switch p % Chooses a new condition for the next block
			case 1
					p = round(2+rand);
			case 2
					p = 1 + 2*round(rand);
			case 3
					p = round(1+rand);
		end


		while BlockIndex(p)>length(BLOCKS{p,1}) % In case we have exhausted all the possible blocks for one condition...

			if BlockIndex == [length(BLOCKS{1,1})+1 length(BLOCKS{2,1})+1 length(BLOCKS{3,1})+1] % ...but not if we have exhausted all the possible blocks for ALL conditions
				break
			end

			switch p % Chooses a new condition for the next block
				case 1
						p = round(2+rand);
				case 2
						p = 1 + 2*round(rand);
				case 3
						p = round(1+rand);
			end
		end

	end
	
	BlockOrder(end-40:end,:)
	
	fprintf('\nSatisfied with the block order ?\n\n' )
	BlockOrderOK = input('\nOK: type 1 ; NO : type 0 ');

end

	



% -------------------------------- %
%           LIST MOVIES            %
% -------------------------------- %

MovieOrder = cell(3,1);

% Stimuli directories
CongMoviesDir = strcat(pwd, filesep, ConDir, filesep);
IncongMoviesDir = strcat(pwd, filesep, InconDir, filesep);
McMoviesDir = strcat(pwd, filesep, McDir, filesep);


fprintf('\nLooking for movies in the directories:\n %s\n %s\n %s\n', CongMoviesDir, IncongMoviesDir, McMoviesDir);

% -------------------------------------------------------------------------

% List the CONGRUENT movies and their absolute pathnames
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

% Cartesian product... Solution found online. Seems also possible to use the ALLCOMB function if it has been downloaded from mathworks exchange.
sets = {1:NbCongMovies, 1:length(NoiseRange)};
[x y] = ndgrid(sets{:});
% List of all possible combinations and repeats the matrix by the amount of times per condition.
MovieOrder{1,1} = repmat([x(:) y(:)], sum(BlockLenght(1,:)), 1 );

% -------------------------------------------------------------------------

% List the INCONGRUENT movies and their absolute pathnames with the same method as above
IncongMoviesDirList = dir(strcat(IncongMoviesDir,'*', MovieType));
if (isempty(IncongMoviesDirList))
    error('There are no incongruent movie.');
end;
NbIncongMovies = size(IncongMoviesDirList,1);

IncongSoundDirList = dir(strcat(IncongMoviesDir,'*', SoundType));
NbIncongSound =  size(IncongSoundDirList,1);
if (NbIncongSound~=NbIncongMovies)
    error('Different numbers of sound and movies in the incongruent folder.');
end;

sets = {1:NbIncongMovies, 1:length(NoiseRange)};
[x y] = ndgrid(sets{:});
MovieOrder{2,1} = repmat([x(:) y(:)], sum(BlockLenght(2,:)), 1 );

% -------------------------------------------------------------------------

% List the McGURK movies and their absolute pathnames with the same method as above
McMoviesDirList = dir(strcat(McMoviesDir,'*', MovieType));
if (isempty(McMoviesDirList))
    error('There are no McGurk movie.');
end;
NbMcMovies = size(McMoviesDirList,1);

McSoundDirList = dir(strcat(McMoviesDir,'*', SoundType));
NbMcSound =  size(McSoundDirList,1);
if (NbMcSound~=NbMcMovies)
    error('Different numbers of sound and movies in the incongruent folder.');
end;

MovieOrder{3,1} = repmat([1:NbMcMovies]', NbMcMovies*sum(BlockLenght(3,:)), 1);

% -------------------------------------------------------------------------


% Creates randomised indices vector for the different conditions
MovieOrderIndices = [ [randperm(length(MovieOrder{1,1}(:,1)))]' [randperm(length(MovieOrder{2,1}(:,1)))]' [randperm(length(MovieOrder{3,1}(:,1)))]' ];
% Creates indices counters for the different conditions
MovieIndex=ones(1,3);


fprintf('\nSome movies found.\n\nRandomizing Trials.\n');



% -------------------------------- %
%  CREATING ACTUAL TRIAL SEQUENCE  %
% -------------------------------- %

r = 1; % Run counter

% Delimits the lenght in number of blocks per run
RunLength = [ [1+(0:rMAX-1) * ceil(length(BlockOrder)/rMAX)]' [(1:rMAX) * ceil(length(BlockOrder)/rMAX)]' ];
RunLength(rMAX,2)=length(BlockOrder)


% Initialise some variables or mat or cells
Trials = cell(5,1,rMAX);


for r=1:rMAX
	
	j=1; % Trial Counter
	n = 666; % n is the variable that says what kind of block came before the present one.
	m = 666; % m is the variable that says the length of the block that came before the present one.

	for i = RunLength(r,1):RunLength(r,2) ;

		Choice = BlockOrder(i,1); % Tells what block we are in
		MAX = BlockOrder(i,2); % Decides how long this block will be

		for p=1:MAX

			switch Choice % Choice is a variable that defines the type of block we are in for this iteration of the loop : 0-->Congruent, 1-->Incongruent, 2-->McGurk.

				case 0 % For congruent blocks
					Stim = CongMoviesDirList( MovieOrder{1,1}( MovieOrderIndices(MovieIndex(1,1),1) ) ).name; % Chooses a movie
					Mov = [CongMoviesDir Stim]; % Notes its absolute path

				case 1 % For incongruent blocks
					Stim = IncongMoviesDirList( MovieOrder{2,1}( MovieOrderIndices(MovieIndex(1,2),1) ) ).name;
					Mov = [IncongMoviesDir Stim];

				case 2 % For McGurk blocks
					Stim = McMoviesDirList( MovieOrder{3,1}( MovieOrderIndices(MovieIndex(1,3),1) ) ).name;
					Mov = [McMoviesDir Stim];

			end;


			Sound = strcat(Mov(1:end-4), SoundType); % Notes the name of the sound file corresponding to the movie

			Trials{1,1,r}(j,:) = [j p Choice n m]; % Appends the trial number and the trial type to a matrix and the kind and length of the previous trials.

			Trials{3,1,r}(j,:) = NoiseRange( MovieOrder{Choice+1,1}( MovieOrderIndices(MovieIndex(1,Choice+1),1) ) );

			if (j==1) % Otherwise the first line of the Trials{2,1} and {3,1} matrixes will be empty rows
				Trials{2,1,r} = char(Stim(1:end-4)); % Thus creates a first row to the stim matrix
				Trials{4,1,r} = char(Mov); % Idem but for the movie stim absolute matrix
				Trials{5,1,r} = char(Sound); % Idem but for the sound stim absolute matrix
			else
				Trials{2,1,r} = char(Trials{2,1,r}, Stim(1:end-4)); % Appends the stimulus name to the stim matrix
				Trials{4,1,r} = char(Trials{4,1,r}, Mov); % Appends the stimulus absolute path to the movie stim absolute matrix
				Trials{5,1,r} = char(Trials{5,1,r}, Sound); % Appends the stimulus absolute path to the sound stim absolute matrix
			end;

			j=j+1;

			MovieIndex(1,Choice+1) = MovieIndex(1,Choice+1)+1;

		end

		n = Choice; % Notes down which block we were into before changing

		m = MAX; % Notes down how long was the block we were into before changing


	end
	
end

fprintf('\nRandomization Done.\n\n');




% Saving the run matrix
if (IsOctave==0)
    save (SavedRunMat, 'Trials', 'BlockLenght', 'SubjID', 'rMAX', 'BlockOrder', 'RunLength', 'CongMoviesDirList', 'IncongMoviesDirList', 'McMoviesDirList');
else
    save ('-mat7-binary', SavedRunMat, 'Trials', 'BlockLenght', 'SubjID', 'rMAX', 'BlockOrder', 'RunLength', 'CongMoviesDirList', 'IncongMoviesDirList', 'McMoviesDirList');
end;

% --------------------------%
%  Plot the order of trials %
% --------------------------%

if (Verbosity==1) % To plot the order of trials
	
	A=cell(5,1);
	
	for i=1:rMAX
		for j=1:5
			A{j,1}=[A{j,1}(:,:) ; Trials{j,1}(:,:)]
		end
	end

	A{1,1}
	A{2,1}
	A{3,1}
	A{4,1}
	A{5,1}

	NbTrials=length(A{1,1})

	% Plot the change of type of trials
	subplot(111);
	plot(TriAals{1,1}(:,1), A{1,1}(:,3), 'r');

	t=title('Trial type');
	set(t,'fontsize',15);

	set(gca,'fontsize',15);
	axis('tight');
	set(gca,'xTick' , floor(1:(NbTrials/10):NbTrials) , 'xTickLabel', floor(1:(NbTrials/10):NbTrials ));
	set(gca,'yTick' , 0:2 , 'yTickLabel' , 'Congruent|Incongruent|McGurk' );


end;
