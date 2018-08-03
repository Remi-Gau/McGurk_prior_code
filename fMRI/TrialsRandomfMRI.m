function TrialsRandomfMRI (Verbosity)

% Randomise the trials for the "McGurk" experiment with blocks of stimuli
%
%
% Returns a {5,1} cell
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



if (nargin < 1) || isempty(Verbosity)==1 % 0 to hide some errors and some check-up
    Verbosity = 1; 
end;



ConDir = 'CongMovies';
InconDir = 'IncongMovies';
McDir = 'McGurkMovies';

MovieType = '.mov';
SoundType = '.wav';



% Number of trials per condition
NbTrialperCondition = 42

% Blocklength
BlockLength = 5;


% Number of blocktype
NbBlockType = 3;

% Number of possible previous blocktype
NbPrevBlockType = 2;

% List all possible sequences of blocks
PosBlockSeq =	[0 1; ...
		 0 2; ...
		 1 0; ...
		 1 2; ...
		 2 0; ...
		 2 1];

	 
% Number of runs
NbRuns = 6;

% Number of fixation periods
NbFix = 3;


TotalNbTrials = BlockLength * NbPrevBlockType * NbBlockType * NbTrialperCondition;
TotalNbBlocks = TotalNbTrials/BlockLength;

NbTrialsPerRun = TotalNbTrials/NbRuns;
NbBlocksPerRun = TotalNbBlocks/NbRuns;


NbBlocksBetzeenFix = NbBlocksPerRun/NbFix

% Block number for beginning of runs to avoid starting a run a
% post-fixatiob block with a McGurk block
PostFixBegin = 1:NbBlocksPerRun/NbFix:TotalNbBlocks;


SavedMat = 'BlockOrder.mat';


% That gives 1800 trials (360 blocks). 60 trial per condition.

% Each trial lasts 3 secs (90 min) + 3 long fixation blocks of 25 s of each 6 runs (3 * 6 * 25 seconds = 450 secs) + 4 volumes each lasting about 3 secs to discard at the beginning of each 6 runs (6 * 4 * 3 seconds = 72 secs).
% Total per session = 98 min.
% Each run has 60 blocks and 300 trials. So one fixation every 20 blocks/100 stimuli.

% Do we want to load a block order that already exists or create a new one 
LoadOrCompute = input('Load BlockOrder [0] or Compute it [1] ');

