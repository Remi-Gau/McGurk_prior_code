function AnalyseData

%

% Returns a {5,1,rMAX} cell where rMAX is the total number of run

% {1,1} contains the trial number and the type of stimuli presented on this trial
% Trials(i,1:5) = [i p Choice n m RT Resp RespCat];
% i		 is the trial number
% p		 is the trial number in the current block
% Choice	 contains the type of stimuli presented on this trial : 0--> Congruent, 1--> Incongruent, 2--> Counterphase.
% n 		 is the variable that says what kind of block came before the present one. Equals to 666 if there was no previous block. : 0--> Congruent, 1--> Incongruent, 2--> Counterphase.
% m 		 is the variable that says the length of the block that came before the present one. Equals to 666 if there was no previous block.
% RT
% Resp
% RespCat	 For Congruent trials : 1 --> Hit; 0 --> Miss // For Incongruent trials : 1 --> Hit; 0 --> Miss // For McGurk trials : 0 --> McGurk effect worked; 0 --> Miss


% {2,1} contains the name of the stim used
% {3,1} contains the level of noise used for this stimuli
% {4,1} contains the absolute path of the corresponding movie to be played
% {5,1} contains the absolute path of the corresponding sound to be played


% TO DO :
%	- Test on matlab and on other station
%	- take into account answers
%	- what if first block is McGurk : still count it.
%	- add a way to analyze just one trial
%	- Simplify !!!!!
%	- ANALYZE RT F(LENGHT OF BLOCK BEFORE).



clc
clear all
close all

KbName('UnifyKeyNames');

MovieType = '.mov';

% Figure counter
n=1;


% Creates a cell to record what answers are given for the different INC  stim
INC_Dir = 'IncongMovies';
INCMoviesDir = strcat(pwd, filesep, INC_Dir, filesep);
INCMoviesDirList = dir(strcat(INCMoviesDir,'*', MovieType));
NbINCMovies = size(INCMoviesDirList,1);

StimByStimINCRespRecap=cell(1,2);
for i=1:NbINCMovies
    StimByStimINCRespRecap{1,1}(i,:) = INCMoviesDirList(i).name(1:end-4); % Which stimuli
    StimByStimINCRespRecap{1,2}(i,:) = zeros(1,5); % What answers
end


% Creates a cell to record what answers are given for the different McGurk stim
McDir = 'McGurkMovies';
McMoviesDir = strcat(pwd, filesep, McDir, filesep);
McMoviesDirList = dir(strcat(McMoviesDir,'*', MovieType));
NbMcMovies = size(McMoviesDirList,1);

% After a congruent block
StimByStimMACRespRecap=cell(1,2);
% After an incongruent block
StimByStimMAIRespRecap=cell(1,2);

for i=1:NbMcMovies
    StimByStimMACRespRecap{1,1}(i,:) = McMoviesDirList(i).name(1:end-4); % Which stimuli
    StimByStimMAIRespRecap{1,1}(i,:) = McMoviesDirList(i).name(1:end-4);
    StimByStimMACRespRecap{1,2}(i,:) = zeros(1,5); % What answers
    StimByStimMAIRespRecap{1,2}(i,:) = zeros(1,5);
end



cd Subjects_Data



try

List = dir ('*.mat');
SizeList = size(List,1);

% Compile all the trials of all the runs
TotalTrials = cell(2,1);
for i=1:SizeList
	load(List(i).name);
	TotalTrials{1,1} = [TotalTrials{1,1} ; Trials{1,1}];
	TotalTrials{2,1} = [TotalTrials{2,1} ; Trials{2,1}];
end;

NbTrials = length(TotalTrials{1,1}(:,1));

if exist('NoiseRange')==0
	NoiseRange = zeros(1, NbMcMovies)
end

SavedMat = strcat('Results_', SubjID, '.mat');


SavedTxt = strcat('Results_', SubjID, '.csv');
fid = fopen (SavedTxt, 'w');


%--------------------------------------------- FIGURE --------------------------------------------------------
% A first quick figure to have look at the different reactions times
figure(n)
n = n+1;

scatter(15*TotalTrials{1,1}(:,3)+TotalTrials{1,1}(:,2) , TotalTrials{1,1}(:,6))
xlabel 'Trial Number'
ylabel 'Response Time'
set(gca,'tickdir', 'out', 'xtick', [1 16 31] ,'xticklabel', 'Congruent|Incongruent|McGurk', 'ticklength', [0.002 0], 'fontsize', 13)
axis 'tight'
set(gca,'ylim', [-1 5])



%------------------------------------------------------------------------------------------------------------------

% SORT TRIALS ANSWERS ACCORDING TO BLOCK TYPE
% Also sort answers of McGurk blocks in 2 matrixes depending if they were preceded by a CON or INCON block.
AllCongruent = [];
AllIncongruent = [];
McGurkAfterCongruent = [];
McGurkAfterIncongruent = [];

for i=1:NbTrials
	
	if TotalTrials{1,1}(i,7)~=999 & TotalTrials{1,1}(i,6)>1 % Skips trials where answer came after responses window or with impossible RT (negative or before the beginning of the movie)

		switch KbName( TotalTrials{1,1}(i,7) ) % Check responses given
			case RespB
			B = 1;

			case RespD
			B = 2;

			case RespP
			B = 3;

			case RespT
			B = 4;	

			otherwise
			B = 5;
		end



		if (TotalTrials{1,1}(i,3)==0) % This is a congruent trial
			AllCongruent = [AllCongruent ; TotalTrials{1,1}(i,:)];

		elseif (TotalTrials{1,1}(i,3)==1) % This is an incongruent trial
			AllIncongruent = [AllIncongruent ; TotalTrials{1,1}(i,:)];

			% Find what stimulus was played
			A = find( strcmp (cellstr( repmat(TotalTrials{2,1}(i,:), NbINCMovies, 1) ), StimByStimINCRespRecap{1,1}) );

			StimByStimINCRespRecap{1,2}(A,B) = StimByStimINCRespRecap{1,2}(A,B) + 1;

		elseif (TotalTrials{1,1}(i,3)==2)

			% Find what stimulus was played
			A = find( strcmp (cellstr( repmat(TotalTrials{2,1}(i,:), NbMcMovies, 1) ), StimByStimMACRespRecap{1,1}) );

			switch TotalTrials{1,1}(i,4) % This is a McGURK	trial	

				case 0 % following a congruent block
					McGurkAfterCongruent = [McGurkAfterCongruent ; TotalTrials{1,1}(i,:)];

					StimByStimMACRespRecap{1,2}(A,B) = StimByStimMACRespRecap{1,2}(A,B) + 1;

				case 1 % following an incongruent block
					McGurkAfterIncongruent = [McGurkAfterIncongruent ; TotalTrials{1,1}(i,:)];

					StimByStimMAIRespRecap{1,2}(A,B) = StimByStimMAIRespRecap{1,2}(A,B) + 1;
			end

		end
	
	end
