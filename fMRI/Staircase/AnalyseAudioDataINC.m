function AnalyseAudioDataINC

% TO DO :
%	- change the way the txt output is printed to facilitate analysis

% Trials{1,1}(i,:) = [j NoiseSoundLevel RT Resp RespCat];
% j			- is the trial number.
% q			- is the trial condition
% NoiseSoundLevel	- Noise level for this trial
% RT
% Resp
% RespCat	 2 --> McGurk effect did not worked; 3 --> Mc Gurk effect worked; 4 --> something else answered



clc
clear all
close all

% message = 'Parametric Bootstrap (1) or Non-Parametric Bootstrap? (2): ';
ParOrNonPar = 1; %input(message);
%Parameter grid defining parameter space through which to perform a
%brute-force search for values to be used as initial guesses in iterative
%parameter search.
searchGrid.alpha = 0:.05:1;
searchGrid.beta = logspace(1,3,100);
searchGrid.gamma = 0;  %scalar here (since fixed) but may be vector
searchGrid.lambda = 0:.05:1;  %ditto

%Threshold and Slope are free parameters, guess and lapse rate are fixed
paramsFree = [1 1 0 1];  %1: free parameter, 0: fixed parameter
 
%Fit a Logistic function
PF = @PAL_Logistic;  %Alternatives: PAL_Gumbel, PAL_Weibull, 
                     %PAL_CumulativeNormal, PAL_HyperbolicSecant

%Optional:
options = PAL_minimize('options');   %type PAL_minimize('options','help') for help
options.TolFun = 1e-09;     %increase required precision on LL
options.MaxIter = 100;
options.Display = 'off';    %suppress fminsearch messages
lapseLimits = [0 1];        %limit range for lambda
                            %(will be ignored here since lambda is not a
                            %free parameter)

% Figure counter
n=1;

MovieType = '.mov';

InconDir = 'IncongMovies';

IncongMoviesDir = strcat(pwd, filesep, InconDir, filesep);
IncongMoviesDirList = dir(strcat(IncongMoviesDir,'*', MovieType));
NbIncongMovies = size(IncongMoviesDirList,1);

StimByStimRespRecap = cell(NbIncongMovies,2);

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

NbTrials = length(TotalTrials{1,1}(:,1));

MoviesLists = [];

for i=1:NbIncongMovies
	StimByStimRespRecap{i,2} = IncongMoviesDirList(i).name(1:end-4);
    StimByStimRespRecap{i,1} = [ NoiseSoundRange(i,:) ; zeros(3, length(NoiseSoundRange(i,:))) ];
	
	RespTypeRecap{i,1} = IncongMoviesDirList(i).name(1:end-4);
    RespTypeRecap{i,2} = zeros(7,length(NoiseSoundRange(i,:)));
		
	MoviesLists = [MoviesLists ; IncongMoviesDirList(i).name(1:end-4)];
end

MoviesLists

%--------------------------------------------- FIGURE --------------------------------------------------------
% A first quick figure to have look at the different reactions times
figure(n)
n = n+1;

scatter(20+TotalTrials{1,1}(:,3)*20, TotalTrials{1,1}(:,4))
ylabel 'Response Time'
set(gca,'tickdir', 'out', 'xtick', [20] ,'xticklabel', 'Incongruent', 'ticklength', [0.002 0], 'fontsize', 13)
axis([0 40 0 3])

%-------------------------------------------------------------------------------------------------------------


for i=1:NbTrials
    

	if TotalTrials{1,1}(i,5)~=1 & TotalTrials{1,1}(i,4)>.5

		if TotalTrials{1,1}(i,2)==2

			for j=1:NbIncongMovies
                if TotalTrials{2,1}(i,:)==StimByStimRespRecap{j,2};
                    
                    NoiseLevel = find(StimByStimRespRecap{j,1}(1,:)==TotalTrials{1,1}(i,3));

                    if isempty(NoiseLevel);
                        NoiseLevel = length(StimByStimRespRecap{j,1})+1;
                        StimByStimRespRecap{j,1}(1,end+1)=TotalTrials{1,1}(i,3);
                        StimByStimRespRecap{j,1}(2:4,end)=0;
                        
                        RespTypeRecap{j, 2}(:,end+1)=0;
                    end
                    
					StimByStimRespRecap{j,1}(TotalTrials{1,1}(i,6) , NoiseLevel) = StimByStimRespRecap{j,1}(TotalTrials{1,1}(i,6) , NoiseLevel) + 1;
				end
            end

			switch KbName( TotalTrials{1,1}(i,5) ) % Check responses given
			    case RespB
			    B = 1;

			    case RespD
			    B = 2;

			    case RespG
			    B = 3;		

			    case RespK
			    B = 4;

			    case RespP
			    B = 5;

			    case RespT
			    B = 6;	

			    otherwise
			    B = 7;
            end

			% Find what stimulus was played
			A = find( strcmp (cellstr( repmat(TotalTrials{2,1}(i,:), NbIncongMovies, 1) ), cellstr(MoviesLists) ) );

			RespTypeRecap{A, 2}(B, NoiseLevel) = RespTypeRecap{A, 2}(B, NoiseLevel) + 1;
		end
	end
