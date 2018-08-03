function AnalyseVisualData

%

% Trials{1,1}(i,:) = [j NoiseSoundLevel RT Resp RespCat];
% j			- is the trial number.
% NoiseSoundLevel	- Noise level for this trial
% RT
% Resp
% RespCat	 2 --> McGurk effect did not worked; 3 --> Mc Gurk effect worked; 4 --> something else answered


% TO DO :
%	- Test on matlab and on other station
%	- take into account answers Other


clc
clear all
close all




% message = 'Parametric Bootstrap (1) or Non-Parametric Bootstrap? (2): ';
ParOrNonPar = 1; %input(message);
%Parameter grid defining parameter space through which to perform a
%brute-force search for values to be used as initial guesses in iterative
%parameter search.
searchGrid.alpha = 0:.01:1;
searchGrid.beta = logspace(1,3,100);
searchGrid.gamma = 0;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0:.01:1;  %ditto

%Threshold and Slope are free parameters, guess and lapse rate are fixed
paramsFree = [1 1 0 1];  %1: free parameter, 0: fixed parameter
 
%Fit a Logistic function
PF = @PAL_Logistic;  %Alternatives: PAL_Gumbel, PAL_Weibull, 
                     %PAL_CumulativeNormal, PAL_HyperbolicSecant

%Optional:
options = PAL_minimize('options');   %type PAL_minimize('options','help') for help
options.TolFun = 1e-09;     %increase required precision on LL
options.MaxIter = 400;
options.Display = 'off';    %suppress fminsearch messages
lapseLimits = [0 1];        %limit range for lambda
                            %(will be ignored here since lambda is not a
                            %free parameter)




% Figure counter
n=1;

MovieType = '.mov';
McDir = 'McGurkMovies';

McMoviesDir = strcat(pwd, filesep, McDir, filesep);
McMoviesDirList = dir(strcat(McMoviesDir,'*', MovieType));
NbMcMovies = size(McMoviesDirList,1);

StimByStimRespRecap=cell(NbMcMovies,2);


McMoviesDirList.name

cd Subjects_Data

try

List = dir ('*.mat');
SizeList = size(List,1);

% Compile all the trials of all the runs
TotalTrials = cell(2,1);
for i=1:SizeList
	load(List(i).name);
	TotalTrials{1,1}=[TotalTrials{1,1};Trials{1,1}];
	TotalTrials{2,1}=[TotalTrials{2,1};Trials{2,1}];
end;

StimLevels = NoiseSoundRange;
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];

NbTrials = length(TotalTrials{1,1}(:,1));

SavedMat = strcat('Results_', SubjID, '.mat');

RespRecap = [ NoiseSoundRange; zeros(3, length(NoiseSoundRange)) ];


for i=1:NbMcMovies
    StimByStimRespRecap{i,2} = McMoviesDirList(i).name(1:end-4);
    StimByStimRespRecap{i,1} = [ NoiseSoundRange; zeros(3, length(NoiseSoundRange)) ];
    
    RespTypeRecap{1,1}(i,:) = McMoviesDirList(i).name(1:end-4);
    RespTypeRecap{1,2}(i,:) = zeros(1,5);
end



for i=1:NbTrials
    
	for j=1:NbMcMovies
		if TotalTrials{2,1}(i,:)==StimByStimRespRecap{j,2}
		StimByStimRespRecap{j,1}(TotalTrials{1,1}(i,5) , TotalTrials{1,1}(i,2)) = StimByStimRespRecap{j,1}(TotalTrials{1,1}(i,5) , TotalTrials{1,1}(i,2)) + 1;
		end
	end

	
	RespRecap(TotalTrials{1,1}(i,5) ,TotalTrials{1,1}(i,2)) = RespRecap(TotalTrials{1,1}(i,5) ,TotalTrials{1,1}(i,2)) + 1;
    
    
	switch KbName( TotalTrials{1,1}(i,4) ) % Check responses given
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
	
	% Find what stimulus was played
	A = find( strcmp (cellstr( repmat(TotalTrials{2,1}(i,:), NbMcMovies, 1) ), RespTypeRecap{1,1}) );
    
	RespTypeRecap{1,2}(A,B) = RespTypeRecap{1,2}(A,B) + 1;
    
end;

RespRecap


for i=1:NbMcMovies
    StimByStimRespRecap{i,:}
end

RespTypeRecap{1,1}
RespTypeRecap{1,2}


figure(n)
n = n+1;

title ('Stimuli by Stimuli')

color = ['r' 'g' 'b' 'c' 'y' 'm'];

LegendContent = [];

hold on

for i=1:NbMcMovies
	plot(StimByStimRespRecap{i,1}(1,:), [StimByStimRespRecap{i,1}(3,:)./sum(StimByStimRespRecap{i,1}(2:3,:))], '.--', 'Color', color(i),'MarkerEdgeColor', color(i), 'markersize', 20)

    	[paramsValues LL exitflag output] = PAL_PFML_Fit(StimLevels, StimByStimRespRecap{i,1,3}(3,:), sum(StimByStimRespRecap{i,1,3}(2:3,:)), ...
		searchGrid, paramsFree, PF, 'searchOptions', options, 'lapseLimits',lapseLimits);
	ProportionCorrectModel = PF(paramsValues, StimLevelsFineGrain);

	plot(StimLevelsFineGrain, ProportionCorrectModel, color(i), 'linewidth',2);

	LegendContent = [LegendContent ; StimByStimRespRecap{i,2} ; blanks(length(StimByStimRespRecap{i,2})) ];
end
legend (LegendContent, 'Location', 'SouthEast')
set(gca,'ylim', [0 1])



figure(n)
n = n+1;

subplot(111)
for i=1:NbMcMovies
    C(i,:) = RespTypeRecap{1,2}(i,:)./sum(RespTypeRecap{1,2}(i,:));    
end
barh(C, 'stacked')
legend(['b'; 'd'; 'p'; 't'; ' '])
t=title ('Responses to McGurk stim after congruent block');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'ytick', 1:14 ,'yticklabel', RespTypeRecap{1,1}, 'ticklength', [0.005 0], 'fontsize',13)
axis 'tight'


% Saving the data
if (IsOctave==0)
    save (SavedMat);
else
    save ('-mat7-binary', SavedMat);
end;



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

catch
cd ..
lasterror
end