end



figure(n)
n = n+1;

for i=1:NbINCMovies
    C(i,:) = StimByStimINCRespRecap{1,2}(i,:)./sum(StimByStimINCRespRecap{1,2}(i,:));
end
barh(C, 'stacked')
legend(['b'; 'd'; 'p'; 't'; ' '])
t=title ('Responses to INC stim');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'ytick', 1:14 ,'yticklabel', StimByStimINCRespRecap{1,1}, 'ticklength', [0.005 0], 'fontsize',13)
axis 'tight'



figure(n)
n = n+1;

subplot(121)
for i=1:NbMcMovies
    C(i,:) = StimByStimMACRespRecap{1,2}(i,:)./sum(StimByStimMACRespRecap{1,2}(i,:));
end
barh(C, 'stacked')
legend(['b'; 'd'; 'p'; 't'; ' '])
t=title ('Responses to McGurk stim after congruent block');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'ytick', 1:14 ,'yticklabel', StimByStimMACRespRecap{1,1}, 'ticklength', [0.005 0], 'fontsize',13)
axis 'tight'

subplot(122)
for i=1:NbMcMovies
    C(i,:)=StimByStimMAIRespRecap{1,2}(i,:)./sum(StimByStimMAIRespRecap{1,2}(i,:));
end
barh(C, 'stacked')
legend(['b'; 'd'; 'p'; 't'; ' '])
t=title ('Responses to McGurk stim after incongruent block');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'ytick', 1:14 ,'yticklabel', StimByStimMAIRespRecap{1,1}, 'ticklength', [0.005 0], 'fontsize',13)
axis 'tight'



NbAllCongruent = length(AllCongruent(:,1));
NbAllIncongruent = length(AllIncongruent(:,1));
NbAllMcGurkAfterCongruent = length(McGurkAfterCongruent(:,1));
NbAllMcGurkAfterIncongruent = length(McGurkAfterIncongruent(:,1));
NbAllMcGurk = NbAllMcGurkAfterIncongruent + NbAllMcGurkAfterCongruent;

NbAll=sum([NbAllMcGurk NbAllIncongruent NbAllCongruent]);


%------------------------------------------------------------------------------------------------------------------


% Count good answers

% For CON blocks
CongruentHit=0;
CongruentMiss=0;
for i=1:NbAllCongruent
	if AllCongruent(i,8)==1
		CongruentHit = CongruentHit+1;	
	elseif AllCongruent(i,8)==0
		CongruentMiss = CongruentMiss+1;
	else
	end;
end;
RelCongruentHit=CongruentHit/NbAllCongruent;
RelCongruentMiss=CongruentMiss/NbAllCongruent;

% For INC blocks
IncongruentHit=0;
IncongruentMiss=0;
for i=1:NbAllIncongruent
	if AllIncongruent(i,8)==1
		IncongruentHit = IncongruentHit+1;
	elseif AllIncongruent(i,8)==0
		IncongruentMiss = IncongruentMiss+1;
	else
	end;
end;
RelIncongruentHit=IncongruentHit/NbAllIncongruent;
RelIncongruentMiss=IncongruentMiss/NbAllIncongruent;



% For COUNTERPHASE blocks

% AFTER A CONGRUENT BLOCK

MaxBlockLengthMAC=max(McGurkAfterCongruent(:,2));

% Initialises a cell to record RT depending on position of the trial in the counterphase block
% First line is a matrix for Mc Gurk effect
% Second line is a matrix for no Mc Gurk effect
% Third line is a matrix for other responses
RTBlockMAC=cell(3,MaxBlockLengthMAC);

% Initialises a matrix to record auditory capture depending on position of the trial in the counterphase block
% Mc Gurk effect on the first row.
% No Mc Gurk effect on the second row.
% Other on the third row.
RespBlockMAC=zeros(6,MaxBlockLengthMAC,length(BlockLenght(1,:))+1 );

for i=1:NbAllMcGurkAfterCongruent

	if McGurkAfterCongruent(i,4)~=666 % If not a firstblock
		
		B=find( repmat(McGurkAfterCongruent(i,5), 1, length(BlockLenght(1,:)))==BlockLenght(1,:) ) + 1;
		
		if McGurkAfterCongruent(i,8)==0 % That is a Mc Gurk response
			A=1;			
		elseif McGurkAfterCongruent(i,8)==1 % That is not a Mc Gurk response
			A=2;				
		else % That is not an other response
			A=3;		
		end;
		
		RTBlockMAC{A,McGurkAfterCongruent(i,2)} = [RTBlockMAC{A,McGurkAfterCongruent(i,2)} McGurkAfterCongruent(i,6)]; % Add the reaction time value to the cell
		
		RespBlockMAC(A,McGurkAfterCongruent(i,2), 1) = RespBlockMAC(A,McGurkAfterCongruent(i,2), 1) + 1; % Increments the right value in the matrix
		RespBlockMAC(A,McGurkAfterCongruent(i,2), B) = RespBlockMAC(A,McGurkAfterCongruent(i,2), B) + 1; % Increments the right value in the matrix
	end;
end;

% Normalisation at each block position by the number of trial at this position
RespBlockMAC(4,:,:)=RespBlockMAC(1,:,:)./sum(RespBlockMAC(1:2,:,:));
RespBlockMAC(5,:,:)=RespBlockMAC(2,:,:)./sum(RespBlockMAC(1:2,:,:));
RespBlockMAC(6,:,:)=RespBlockMAC(3,:,:)./sum(RespBlockMAC(1:3,:,:));

