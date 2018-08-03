% Randomise the trials for the "McGurk" experiment with blocks of stimuli
%
%
% Returns a {5,1} cell
% {1,1} contains the trial number and the type of stimuli presented on this trial
% Trials(i,1:5) = [i p Choice n m];
% i		 is the trial number
% p		 is the trial number in the current block
% TrialOnset	 is the onset of this movie
% Blocktype	 is the type of the current block
% Choice	 contains the type of stimuli presented on this trial : 0--> Congruent, 1--> Incongruent, 2--> Counterphase.

% {2,1} contains the name of the stim used
% {3,1} contains the level of noise used for this stimuli
% {4,1} contains the absolute path of the corresponding movie to be played
% {5,1} contains the absolute path of the corresponding sound to be played

clc
clear all
close all



ConDir = 'CongMovies';
InconDir = 'IncongMovies';
McDir = 'McGurkMovies';

MovieType = '.mov';
SoundType = '.wav';


NbSession = 8;

MovieDuration = 1.5;

NbTrialsPerBlock = 12;

IBI = 17;

NbBlockdTotal = 10;

NbBlockType = 2;

McGurkPerBlock = 4;

BlockDuration = 83;



SessionDuration = (BlockDuration+IBI)*NbBlockdTotal/60;

NbTrialsPerCondition = NbBlockdTotal/2*NbSession*McGurkPerBlock;



% TEST = [ones(1,NbTrialsPerBlock) zeros(1,NbTrialsPerBlock)];
% 
% StimOnsetAll = linspace(0,BlockDuration,2*NbTrialsPerBlock+1);
% 
% StimOnsetMat=[];
% 
% for j=1:NbBlockdTotal
% 	
% 	Index = randperm(length(TEST));
% 
% 	StimOnset = [TEST(Index)] .* StimOnsetAll(1:end-1);
% 
% 	StimOnset = StimOnset(find(StimOnset));
% 	
% 	if length(StimOnset)~=NbTrialsPerBlock
% 		StimOnset = [0 StimOnset];
% 	else
% 		StimOnset = [0 StimOnset(1:end-1)];
% 	end
% 
% 	StimOnsetMat(j,:) = StimOnset;
% 
% end
% 
% save('StimOnsetMat.mat', 'StimOnsetMat')



load('StimOnsetMat.mat')

StimOnsetMat;
 
MatISI=diff(StimOnsetMat,1,2);

MinISI = min(min(MatISI));

MaxISI = max(max(MatISI));

%figure(1)
%hist(MatISI(1:end))



load('TrialOrderFinal.mat')
TrialOrder;

% [a, b] = size(TrialOrder);
% 
% PriorDistribution=zeros(1,12);
% 
% FromMc=0;
% 
% for i=1:a
% 
% 	for j=1:b
% 		From = [];
% 		
% 		if j>1
% 			From = TrialOrder(i,j-1);
% 		end
% 		
% 		if TrialOrder(i,j)==2 & From==2
% 			FromMc = FromMc + 1;
% 		end
% 		
% 		if TrialOrder(i,j)==2 & TrialOrder(i,j-1)==0
% 			
% 			GoingBack=1;	
% 			
% 			while TrialOrder(i,j-GoingBack)==From
% 				GoingBack=GoingBack+1;
% 				if GoingBack==j
% 					break
% 				end
% 			end
% 			
% 
% 
% 			PriorDistribution(GoingBack-1) = PriorDistribution(GoingBack-1)+1;
% 			
% 		end
% 	end
% end
%
% RelPriorDistribution = PriorDistribution/sum(PriorDistribution);
% 
% sum(2*ones(size(TrialOrder))==TrialOrder);
% 
% sum(TrialOrder,2);
% 
% FromMc/a;
% 
% 
% 
% (TrialOrder==2) .* [zeros(NbBlockdTotal,1) MatISI];
% 
% [A B] = find(TrialOrder);
% 
% ListISIMcGurk = [];
% 
% for i=1:length(A)
% 		ListISIMcGurk(end+1) = StimOnsetMat(A(i),B(i))-StimOnsetMat(A(i),B(i)-1);
% end
% 
% %figure(2)
% %hist(ListISIMcGurk(1:end));
% 
% mean(ListISIMcGurk);
% std(ListISIMcGurk);


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

clear NbMcSound NbIncongSound NbCongSound McSoundDirList IncongSoundDirList CongSoundDirList ConDir InconDir McDir

fprintf('\nSome movies found.\n\nRandomizing Trials.\n');



BlockOrder=[0];
for i=1:NbBlockdTotal-1
	BlockOrder(end+1) = mod(i,2);
end


[a, b] = size(TrialOrder);
TrialOrder(:,:,2) = TrialOrder (:,:,1);

StimOnsetMat(:,:,2) = StimOnsetMat(:,:,1);

for i=1:a
	for j=1:b		
		if TrialOrder(i,j,2)==0
			TrialOrder(i,j,2)=1;
		end
	end
end
TrialOrder (:,:,2);

Run = 1;