end


for i=1:NbIncongMovies
    
    [TEMP , OrderedIndexes] = sort(StimByStimRespRecap{i,1}(1,:));
    
    for j=1:4
        StimByStimRespRecap{i,1}(j,:)=StimByStimRespRecap{i,1}(j,OrderedIndexes);
    end
    
    for j=1:7
        RespTypeRecap{i,2}(j,:)=RespTypeRecap{i,2}(j,OrderedIndexes);
    end
    
    LimitsStimLevels{i,:} = [1 length(StimByStimRespRecap{i,1}(1,:))];
    
end


% LimitsStimLevels{1,:} = [1 10];
% LimitsStimLevels{2,:} = [1 10];
% LimitsStimLevels{3,:} = [1 10];
% LimitsStimLevels{4,:} = [1 15];
% LimitsStimLevels{5,:} = [1 15];
% LimitsStimLevels{6,:} = [1 10];
% LimitsStimLevels{7,:} = [1 10];
% LimitsStimLevels{8,:} = [1 10];



% Display results

for i=1:NbIncongMovies
    disp(StimByStimRespRecap{i,2})
    disp(StimByStimRespRecap{i,1})
end

Missed = length( [find(TotalTrials{1,1}(:,5)==666)' find(TotalTrials{1,1}(:,4)<0.5)'] ) / length (TotalTrials{1,1}(:,4))


% Type of response depending on stimuli

for i=1:NbIncongMovies

	figure(n)
	n = n+1;
    
	for j=1:length(RespTypeRecap{i,2}(1,:))
	    C(:,j) = RespTypeRecap{i,2}(:,j)./sum(RespTypeRecap{i,2}(:,j));
	end
	bar(C', 'stacked')
	legend(['b'; 'd'; 'g'; 'k'; 'p'; 't'; ' '])
	t=title (RespTypeRecap{i,1});
	set(t,'fontsize',15);
    set(gca,'tickdir', 'out', 'xtick', 1:length(RespTypeRecap{i,2}(1,:)) ,'xticklabel', StimByStimRespRecap{i,1}(1,:), 'ticklength', [0.005 0], 'fontsize',13)
	axis 'tight'

end


% Percent of response correct or McGurk response depending on intensity of white noise

color = [0 0 0; ...
         1 1 0; ...
         1 0 0; ...
         0 1 1; ...
         0 1 0; ...
         0 0 1; ...
         .5 .5 .5; ...
         .5 .5 0];
    
for i=1:NbIncongMovies
    
    figure(n)
    n = n+1;
    title (StimByStimRespRecap{i,2})
 
    hold on
    
    StimLevels = StimByStimRespRecap{i,1}(1,LimitsStimLevels{i,1}(1):LimitsStimLevels{i,1}(2));
    StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./200:max(StimLevels)];
    
	plot(StimByStimRespRecap{i,1}(1,:), [StimByStimRespRecap{i,1}(3,:)./sum(StimByStimRespRecap{i,1}(2:4,:))], '.--', 'Color', color(i,:),'MarkerEdgeColor', color(i,:), 'markersize', 20)
	
	[paramsValues LL exitflag output] = PAL_PFML_Fit(StimLevels, StimByStimRespRecap{i,1}(3,LimitsStimLevels{i,1}(1):LimitsStimLevels{i,1}(2)), sum(StimByStimRespRecap{i,1}(2:4,LimitsStimLevels{i,1}(1):LimitsStimLevels{i,1}(2))), ...
		searchGrid, paramsFree, PF, 'searchOptions', options, 'lapseLimits',lapseLimits);
	ProportionCorrectModel = PF(paramsValues, StimLevelsFineGrain);

	plot(StimLevelsFineGrain, ProportionCorrectModel, 'Color', color(i,:), 'linewidth',2);
    
	
	LegendContent = [StimByStimRespRecap{i,2} ; blanks(length(StimByStimRespRecap{i,2})) ];
    legend (LegendContent, 'Location', 'SouthEast')
    
    set(gca,'ylim', [0 1])
end




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