% Gets the normalised grand total of captureOK/captureNO/switch for all blocks independtly of the trial position in the block
RelMcGurkOKMAC=sum(RespBlockMAC(1,:))/sum(sum(RespBlockMAC(1:2,:)));
RelMcGurkNOMAC=sum(RespBlockMAC(2,:))/sum(sum(RespBlockMAC(1:2,:)));
RelOtherMAC=sum(RespBlockMAC(3,:))/sum(sum(RespBlockMAC(1:3,:)));



% AFTER AN INCONGRUENT BLOCK (same logic as above)
MaxBlockLengthMAI=max(McGurkAfterIncongruent(:,2));

RTBlockMAI=cell(3, MaxBlockLengthMAI);

RespBlockMAI=zeros(6, MaxBlockLengthMAI, length(BlockLenght(2,:))+1);

for i=1:NbAllMcGurkAfterIncongruent

	if McGurkAfterIncongruent(i,4)~=666
		
		B=find( repmat(McGurkAfterIncongruent(i,5), 1, length(BlockLenght(2,:)))==BlockLenght(2,:) ) + 1;
	
		if McGurkAfterIncongruent(i,8)==0
			A=1;
			RTBlockMAI{1,McGurkAfterIncongruent(i,2)} = [RTBlockMAI{1,McGurkAfterIncongruent(i,2)} McGurkAfterIncongruent(i,6)];
		
		elseif McGurkAfterIncongruent(i,8)==1
			A=2;
			RTBlockMAI{2,McGurkAfterIncongruent(i,2)} = [RTBlockMAI{2,McGurkAfterIncongruent(i,2)} McGurkAfterIncongruent(i,6)];			
			
		else
			A=3;
			RTBlockMAI{3,McGurkAfterIncongruent(i,2)} = [RTBlockMAI{3,McGurkAfterIncongruent(i,2)} McGurkAfterIncongruent(i,6)];
			
		end;
		
		RespBlockMAI(A, McGurkAfterIncongruent(i,2), 1) = RespBlockMAI(A, McGurkAfterIncongruent(i,2), 1) + 1;
		RespBlockMAI(A, McGurkAfterIncongruent(i,2), B) = RespBlockMAI(A, McGurkAfterIncongruent(i,2), B) + 1;
		
	end;
end;

RespBlockMAI(4,:,:)=RespBlockMAI(1,:,:)./sum(RespBlockMAI(1:2,:,:));
RespBlockMAI(5,:,:)=RespBlockMAI(2,:,:)./sum(RespBlockMAI(1:2,:,:));
RespBlockMAI(6,:,:)=RespBlockMAI(3,:,:)./sum(RespBlockMAI(1:3,:,:));

RelMcGurkOKMAI=sum(RespBlockMAI(1,:))/sum(sum(RespBlockMAI(1:2,:)));
RelMcGurkNOMAI=sum(RespBlockMAI(2,:))/sum(sum(RespBlockMAI(1:2,:)));
RelOtherMAI=sum(RespBlockMAI(3,:))/sum(sum(RespBlockMAI(1:3,:)));


% Gets the normalised grand total of captureOK/captureNO/switch for all blocks independtly of the trial position in the block and indepently of what block came before
RelMcGurkOK=( sum(RespBlockMAC(1,:)) + sum(RespBlockMAI(1,:)) )/sum([sum(RespBlockMAC(1:3,:)) sum(RespBlockMAI(1:3,:))]);
RelMcGurkNO=( sum(RespBlockMAC(2,:)) + sum(RespBlockMAI(2,:)) )/sum([sum(RespBlockMAC(1:3,:)) sum(RespBlockMAI(1:3,:))]);
RelOther=( sum(RespBlockMAC(3,:)) + sum(RespBlockMAI(3,:)) )/sum([sum(RespBlockMAC(1:3,:)) sum(RespBlockMAI(1:3,:))]);



%--------------------------------------------- FIGURE --------------------------------------------------------
% Plot Hits and Misses
figure(n)
n=n+1;

subplot(2,2,1:2)
% Plots histograms for "hits" and "misses" for all the McGurk trials
bar([RelMcGurkOK RelMcGurkNO RelOther], 0.7)
t=title ('Counterphase');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:3 ,'xticklabel', 'Mc Gurk|No Mc Gurk|Other', 'ticklength', [0.005 0], 'fontsize',13)
axis 'tight'
% set(gca,'ylim', [0 1])

subplot(2,2,3)
% Plots histograms for "hits" and "misses" for all the CON trials
bar([RelCongruentHit RelCongruentMiss], 0.7)
t=title ('Congruent');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:2 ,'xticklabel', 'Correct|Incorrect', 'ticklength', [0.005 0], 'fontsize',13)
axis 'tight'
set(gca,'ylim', [0 1])

subplot(2,2,4)
% Plots histograms for "hits" and "misses" for all the CON trials
bar([RelIncongruentHit RelIncongruentMiss], 0.7)
t=title ('Incongruent');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:2 ,'xticklabel', 'Correct|Incorrect', 'ticklength', [0.005 0], 'fontsize',13)
axis 'tight'
set(gca,'ylim', [0 1])


%--------------------------------------------- FIGURE --------------------------------------------------------
% Plot Hits and Misses trial per trial within McGurk block
figure(n)
n=n+1;

subplot(3,2,1)
% Plots histograms for "hits" for the counterphase after CON blocks
bar([RelMcGurkOKMAC RespBlockMAC(4,:,1)], 0.7)
t=title ('After Congruent');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:(MaxBlockLengthMAC+1) ,'xticklabel', 'All|1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize',13) % Improve naming
ylabel 'Mc Gurk'
axis 'tight'
set(gca,'ylim', [0 1])

subplot(3,2,3)
% Plots histograms for "misses" for the counterphase after CON blocks
bar([RelMcGurkNOMAC RespBlockMAC(5,:,1)], 0.7)
set(gca,'tickdir', 'out', 'xtick', 1:(MaxBlockLengthMAC+1) ,'xticklabel', 'All|1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize',13)
ylabel 'No Mc Gurk'
axis 'tight'
set(gca,'ylim', [0 1])