for l=1:NbSession/2
	
	for k=1:2
		
		if k==1
			BlockIndexes = [randperm(a/2)' randperm(a/2)'];
		else
			BlockIndexes = [randperm(a/2)' randperm(a/2)'] + NbBlockdTotal/2 ;
		end

		BlockIndex=[1 1];

		for i=1:NbBlockdTotal
			MovieLongOrders(i,:) = randperm(NbCongMovies);
		end
		MovieLongOrders;

		McGurkOders = pick(1:NbMcMovies,NbMcMovies,'o');
		McGurkMovieOrders = McGurkOders([randsample(length(McGurkOders),NbBlockdTotal)],:);


		MovieOrders = cell(2,3);
		MovieOrders{1,1} = MovieLongOrders;
		MovieOrders{1,2} = [];
		MovieOrders{1,3} = McGurkMovieOrders;
		MovieOrders{2,1} = [];
		MovieOrders{2,2} = MovieLongOrders;
		MovieOrders{2,3} = McGurkMovieOrders;

		Index=ones(2,3);

		Blocks=[];
		StimOnsetMatFinal=[];
		
		

		for i=1:length(BlockOrder)

			Blocks = [ Blocks ; TrialOrder( BlockIndexes( BlockIndex(BlockOrder(i)+1), BlockOrder(i)+1 ), :, BlockOrder(i)+1 ) ];
			StimOnsetMatFinal = [ StimOnsetMatFinal ; StimOnsetMat( BlockIndexes( BlockIndex(BlockOrder(i)+1), BlockOrder(i)+1 ), :, BlockOrder(i)+1 ) ];

			BlockIndex(BlockOrder(i)+1) = BlockIndex(BlockOrder(i)+1)+1;

		end

		% -------------------------------- %
		%  CREATING ACTUAL TRIAL SEQUENCE  %
		% -------------------------------- %

		% Initialise some variables or mat or cells
		Trials = cell(5,1);

		h=1; % Trial counter

		for i = 1:NbBlockdTotal

			MovieIndex=[1 1 1];

			for j=1:NbTrialsPerBlock

				Blocktype = BlockOrder(i);

				Choice = Blocks(i,j); % Tells what block we are in

				p = MovieOrders{Blocktype+1,Choice+1}( BlockIndexes(Index(Blocktype+1,Choice+1) , Blocktype+1) , MovieIndex(Choice+1) );

				TrialOnset = StimOnsetMatFinal(i,j);

				switch Choice

					case 0 % For congruent blocks
						Stim = CongMoviesDirList(p).name; % Chooses a movie
						Mov = [CongMoviesDir Stim]; % Notes its absolute path

					case 1 % For incongruent blocks
						Stim = IncongMoviesDirList(p).name;
						Mov = [IncongMoviesDir Stim];

					case 2 % For McGurk blocks
						Stim = McMoviesDirList(p).name;
						Mov = [McMoviesDir Stim];

				end


				Sound = strcat(Mov(1:end-4), SoundType); % Notes the name of the sound file corresponding to the movie

				Trials{1,1}(h,:) = [h j TrialOnset Blocktype Choice]; % Appends the trial number and the trial type to a matrix and the kind and length of the previous trials.

				Trials{3,1}(h,:) = [Choice+1 p]; % Which kind of trial and which movie is being played in the sequence : this will be used to associate the right level of white noise to play.

				if (h==1) % Otherwise the first line of the Trials{2,1} and {3,1} matrixes will be empty rows
					Trials{2,1} = char(Stim(1:end-4)); % Thus creates a first row to the stim matrix
					Trials{4,1} = char(Mov); % Idem but for the movie stim absolute matrix
					Trials{5,1} = char(Sound); % Idem but for the sound stim absolute matrix
				else
					Trials{2,1} = char(Trials{2,1}, Stim(1:end-4)); % Appends the stimulus name to the stim matrix
					Trials{4,1} = char(Trials{4,1}, Mov); % Appends the stimulus absolute path to the movie stim absolute matrix
					Trials{5,1} = char(Trials{5,1}, Sound); % Appends the stimulus absolute path to the sound stim absolute matrix
				end

				MovieIndex(Choice+1)=MovieIndex(Choice+1)+1;

				h=h+1;

			end

			Index(Blocktype+1,:)=Index(Blocktype+1,:)+1;
		end


		save (strcat('Run_', num2str(Run),'.mat'))

		Run = Run + 1;

	end

end

List = dir ('Run*.mat');
NbSession = size(List,1);

for Run=1:NbSession
	load(List(Run).name);
	clear A B i j a k b c h ans BlockIndex BlockIndexes Blocks BlockOrder McGurkOders StimOnsetMatFinal From FromMc GoingBack Index MovieOrders StimOnsetMat MatISI  TrialOrder ... 
	      ListISIMcGurk MovieIndex MovieLongOrders McGurkMovieOrders Blocktype Choice p Stim TrialOnset Mov Sound Verbosity
	save(List(Run).name);
end;


fprintf('\nRandomization Done.\n\n');
