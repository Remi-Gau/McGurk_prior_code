function AnalyseAudioDataV2

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

JustMcGurk = input('Just McGurk ? Yes : 1 ; No : 0. ');


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


McDir = 'McGurkMovies';
ConDir = 'CongMovies';
InconDir = 'IncongMovies';


McMoviesDir = strcat(pwd, filesep, McDir, filesep);
McMoviesDirList = dir(strcat(McMoviesDir,'*', MovieType));
NbMcMovies = size(McMoviesDirList,1);

CongMoviesDir = strcat(pwd, filesep, ConDir, filesep);
CongMoviesDirList = dir(strcat(CongMoviesDir,'*', MovieType)); % List the movie files in the congruent movie folder and returns a structure
NbCongMovies = size(CongMoviesDirList,1);

IncongMoviesDir = strcat(pwd, filesep, InconDir, filesep);
IncongMoviesDirList = dir(strcat(IncongMoviesDir,'*', MovieType));
NbIncongMovies = size(IncongMoviesDirList,1);


StimByStimRespRecap = cell(NbMcMovies,2,3);


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
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./200:max(StimLevels)];


NbTrials = length(TotalTrials{1,1}(:,1));

SavedMat = strcat('Results_', SubjID, '.mat');

RespRecap = repmat([ NoiseSoundRange; zeros(3, length(NoiseSoundRange)) ], [1 1 3]);


MoviesLists = cell(1,3);

for i=1:NbMcMovies
	StimByStimRespRecap{i,2,3} = McMoviesDirList(i).name(1:end-4);
	StimByStimRespRecap{i,1,3} = [ NoiseSoundRange; zeros(3, length(NoiseSoundRange)) ];
	
	RespTypeRecap{i,1,3} = McMoviesDirList(i).name(1:end-4);
	RespTypeRecap{i,2,3} = zeros(7,length(NoiseSoundRange));
	
	MoviesLists{1,3} = [MoviesLists{1,3} ; McMoviesDirList(i).name(1:end-4)];
end

MoviesLists{1,3}
	
for i=1:NbCongMovies	
	StimByStimRespRecap{i,2,1} = CongMoviesDirList(i).name(1:end-4);
	StimByStimRespRecap{i,1,1} = [ NoiseSoundRange; zeros(3, length(NoiseSoundRange)) ];
	
	RespTypeRecap{i,1,1} = CongMoviesDirList(i).name(1:end-4);
	RespTypeRecap{i,2,1} = zeros(7,length(NoiseSoundRange));
    
    MoviesLists{1,1} = [MoviesLists{1,1} ; CongMoviesDirList(i).name(1:end-4)];
end

MoviesLists{1,1}
		
for i=1:NbCongMovies	
	StimByStimRespRecap{i,2,2} = IncongMoviesDirList(i).name(1:end-4);
	StimByStimRespRecap{i,1,2} = [ NoiseSoundRange; zeros(3, length(NoiseSoundRange)) ];
	
	RespTypeRecap{i,1,2} = IncongMoviesDirList(i).name(1:end-4);
	RespTypeRecap{i,2,2} = zeros(7,length(NoiseSoundRange));
    
    MoviesLists{1,2} = [MoviesLists{1,2} ; IncongMoviesDirList(i).name(1:end-4)];
end

MoviesLists{1,2}


%--------------------------------------------- FIGURE --------------------------------------------------------
% A first quick figure to have look at the different reactions times
figure(n)
n = n+1;

scatter(TotalTrials{1,1}(:,2)*20+TotalTrials{1,1}(:,3), TotalTrials{1,1}(:,4))
ylabel 'Response Time'
set(gca,'tickdir', 'out', 'xtick', [0 20 40] ,'xticklabel', 'Congruent|Incongruent|McGurk', 'ticklength', [0.002 0], 'fontsize', 13)
axis([0 40+length(NoiseSoundRange) 0 3])

%-------------------------------------------------------------------------------------------------------------


for i=1:NbTrials

	if TotalTrials{1,1}(i,5)~=666 & TotalTrials{1,1}(i,4)>.5

		if JustMcGurk==1 & TotalTrials{1,1}(i,2)~=2
		else

			if TotalTrials{1,1}(i,2)==2
				NbMovies = NbMcMovies;
			else
				NbMovies = NbCongMovies;
			end

			for j=1:NbMovies
				if TotalTrials{2,1}(i,:)==StimByStimRespRecap{j,2,TotalTrials{1,1}(i,2)+1}		
					StimByStimRespRecap{j,1,TotalTrials{1,1}(i,2)+1}(TotalTrials{1,1}(i,6) , TotalTrials{1,1}(i,3)) = StimByStimRespRecap{j,1,TotalTrials{1,1}(i,2)+1}(TotalTrials{1,1}(i,6) , TotalTrials{1,1}(i,3)) + 1;
				end
			end

			RespRecap(TotalTrials{1,1}(i,6) ,TotalTrials{1,1}(i,3), TotalTrials{1,1}(i,2)+1) = RespRecap(TotalTrials{1,1}(i,6) ,TotalTrials{1,1}(i,3), TotalTrials{1,1}(i,2)+1) + 1;

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

			A = find( strcmp (cellstr( repmat(TotalTrials{2,1}(i,:), NbMovies, 1) ), MoviesLists{1, TotalTrials{1,1}(i,2)+1 } ) );

			RespTypeRecap{A, 2, TotalTrials{1,1}(i,2)+1}(B, TotalTrials{1,1}(i,3)) = RespTypeRecap{A, 2, TotalTrials{1,1}(i,2)+1}(B, TotalTrials{1,1}(i,3)) + 1;
		end
	end