subplot(3,2,5)
% Plots histograms for Switch for the counterphase after CON blocks
bar([RelOtherMAC RespBlockMAC(6,:,1)], 0.7)
set(gca,'tickdir', 'out', 'xtick', 1:(MaxBlockLengthMAC+1) ,'xticklabel', 'All|1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize',13)
ylabel 'Other'
xlabel 'Trial Number'
axis 'tight'
set(gca,'ylim', [0 1])



subplot(3,2,2)
% Plots histograms for "hits" for the counterphase after INC blocks
bar([RelMcGurkOKMAI RespBlockMAI(4,:,1)], 0.7)
t=title ('After Incongruent');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:(MaxBlockLengthMAI+1) ,'xticklabel', 'All|1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize',13)
axis 'tight'
set(gca,'ylim', [0 1])

subplot(3,2,4)
% Plots histograms for "misses" for the counterphase after INC blocks
bar([RelMcGurkNOMAI RespBlockMAI(5,:,1)], 0.7)
set(gca,'tickdir', 'out', 'xtick', 1:(MaxBlockLengthMAI+1) ,'xticklabel', 'All|1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize',13)
axis 'tight'
set(gca,'ylim', [0 1])

subplot(3,2,6)
% Plots histograms for "misses" for the counterphase after INC blocks
bar([RelOtherMAI RespBlockMAI(6,:,1)], 0.7)
set(gca,'tickdir', 'out', 'xtick', 1:(MaxBlockLengthMAI+1) ,'xticklabel', 'All|1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize',13)
xlabel 'Trial Number'
axis 'tight'
set(gca,'ylim', [0 1])
	


figure(n)
n=n+1;

Color=['r','g','b','c'];

subplot(1,2,1)
% Plots histograms for "hits" for the counterphase after CON blocks

for i=1:length(BlockLenght(1,:))
	plot(RespBlockMAC(4,:,i+1), Color(i))
	hold on