if LoadOrCompute

	% -------------------------------- %
	%	CREATE BLOCK SEQUENCE      %
	% -------------------------------- %

	% Create a cell that will list the different block length for the different conditons
	BLOCKS = cell(3,1);

	% Fills the different matrices of the cell for the different conditions (first column for condition and second for block length)
	for i=1:3
		BLOCKS{i,1} = repmat( [i-1], TotalNbBlocks/NbBlockType, 1);
	end

	% This variable is TRUE if the block order is considered good
	BlockOrderOK=0;

	% To count how trials the computer has to do to find the right
	% Block sequence
	ThatIsGonnaTakeLong=0;

	while ~BlockOrderOK

		% We count which attempt it is and display it every 10^4
		% attempt
		ThatIsGonnaTakeLong=ThatIsGonnaTakeLong+1;
		if mod(ThatIsGonnaTakeLong,10000)==0
			ThatIsGonnaTakeLong
		end

		% Creates randomised indices vector for the different conditions
		BlockOrderIndices = [ [randperm(length(BLOCKS{1,1}))]' [randperm(length(BLOCKS{2,1}))]' [randperm(length(BLOCKS{3,1}))]' ];
		% Creates indices counters for the different conditions
		BlockIndex=ones(1,NbBlockType);
		
		% Initialise the matrix that will hold the blocksequence
		BlockOrder=[];
		
		% Initialise the matrix that will count how many transition
		% from a given block type to another we have
		BlockTransition = zeros(NbBlockType*NbPrevBlockType,1);

		% p is a variable that assigns a condition on the i^th block
		p = round(1+rand);

		% Index counter for PostFixBegin
		PostFixBeginIndex = 1;

		for i=1:TotalNbBlocks

			BlockOrder(i,:) = BLOCKS{p,1}( BlockOrderIndices(BlockIndex(p),p) , :); % Appends a new block to the block order vector

			BlockIndex(p)=BlockIndex(p)+1; % Increments relevant counter

			switch p % Chooses a new condition for the next block
				case 1 % CON
						p = round(2+rand);
				case 2 % INC
						p = 1 + 2*round(rand);
				case 3 % McGurk
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
			
			% We assume the sequence is good.
			BlockOrderOK=1;
			
			% But if we have a succesion of two blocks of the
			% same kind we restart from scratch
			if i>1 && BlockOrder(i)==BlockOrder(i-1)
				BlockOrderOK=0;
				break
			end
			
			% Idem if the first block of a Run or after a
			% fixation is aMcGurk
			if i==PostFixBegin(PostFixBeginIndex)
				if BlockOrder(i)==2
					BlockOrderOK=0;
					break
				else %  If not we increment the index for the next beggining of run or post-fixation
					PostFixBeginIndex=PostFixBeginIndex+1;
					if PostFixBeginIndex>length(PostFixBegin)
						PostFixBeginIndex=length(PostFixBegin); % Make sure we saturate at the maximum value
					end
				end
			end
			
			% If we manage to have something a full Block
			% sequence we count which kind of transition we
			% have.
			if length(BlockOrder)==TotalNbBlocks
				BlockOrder = reshape(BlockOrder,NbBlocksPerRun/NbFix,NbRuns*NbFix); % Fraction the whole sequence in series of between fixation mini-runs

				[B,C] = size(BlockOrder);
				
				% Scan this whole matrix to count the
				% transition
				for j=1:C
					for l=2:B
						[e,r,k] = intersect(BlockOrder(l-1:l,j)',PosBlockSeq,'rows');
						BlockTransition(k) = BlockTransition(k) + 1;
					end
				end
				
				% We restart the whole thing if we do not
				% have equal numbers of CON-->McGurk and INC-->McGurk 
				% as well as CON-->INC and INC-->CON transitions
				if (BlockTransition(2)~=BlockTransition(4)) || (BlockTransition(1)~=BlockTransition(3))
					BlockOrderOK=0;
					break
				end

			end

		end	
	end
	
	if (IsOctave==0)
		save (SavedMat,  'BlockOrder', 'BlockTransition', 'PosBlockSeq');
	else
		save ('-mat7-binary', SavedMat, 'BlockOrder', 'BlockTransition', 'PosBlockSeq');
	end;
	
else
	BlockOrderList = dir('*.mat');
	BlockOrderList.name
	FiletoLoad = input('Choose file to load ', 's');
	load (FiletoLoad)	
end

BlockOrder

PosBlockSeq

BlockTransition			


% -------------------------------- %
%           LIST MOVIES            %
% -------------------------------- %


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


% -------------------------------------------------------------------------

fprintf('\nSome movies found.\n\nRandomizing Trials.\n');


% -------------------------------- %
%  CREATING ACTUAL TRIAL SEQUENCE  %
% -------------------------------- %

% Lists all the possible sequences in which the movies can be presented
MovieOrderPerm = perms(1:BlockLength);

%
% THIS HAS TO CHANGED TO IF WE THERE ARE 2 SESSIONS
% MovieOrderChoice = randsample(length(MovieOrderPerm), 2*max(BlockTransition));
%
% Subselect a few of these sequences 
MovieOrderChoice = randsample(length(MovieOrderPerm), max(BlockTransition));

MovieOrderIndex=[];

% Determines in which order these subselections of movie sequences will be
% presented for each transition (e.g from CON to McGurk...)
for i=1:(NbBlockType*NbPrevBlockType)
	MovieOrderIndex(:,i)=randperm(length(MovieOrderChoice));
end

MovieOrderChoiceIndex = ones(1,NbBlockType*NbPrevBlockType);

for Session=1:2;
	
	for Run=1:NbRuns

		SavedMat = strcat('Session_', num2str(Session),'_Run_', num2str(Run),'.mat');

		% Initialise some variables or mat or cells
		Trials = cell(5,1);

		j=1; % Trial Counter

		for k=1:NbFix

			n = 666; % n is the variable that says what kind of block came before the present one.
			m = 666; % m is the variable that says the length of the block that came before the present one.

			for i = 1:length(BlockOrder( : , k+(Run-1)*3) )

				Choice = BlockOrder(i,k+(Run-1)*3); % Tells what block we are in
			
				if n==666
					MovieOrder = randperm(BlockLength);
				else % Here we check the kind of condition transition we are doing and we select the corresponding movie sequence
					[a,b,c] = intersect([n Choice],PosBlockSeq,'rows');
					MovieOrder = MovieOrderPerm(MovieOrderChoice(MovieOrderIndex(MovieOrderChoiceIndex(c))),:);
					MovieOrderChoiceIndex(c)=MovieOrderChoiceIndex(c)+1;
				end
				
				
				for p=1:BlockLength

					switch Choice

						case 0 % For congruent blocks
							Stim = CongMoviesDirList(MovieOrder(p)).name; % Chooses a movie
							Mov = [CongMoviesDir Stim]; % Notes its absolute path

						case 1 % For incongruent blocks
							Stim = IncongMoviesDirList(MovieOrder(p)).name;
							Mov = [IncongMoviesDir Stim];

						case 2 % For McGurk blocks
							Stim = McMoviesDirList(MovieOrder(p)).name;
							Mov = [McMoviesDir Stim];

					end;


					Sound = strcat(Mov(1:end-4), SoundType); % Notes the name of the sound file corresponding to the movie

					Trials{1,1}(j,:) = [j p Choice n m]; % Appends the trial number and the trial type to a matrix and the kind and length of the previous trials.

					Trials{3,1}(j,:) = [Choice+1 MovieOrder(p)]; % Which kind of trial and which movie is being played in the seuquence : this will be used to associate the right level of white noise to play.

					if (j==1) % Otherwise the first line of the Trials{2,1} and {3,1} matrixes will be empty rows
						Trials{2,1} = char(Stim(1:end-4)); % Thus creates a first row to the stim matrix
						Trials{4,1} = char(Mov); % Idem but for the movie stim absolute matrix
						Trials{5,1} = char(Sound); % Idem but for the sound stim absolute matrix
					else
						Trials{2,1} = char(Trials{2,1}, Stim(1:end-4)); % Appends the stimulus name to the stim matrix
						Trials{4,1} = char(Trials{4,1}, Mov); % Appends the stimulus absolute path to the movie stim absolute matrix
						Trials{5,1} = char(Trials{5,1}, Sound); % Appends the stimulus absolute path to the sound stim absolute matrix
					end;

					j=j+1;

				end

				n = Choice; % Notes down which block we were into before changing
				m = BlockLength; % Notes down how long was the block we were into before changing

			end
		end
			
			
		if (IsOctave==0)
			save (SavedMat, 'Session', 'BlockLength', 'BlockOrder', 'BlockTransition', 'NbBlockType', 'Run', 'Trials', 'NbBlocksPerRun', 'NbFix', 'NbPrevBlockType', 'NbRuns', 'NbTrialperCondition', 'NbTrialsPerRun', 'TotalNbBlocks', 'TotalNbTrials');
		else
			save ('-mat7-binary', SavedMat, 'Session', 'BlockLength', 'BlockOrder', 'BlockTransition', 'NbBlockType', 'Run', 'Trials', 'NbBlocksPerRun', 'NbFix', 'NbPrevBlockType', 'NbRuns', 'NbTrialperCondition', 'NbTrialsPerRun', 'TotalNbBlocks', 'TotalNbTrials');
		end;
		
	end

	MovieOrderChoiceIndex
	
	fliplr(BlockOrder);
end



fprintf('\nRandomization Done.\n\n');