end



% Display results

RespRecap(:,:,2)
RespRecap(:,:,3)

for i=1:NbIncongMovies
    StimByStimRespRecap{i,:,2}
end

for i=1:NbMcMovies
    StimByStimRespRecap{i,:,3}
end

Missed = length( [find(TotalTrials{1,1}(:,4)==3)' find(TotalTrials{1,1}(:,4)<0.5)'] ) / length (TotalTrials{1,1}(:,4))

% Type of response depending on stimuli

for i=1:NbMcMovies

	figure(n)
	n = n+1;
    
	for j=1:length(NoiseSoundRange)
	    C(:,j) = RespTypeRecap{i,2,3}(:,j)./sum(RespTypeRecap{i,2,3}(:,j));
	end
	bar(C', 'stacked')
	legend(['b'; 'd'; 'g'; 'k'; 'p'; 't'; ' '])
	t=title (RespTypeRecap{i,1,3});
	set(t,'fontsize',15);
    set(gca,'tickdir', 'out', 'xtick', 1:length(NoiseSoundRange) ,'xticklabel', NoiseSoundRange, 'ticklength', [0.005 0], 'fontsize',13)
	axis 'tight'

end

if JustMcGurk==0

    for i=1:NbIncongMovies

        figure(n)
        n = n+1;

        for j=1:length(NoiseSoundRange)
            C(:,j) = RespTypeRecap{i,2,2}(:,j)./sum(RespTypeRecap{i,2,2}(:,j));
        end
        bar(C', 'stacked')
        legend(['b'; 'd'; 'g'; 'k'; 'p'; 't'; ' '])
        t=title (RespTypeRecap{i,1,2});
        set(t,'fontsize',15);
        set(gca,'tickdir', 'out', 'xtick', 1:length(NoiseSoundRange) ,'xticklabel', NoiseSoundRange, 'ticklength', [0.005 0], 'fontsize',13)
        axis 'tight'

    end


    for i=1:NbCongMovies

        figure(n)
        n = n+1;

        for j=1:length(NoiseSoundRange)
            C(:,j) = RespTypeRecap{i,2,1}(:,j)./sum(RespTypeRecap{i,2,1}(:,j));
        end
        bar(C', 'stacked')
        legend(['b'; 'd'; 'g'; 'k'; 'p'; 't'; ' '])
        t=title (RespTypeRecap{i,1,1});
        set(t,'fontsize',15);
        set(gca,'tickdir', 'out', 'xtick', 1:length(NoiseSoundRange) ,'xticklabel', NoiseSoundRange, 'ticklength', [0.005 0], 'fontsize',13)
        axis 'tight'

    end

end



% Percent of response correct or McGurk response depending on intensity of
% white noise
figure(n)
n = n+1;

subplot(131)
title ('McGurk')
hold on
plot(RespRecap(1,:,3), [RespRecap(3,:,3)./sum(RespRecap(2:4,:,3))], 'k.', 'markersize', 30) 

[paramsValues LL exitflag output] = PAL_PFML_Fit(StimLevels, RespRecap(3,:,3), sum(RespRecap(2:4,:,3)), ...
	searchGrid, paramsFree, PF, 'searchOptions', options, 'lapseLimits',lapseLimits);
ProportionCorrectModel = PF(paramsValues, StimLevelsFineGrain);

plot(StimLevelsFineGrain, ProportionCorrectModel,'g-','linewidth',3);
set(gca,'ylim', [0 1])


if JustMcGurk==0

    subplot(132)
    title ('Incongruent')
    hold on
    plot(RespRecap(1,:,2), [RespRecap(3,:,2)./sum(RespRecap(2:4,:,2))], 'k.', 'markersize', 30)

    [paramsValues LL exitflag output] = PAL_PFML_Fit(StimLevels, RespRecap(3,:,2), sum(RespRecap(2:4,:,2)), ...
        searchGrid, paramsFree, PF, 'searchOptions', options, 'lapseLimits',lapseLimits);
    ProportionCorrectModel = PF(paramsValues, StimLevelsFineGrain);

    plot(StimLevelsFineGrain, ProportionCorrectModel,'g-','linewidth',3);
    set(gca,'ylim', [0 1])

    subplot(133)
    title ('Congruent')
    hold on
    plot(RespRecap(1,:,1), [RespRecap(3,:,1)./sum(RespRecap(2:4,:,1))], 'k.', 'markersize', 30)

    [paramsValues LL exitflag output] = PAL_PFML_Fit(StimLevels, RespRecap(3,:,1), sum(RespRecap(2:4,:,1)), ...
        searchGrid, paramsFree, PF, 'searchOptions', options, 'lapseLimits',lapseLimits);
    ProportionCorrectModel = PF(paramsValues, StimLevelsFineGrain);

    plot(StimLevelsFineGrain, ProportionCorrectModel,'g-','linewidth',3);
    set(gca,'ylim', [0 1])

end


% Percent of response correct or McGurk response depending on intensity of white noise
figure(n)
n = n+1;

color = ['r' 'g' 'b' 'c' 'y' 'm'];

title ('McGurk')
LegendContent = [];
hold on
for i=1:NbMcMovies
	plot(StimByStimRespRecap{i,1,3}(1,:), [StimByStimRespRecap{i,1,3}(3,:)./sum(StimByStimRespRecap{i,1,3}(2:4,:))], '.--', 'Color', color(i),'MarkerEdgeColor', color(i), 'markersize', 20)
	
	[paramsValues LL exitflag output] = PAL_PFML_Fit(StimLevels, StimByStimRespRecap{i,1,3}(3,:), sum(StimByStimRespRecap{i,1,3}(2:4,:)), ...
		searchGrid, paramsFree, PF, 'searchOptions', options, 'lapseLimits',lapseLimits);
	ProportionCorrectModel = PF(paramsValues, StimLevelsFineGrain);

	plot(StimLevelsFineGrain, ProportionCorrectModel, color(i), 'linewidth',2);
	
	LegendContent = [LegendContent ; StimByStimRespRecap{i,2,3} ; blanks(length(StimByStimRespRecap{i,2,3})) ];
end
legend (LegendContent, 'Location', 'SouthEast')
set(gca,'ylim', [0 1])




if JustMcGurk==0
    
    % Percent of response correct or INC response depending on intensity of white noise
    figure(n)
    n = n+1;
    
    title ('Incongruent')
    LegendContent = [];
    hold on
    for i=1:NbIncongMovies
        plot(StimByStimRespRecap{i,1,2}(1,:), [StimByStimRespRecap{i,1,2}(3,:)./sum(StimByStimRespRecap{i,1,2}(2:3,:))], '.--', 'Color', color(i), 'MarkerEdgeColor', color(i), 'markersize', 20)

        [paramsValues LL exitflag output] = PAL_PFML_Fit(StimLevels, StimByStimRespRecap{i,1,2}(3,:), sum(StimByStimRespRecap{i,1,2}(2:3,:)), ...
            searchGrid, paramsFree, PF, 'searchOptions', options, 'lapseLimits',lapseLimits);
        ProportionCorrectModel = PF(paramsValues, StimLevelsFineGrain);

        plot(StimLevelsFineGrain, ProportionCorrectModel, color(i), 'linewidth',2);

        LegendContent = [LegendContent ; StimByStimRespRecap{i,2,2} ; blanks(length(StimByStimRespRecap{i,2,2})) ];
    end
    legend (LegendContent, 'Location', 'SouthEast')
    set(gca,'ylim', [0 1])

    % Percent of response correct or CON response depending on intensity of white noise
    figure(n)
    n = n+1;

    title ('Congruent')
    LegendContent = [];
    hold on
    for i=1:NbCongMovies
        plot(StimByStimRespRecap{i,1,1}(1,:), [StimByStimRespRecap{i,1,1}(3,:)./sum(StimByStimRespRecap{i,1,1}(2:3,:))], '.--', 'Color', color(i), 'MarkerEdgeColor', color(i), 'markersize', 20)

        [paramsValues LL exitflag output] = PAL_PFML_Fit(StimLevels, StimByStimRespRecap{i,1,1}(3,:), sum(StimByStimRespRecap{i,1,1}(2:3,:)), ...
            searchGrid, paramsFree, PF, 'searchOptions', options, 'lapseLimits',lapseLimits);
        ProportionCorrectModel = PF(paramsValues, StimLevelsFineGrain);

        plot(StimLevelsFineGrain, ProportionCorrectModel, color(i), 'linewidth',2);

        LegendContent = [LegendContent ; StimByStimRespRecap{i,2,1} ; blanks(length(StimByStimRespRecap{i,2,1}))];
    end
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

clear A B C ans searchGrid ParOrNonPar paramsFree PF options lapseLimits McDir ConDir InconDir McMoviesDir CongMoviesDir IncongMoviesDir List SizeList i n paramsValues LL exitflag output ProportionCorrectModel StimLevelsFineGrain LegendContent color

cd ..


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