end
t=title ('After Congruent');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:(MaxBlockLengthMAC+1) ,'xticklabel', '1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize',13)
ylabel 'Mc Gurk'
axis 'tight'
set(gca,'ylim', [0 1])
legend(num2str(BlockLenght(1,:)'), 'Location', 'SouthEast')

subplot(1,2,2)
% Plots histograms for "hits" for the counterphase after CON blocks
hold on
for i=1:length(BlockLenght(2,:))
	plot(RespBlockMAI(4,:,i+1), Color(i))
end
t=title ('After Incongruent');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:(MaxBlockLengthMAI+1) ,'xticklabel', '1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize',13)
ylabel 'Mc Gurk'
axis 'tight'
set(gca,'ylim', [0 1])
legend(num2str(BlockLenght(2,:)'), 'Location', 'SouthEast')


	
%------------------------------------------- REACTION TIMES ----------------------------------------------	


% Get Mean and SD of RT for INC trials
MeanAllIncongruentRT = mean(AllIncongruent(:,6));
SDAllIncongruentRT = std(AllIncongruent(:,6));


RTBlockINC=cell(1,max(AllIncongruent(:,2)),3);
ResultsRTBlockINC=[];

for i=1:length(AllIncongruent)
	switch AllIncongruent(i,4)
		case 0
			A=1;
		case 2
			A=2;
		otherwise
			A=3;
	end
		
	RTBlockINC{1,AllIncongruent(i,2),A}=[RTBlockINC{1,AllIncongruent(i,2),A}; AllIncongruent(i,6)];
end

for i=1:max(AllIncongruent(:,2))
	for j=1:3
		if isempty(RTBlockINC{1,i,j})==0
		ResultsRTBlockINC(1,i,j)=mean(RTBlockINC{1,i,j});
		ResultsRTBlockINC(2,i,j)=std(RTBlockINC{1,i,j});
		end
	end
end


% Get Mean and SD of RT for CON trials
MeanAllCongruentRT = mean(AllCongruent(:,6));
SDAllCongruentRT = std(AllCongruent(:,6));


RTBlockCON=cell(1,max(AllCongruent(:,2)),3);
ResultsRTBlockCON=[];

for i=1:length(AllCongruent)
	
	switch AllCongruent(i,4)
		case 1
			A=1;
		case 2
			A=2;
		otherwise
			A=3;
	end
	
	RTBlockCON{1,AllCongruent(i,2),A}=[RTBlockCON{1,AllCongruent(i,2),A}; AllCongruent(i,6)];
end

for i=1:max(AllCongruent(:,2))
	for j=1:3
		if isempty(RTBlockCON{1,i,j})==0
		ResultsRTBlockCON(1,i,j)=mean(RTBlockCON{1,i,j});
		ResultsRTBlockCON(2,i,j)=std(RTBlockCON{1,i,j});
		end
	end
end


% And for the blocks of McGurk
MeanMcGurkRT=0*ones(2,4);

% Gets mean and std RT of all responses irrespectively of position in blocks and of what block came before
MeanMcGurkRT(1:2,1) =[ mean([ [RTBlockMAI{1:3,:}] [RTBlockMAC{1:3,:}] ]) ; std([ [RTBlockMAI{1:3,:}] [RTBlockMAC{1:3,:}] ]) ];

% Gets mean and std RT for different responses types irrespectively of position in blocks and of what block came before
A=[cellfun(@isempty,RTBlockMAC) cellfun(@isempty,RTBlockMAI)];
for i=1:3
	if all(A(i,:))~=1
   		MeanMcGurkRT(1:2,i+1) = [ mean([ [RTBlockMAI{i,:}] [RTBlockMAC{i,:}] ]) ; std([ [RTBlockMAI{i,:}] [RTBlockMAC{i,:}] ]) ];
   	end
end

% After a CON block

% Initialise a matrix to store mean and std as function of block position
ResultsRTBlockMAC=0*ones(8,MaxBlockLengthMAC);

for i=1:MaxBlockLengthMAC
	if ~isempty(RTBlockMAC{1,i})
	ResultsRTBlockMAC(1:2,i) = [mean(RTBlockMAC{1,i}) ; std(RTBlockMAC{1,i})]; % For the RT in case of Mc Gurk
	end
	
	if ~isempty(RTBlockMAC{2,i})
	ResultsRTBlockMAC(3:4,i) = [mean(RTBlockMAC{2,i}) ; std(RTBlockMAC{2,i})]; % For the RT in case of no Mc Gurk
	end
	
	if ~isempty(RTBlockMAC{3,i})
	ResultsRTBlockMAC(5:6,i) = [mean(RTBlockMAC{3,i}) ; std(RTBlockMAC{3,i})]; % For the RT for the other responses
	end
	
	ResultsRTBlockMAC(7:8,i) = [ mean([RTBlockMAC{1:3,i}]) ; std([RTBlockMAC{1:3,i}]) ]; % For the RT of all responses
end;

% Gets mean and std RT of all responses irrespectively of position in blocks
MeanMcGurkAfterCongruentRT = mean([RTBlockMAC{1:3,:}]);
SDMcGurkAfterCongruentRT = std([RTBlockMAC{1:3,:}]);

% Gets mean and std RT of all responses of one response type irrespectively of position in blocks
for i=1:3
RTBlockMAC{i,MaxBlockLengthMAC+1} = mean([RTBlockMAC{i,:}]);
RTBlockMAC{i,MaxBlockLengthMAC+2} = std([RTBlockMAC{i,:}]);
end



% After a INC block (same logic as above

ResultsRTBlockMAI=0*ones(8,MaxBlockLengthMAI);

for i=1:MaxBlockLengthMAI
	if ~isempty(RTBlockMAI{1,i})
	ResultsRTBlockMAI(1:2,i) = [mean(RTBlockMAI{1,i}) ; std(RTBlockMAI{1,i})];
	end
	
	if ~isempty(RTBlockMAI{2,i})
	ResultsRTBlockMAI(3:4,i) = [mean(RTBlockMAI{2,i}) ; std(RTBlockMAI{2,i})];
	end
	
	if ~isempty(RTBlockMAI{3,i})
	ResultsRTBlockMAI(5:6,i) = [mean(RTBlockMAI{3,i}) ; std(RTBlockMAI{3,i})];
	end
	
	ResultsRTBlockMAI(7:8,i) = [ mean([RTBlockMAI{1:3,i}]) ; std([RTBlockMAI{1:3,i}]) ];	
end;

MeanMcGurkAfterIncongruentRT = mean([RTBlockMAI{1:3,:}]);
SDMcGurkAfterIncongruentRT = std([RTBlockMAI{1:3,:}]);

% Gets mean and std RT of all responses of one response type irrespectively of position in blocks
for i=1:3
RTBlockMAI{i,MaxBlockLengthMAI+1} = mean([RTBlockMAI{i,:}]);
RTBlockMAI{i,MaxBlockLengthMAI+2} = std([RTBlockMAI{i,:}]);
end



%--------------------------------------------- FIGURE --------------------------------------------------------
% Plot RTs
figure(n)
n=n+1;

subplot(211)
% Plots RT histograms the Mc Gurk trials
bar([MeanMcGurkRT(1,:)], 0.7)
hold on
for i=1:4
	errorbar(i, MeanMcGurkRT(1,i) , MeanMcGurkRT(2,i))
end
t=title ('Reaction Times');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:4 ,'xticklabel', 'All|Mc Gurk OK|Mc Gurk NO|Other', 'ticklength', [0.005 0], 'fontsize', 13)
axis 'tight'
set(gca,'ylim', [1 3])

subplot(212)
% Plots RT histograms the other trials
bar([MeanAllCongruentRT MeanAllIncongruentRT], 0.7)
hold on
errorbar(1, MeanAllCongruentRT, SDAllCongruentRT);
errorbar(2, MeanAllIncongruentRT, SDAllIncongruentRT);
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:2 ,'xticklabel', 'Congruent|Incongruent', 'ticklength', [0.005 0], 'fontsize', 13)
axis 'tight'
set(gca,'ylim', [1 3])


%--------------------------------------------- FIGURE --------------------------------------------------------
% Plot RTs
figure(n)
n=n+1;
t=title ('Reaction Times');

subplot(221)
% Plots RT histograms the INC trials
bar(ResultsRTBlockINC(1,:,1), 0.7)
hold on
for i=1:length(ResultsRTBlockINC(1,:,1))
	errorbar(i, ResultsRTBlockINC(1,i,1) , ResultsRTBlockINC(2,i,1))
end
t=title ('Incongruent');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:length(ResultsRTBlockINC(1,:,1)) ,'xticklabel', 1:length(ResultsRTBlockINC(1,:,1)), 'ticklength', [0.005 0], 'fontsize', 13)
axis 'tight'
ylabel ('After congruent')
set(gca,'ylim', [1 3])

subplot(222)
% Plots RT histograms the CON trials
bar(ResultsRTBlockCON(1,:,1), 0.7)
hold on
for i=1:length(ResultsRTBlockCON(1,:,1))
	errorbar(i, ResultsRTBlockCON(1,i,1) , ResultsRTBlockCON(2,i,1))
end
t=title ('Congruent');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:length(ResultsRTBlockCON(1,:,1)) ,'xticklabel', 1:length(ResultsRTBlockCON(1,:,1)), 'ticklength', [0.005 0], 'fontsize', 13)
axis 'tight'
ylabel ('After incongruent')
set(gca,'ylim', [1 3])

subplot(223)
% Plots RT histograms the INC trials
bar(ResultsRTBlockINC(1,:,2), 0.7)
hold on
for i=1:length(ResultsRTBlockINC(1,:,2))
	errorbar(i, ResultsRTBlockINC(1,i,2) , ResultsRTBlockINC(2,i,2))
end
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:length(ResultsRTBlockINC(1,:,2)) ,'xticklabel', 1:length(ResultsRTBlockINC(1,:,2)), 'ticklength', [0.005 0], 'fontsize', 13)
axis 'tight'
ylabel ('After McGurk')
set(gca,'ylim', [1 3])

subplot(224)
% Plots RT histograms the CON trials
bar(ResultsRTBlockCON(1,:,2), 0.7)
hold on
for i=1:length(ResultsRTBlockCON(1,:,2))
	errorbar(i, ResultsRTBlockCON(1,i,2) , ResultsRTBlockCON(2,i,2))
end
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:length(ResultsRTBlockCON(1,:,2)) ,'xticklabel', 1:length(ResultsRTBlockCON(1,:,2)), 'ticklength', [0.005 0], 'fontsize', 13)
axis 'tight'
ylabel ('After McGurk')
set(gca,'ylim', [1 3])


%--------------------------------------------- FIGURE --------------------------------------------------------
% Plot RTs for each trial across Mc Gurk BLOCKS
figure(n)
n=n+1;

% after CON blocks
subplot(211)
bar([MeanMcGurkAfterCongruentRT ResultsRTBlockMAC(7,:)], 0.7)
hold on
errorbar(1, MeanMcGurkAfterCongruentRT, SDMcGurkAfterCongruentRT);
for i=1:MaxBlockLengthMAC
	errorbar(i+1, ResultsRTBlockMAC(7,i) , ResultsRTBlockMAC(8,i))
end
t=title ('RT for Mc Gurk block after a CON block');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:(MaxBlockLengthMAC+1),'xticklabel', 'All|1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize', 13)
axis 'tight'
set(gca,'ylim', [1 3])

% after INC blocks
subplot(212)
bar([MeanMcGurkAfterIncongruentRT ResultsRTBlockMAI(7,:)], 0.7)
hold on
errorbar(1, MeanMcGurkAfterIncongruentRT, SDMcGurkAfterIncongruentRT);
for i=1:MaxBlockLengthMAI
	errorbar(i+1, ResultsRTBlockMAI(7,i) , ResultsRTBlockMAI(8,i))
end
t=title ('RT for Mc Gurk block after an INC block');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:(MaxBlockLengthMAC+1) ,'xticklabel', 'All|1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize', 13)
xlabel 'Trial Number'
axis 'tight'
set(gca,'ylim', [1 3])



%--------------------------------------------- FIGURE --------------------------------------------------------
% Plot RTs for each trial across COUNTERPHASE BLOCKS depending on the type
% of response
figure(n)
n=n+1;

% after CON blocks
subplot(321)
bar([RTBlockMAC{1,MaxBlockLengthMAC+1} ResultsRTBlockMAC(1,:)], 0.7)
hold on
errorbar(1, RTBlockMAC{1,MaxBlockLengthMAC+1} , RTBlockMAC{1,MaxBlockLengthMAC+2})
for i=1:MaxBlockLengthMAC
	errorbar(i+1, ResultsRTBlockMAC(1,i) , ResultsRTBlockMAC(2,i))
end
t=title ('RT after a CON block');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:MaxBlockLengthMAC+1,'xticklabel', 'All|1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize', 13)
ylabel 'Mc Gurk OK'
axis 'tight'
set(gca,'ylim', [1 3])

subplot(323)
bar([RTBlockMAC{2,MaxBlockLengthMAC+1} ResultsRTBlockMAC(3,:)], 0.7)
hold on
errorbar(1, RTBlockMAC{2,MaxBlockLengthMAC+1} , RTBlockMAC{2,MaxBlockLengthMAC+2})
for i=1:MaxBlockLengthMAC
	errorbar(i+1, ResultsRTBlockMAC(3,i) , ResultsRTBlockMAC(4,i))
end
set(gca,'tickdir', 'out', 'xtick', 1:MaxBlockLengthMAC+1,'xticklabel', 'All|1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize', 13)
ylabel 'Mc Gurk NO'
axis 'tight'
set(gca,'ylim', [1 3])

subplot(325)
bar([RTBlockMAC{3,MaxBlockLengthMAC+1} ResultsRTBlockMAC(5,:)], 0.7)
hold on
errorbar(1, RTBlockMAC{3,MaxBlockLengthMAC+1} , RTBlockMAC{3,MaxBlockLengthMAC+2})
for i=1:MaxBlockLengthMAC
	errorbar(i+1, ResultsRTBlockMAC(5,i) , ResultsRTBlockMAC(6,i))
end
set(gca,'tickdir', 'out', 'xtick', 1:MaxBlockLengthMAC+1,'xticklabel', 'All|1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize', 13)
ylabel 'Other'
xlabel 'Trial Number'
axis 'tight'
set(gca,'ylim', [1 3])



% after INC blocks
subplot(322)
bar([RTBlockMAI{1,MaxBlockLengthMAI+1} ResultsRTBlockMAI(1,:)], 0.7)
hold on
errorbar(1, RTBlockMAI{1,MaxBlockLengthMAI+1} , RTBlockMAI{1,MaxBlockLengthMAI+2})
for i=1:MaxBlockLengthMAI
	errorbar(i+1, ResultsRTBlockMAI(1,i) , ResultsRTBlockMAI(2,i))
end
t=title ('RT after an INC block');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:MaxBlockLengthMAI+1,'xticklabel', 'All|1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize', 13)
axis 'tight'
set(gca,'ylim', [1 3])

subplot(324)
bar([RTBlockMAI{2,MaxBlockLengthMAI+1} ResultsRTBlockMAI(3,:)], 0.7)
hold on
errorbar(1, RTBlockMAI{2,MaxBlockLengthMAI+1} , RTBlockMAI{2,MaxBlockLengthMAI+2})
for i=1:MaxBlockLengthMAI
	errorbar(i+1, ResultsRTBlockMAI(3,i) , ResultsRTBlockMAI(4,i))
end
set(gca,'tickdir', 'out', 'xtick', 1:MaxBlockLengthMAI+1,'xticklabel', 'All|1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize', 13)
axis 'tight'
set(gca,'ylim', [1 3])

subplot(326)
bar([RTBlockMAI{3,MaxBlockLengthMAI+1} ResultsRTBlockMAI(5,:)], 0.7)
hold on
errorbar(1, RTBlockMAI{3,MaxBlockLengthMAI+1} , RTBlockMAI{3,MaxBlockLengthMAI+2})
for i=1:MaxBlockLengthMAI
	errorbar(i+1, ResultsRTBlockMAI(5,i) , ResultsRTBlockMAI(6,i))
end
set(gca,'tickdir', 'out', 'xtick', 1:MaxBlockLengthMAI+1,'xticklabel', 'All|1|2|3|4|5|6|7|8|9|10', 'ticklength', [0.005 0], 'fontsize', 13)
xlabel 'Trial Number'
axis 'tight'
set(gca,'ylim', [1 3])


if (IsOctave==0)

	figure(1) 
	print(gcf, 'Figures.ps', '-dpsc2'); % Print figures in ps format
	for i=2:(n-1)
		figure(i)
		print(gcf, 'Figures.ps', '-dpsc2', '-append'); 
    end;
    
    for i=1:(n-1)
        figure(i)
        print(gcf, strcat('Fig', num2str(i) ,'.eps'), '-depsc'); % Print figures in vector format
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
	% Find a way to loop this as well !!!
    	for i=1:(n-1)
    		figure(i)  	   	
    		print(gcf, strcat('Fig', num2str(i) ,'.svg'), '-dsvg'); % Print figures in vector format
	    	print(gcf, strcat('Fig', num2str(i) ,'.pdf'), '-dpdf'); % Print figures in pdf format
    	end;
    	    	    
    	if (IsLinux==1) % try to concatenate pdf
        	try
        	delete Figures.pdf; 
        	system('pdftk Fig?.pdf cat output Figures.pdf');
        	delete Fig?.pdf
        	catch
        	fprintf('\n We are on Linux. :-) But we could not concatenate the pdfs. Maybe check if the software pdftk is installed. \n\n');
        	end;
    	end;
end;

cd ..


A=[];

fprintf (fid, 'SUBJECT, %s\n\n', SubjID);

fprintf (fid, 'Length of the different condition blocks\n');
fprintf (fid, 'Congruent, %i, %i, %i, %i\n', BlockLenght(1,:)');
fprintf (fid, 'Incongruent, %i, %i, %i, %i\n', BlockLenght(2,:)');
fprintf (fid, 'McGurk, %i, %i, %i, %i\n\n', BlockLenght(3,:)');


fprintf (fid, '\nNoise level for the different McGurk stimuli\n');
for i=1:NbMcMovies
	fprintf (fid, '%s, %6.2f\n', StimByStimMACRespRecap{1,1}(i,:), NoiseRange(i) );
end

fprintf (fid, '\nTotal number of trials, %i\n\n', NbAll);

fprintf (fid, '\nRESPONSES,Correct (Percent.),Total\n');
fprintf (fid, 'Congruent, %6.4f, %i\n', RelCongruentHit, NbAllCongruent);
fprintf (fid, 'Incongruent, %6.4f, %i\n\n', RelIncongruentHit, NbAllIncongruent);

fprintf (fid,'Responses for INCONGRENT stimuli,b,d,p,t,Other\n');
for i=1:NbINCMovies
	fprintf (fid, '%s,' , StimByStimINCRespRecap{1,1}(i,:) ); fprintf (fid, '%6.2f,' , StimByStimINCRespRecap{1,2}(i,:) );
	fprintf (fid, '\n');
end

fprintf (fid, '\nREACTION TIMES,Mean,STD\n');
fprintf (fid, 'Congruent,%6.3f,%6.3f\n', MeanAllCongruentRT, SDAllCongruentRT);
fprintf (fid, 'Incongruent,%6.3f,%6.3f\n', MeanAllIncongruentRT, SDAllIncongruentRT);

for i=1:max(BlockLenght(1,:))
	A(i)=length(RTBlockCON{1,i,1});
end
fprintf (fid, '\nCONGRUENT\n');
fprintf (fid, 'After incongruent,'); fprintf (fid, '%i,', 1:max(AllCongruent(:,2)) );
fprintf (fid, '\nMean,'); fprintf (fid, '%6.3f,', ResultsRTBlockCON(1,:,1) );
fprintf (fid, '\nSTD,'); fprintf (fid, '%6.3f,', ResultsRTBlockCON(2,:,1) );
fprintf (fid, '\nn,'); fprintf (fid, '%i,', A );

for i=1:max(BlockLenght(1,:))
	A(i)=length(RTBlockCON{1,i,2});
end		
fprintf (fid, '\n\nAfter McGurk,'); fprintf (fid, '%i,', 1:max(AllCongruent(:,2)) );
fprintf (fid, '\nMean,'); fprintf (fid, '%6.3f,', ResultsRTBlockCON(1,:,2) );
fprintf (fid, '\nSTD,'); fprintf (fid, '%6.3f,', ResultsRTBlockCON(2,:,2) );
fprintf (fid, '\nn,'); fprintf (fid, '%i,', A );

for i=1:max(BlockLenght(2,:))
	A(i)=length(RTBlockINC{1,i,1});
end
fprintf (fid, '\n\nINCONGRUENT\n');
fprintf (fid, 'After congruent,'); fprintf (fid, '%i,', 1:max(AllIncongruent(:,2)) );
fprintf (fid, '\nMean,'); fprintf (fid, '%6.3f,', ResultsRTBlockINC(1,:,1) );
fprintf (fid, '\nSTD,'); fprintf (fid, '%6.3f,', ResultsRTBlockINC(2,:,1) );
fprintf (fid, '\nn,'); fprintf (fid, '%i,', A );

for i=1:max(BlockLenght(2,:))
	A(i)=length(RTBlockINC{1,i,2});
end
fprintf (fid, '\n\nAfter McGurk,'); fprintf (fid, '%i,', 1:max(AllIncongruent(:,2)) );
fprintf (fid, '\nMean,'); fprintf (fid, '%6.3f,', ResultsRTBlockINC(1,:,2) );
fprintf (fid, '\nSTD,'); fprintf (fid, '%6.3f,', ResultsRTBlockINC(2,:,2) );
fprintf (fid, '\nn,'); fprintf (fid, '%i,', A );


fprintf (fid, '\n\n\nMcGURK \n\n');

fprintf (fid, 'RESPONSES, McGurk Reponses (Percent.),Other,Total\n');
fprintf (fid, 'After a congruent block, %6.4f, %i, %i\n', RelMcGurkOKMAC , sum(RespBlockMAC(3,:,1)) , sum(sum(RespBlockMAC(1:2,:,1))) );
fprintf (fid, 'After an incongruent block, %6.4f, %i, %i\n', RelMcGurkOKMAI, sum(RespBlockMAI(3,:,1)) , sum(sum(RespBlockMAI(1:2,:,1))) );
fprintf (fid, 'Total, %6.4f, %i, %i\n\n', RelMcGurkOK, sum ([sum(RespBlockMAC(3,:,1))  sum(RespBlockMAI(3,:,1))]) , sum([sum(RespBlockMAC(1:2,:,1)) sum(RespBlockMAI(1:2,:,1))]) );


fprintf (fid, '\nAfter a CONGRUENT block \n\n');

B = ['X' ; num2str(BlockLenght(1,:)')];
for j=1:length(BlockLenght(1,:))+1
	fprintf (fid, 'After %s CONGRUENT trials', B(j) );
	fprintf (fid, '\nTrial number,') ; fprintf (fid, '%i,' , 1:MaxBlockLengthMAC);
	%fprintf (fid, '\nMcGurk,') ; fprintf (fid, '%6.4f,' , RespBlockMAC(1,:,j));
	fprintf (fid, '\nMcGurk (Percent.),') ; fprintf (fid, '%6.4f,' , RespBlockMAC(4,:,j));
	fprintf (fid, '\nOther,') ; fprintf (fid, '%i,' , RespBlockMAC(3,:,j));
	fprintf (fid, '\nTotal,') ; fprintf (fid, '%i,' , sum(RespBlockMAC(1:2,:,j)) );
	fprintf (fid, '\n\n');
end

fprintf (fid,'Responses stimulus per stimulus,b,d,p,t,Other\n');
for i=1:NbINCMovies
	fprintf (fid, '%s,' , StimByStimMACRespRecap{1,1}(i,:) ); fprintf (fid, '%6.2f,' , StimByStimMACRespRecap{1,2}(i,:) );
	fprintf (fid, '\n');
end


fprintf (fid, '\n\nAfter an INCONGRUENT block \n\n');
B = ['X' ; num2str(BlockLenght(2,:)')];
for j=1:length(BlockLenght(1,:))+1
	fprintf (fid, 'After %s INCONGRUENT trials', B(j) );
	fprintf (fid, '\nTrial number,') ; fprintf (fid, '%i,' , 1:MaxBlockLengthMAI);
	%fprintf (fid, '\nMcGurk,') ; fprintf (fid, '%6.4f,' , RespBlockMAI(1,:,j));
	fprintf (fid, '\nMcGurk (Percent.),') ; fprintf (fid, '%6.4f,' , RespBlockMAI(4,:,j));
	fprintf (fid, '\nOther,') ; fprintf (fid, '%i,' , RespBlockMAI(3,:,j));
	fprintf (fid, '\nTotal,') ; fprintf (fid, '%i,' , sum(RespBlockMAI(1:2,:,j)) );
	fprintf (fid, '\n\n');
end

fprintf (fid,'Responses stimulus per stimulus,b,d,p,t,Other\n');
for i=1:NbINCMovies
	fprintf (fid, '%s,' , StimByStimMAIRespRecap{1,1}(i,:) ); fprintf (fid, '%6.2f,' , StimByStimMAIRespRecap{1,2}(i,:) );
	fprintf (fid, '\n');
end

fprintf (fid, '\nREACTION TIMES,Mean,STD\n');
fprintf (fid, 'All,%6.3f,%6.3f\n', MeanMcGurkRT(1,1), MeanMcGurkRT(2,1));
fprintf (fid, 'Mc McGurk,%6.3f,%6.3f\n', MeanMcGurkRT(1,2), MeanMcGurkRT(2,2));
fprintf (fid, 'No McGurk,%6.3f,%6.3f\n', MeanMcGurkRT(1,3), MeanMcGurkRT(2,3));

fprintf (fid, '\nAfter a CONGRUENT block,Mean,STD\n');
fprintf (fid, 'Mc McGurk,%6.3f,%6.3f\n', RTBlockMAC{1,MaxBlockLengthMAC+1} , RTBlockMAC{1,MaxBlockLengthMAC+2});
fprintf (fid, 'No McGurk,%6.3f,%6.3f\n', RTBlockMAC{2,MaxBlockLengthMAC+1} , RTBlockMAC{2,MaxBlockLengthMAC+2});

fprintf (fid, '\nMcGurk: Trial number,'); fprintf (fid, '%i,', 1:MaxBlockLengthMAC);
fprintf (fid, '\nMean,'); fprintf (fid, '%6.3f,', ResultsRTBlockMAC(1,:));
fprintf (fid, '\nSTD,'); fprintf (fid, '%6.3f,', ResultsRTBlockMAC(2,:));

fprintf (fid, '\n\nNo McGurk: Trial number,'); fprintf (fid, '%i,', 1:MaxBlockLengthMAC);
fprintf (fid, '\nMean,'); fprintf (fid, '%6.3f,', ResultsRTBlockMAC(3,:));
fprintf (fid, '\nSTD,'); fprintf (fid, '%6.3f,', ResultsRTBlockMAC(4,:));

fprintf (fid, '\n\nAfter an INCONGRUENT block,Mean,STD\n');
fprintf (fid, 'Mc McGurk,%6.3f,%6.3f\n', RTBlockMAI{1,MaxBlockLengthMAI+1} , RTBlockMAI{1,MaxBlockLengthMAI+2});
fprintf (fid, 'No McGurk,%6.3f,%6.3f\n', RTBlockMAI{2,MaxBlockLengthMAI+1} , RTBlockMAI{2,MaxBlockLengthMAI+2});

fprintf (fid, '\nMcGurk: Trial number,'); fprintf (fid, '%i,', 1:MaxBlockLengthMAI);
fprintf (fid, '\nMean,'); fprintf (fid, '%6.3f,', ResultsRTBlockMAI(1,:));
fprintf (fid, '\nSTD,'); fprintf (fid, '%6.3f,', ResultsRTBlockMAI(2,:));

fprintf (fid, '\n\nNo McGurk: Trial number,'); fprintf (fid, '%i,', 1:MaxBlockLengthMAI);
fprintf (fid, '\nMean,'); fprintf (fid, '%6.3f,', ResultsRTBlockMAI(3,:));
fprintf (fid, '\nSTD,'); fprintf (fid, '%6.3f,', ResultsRTBlockMAI(4,:));


fclose (fid);



clear A B C AVOffsetMat List MaxBlockLengthMAC MaxBlockLengthMAI Run SizeList Trials ans i j n t vblS Color fid




% Saving the data
if (IsOctave==0)
    save (SavedMat);
else
    save ('-mat7-binary', SavedMat);
end;



catch
cd ..
lasterror
end
