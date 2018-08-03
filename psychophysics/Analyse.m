function Analyse

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
%	- add a way to analyze just one trial

clc
clear all
close all

KbName('UnifyKeyNames');


% Figure counter
n=1;


cd Subjects_Data


try

List = dir ('Subject*.mat');
% List = dir ('*.mat');

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
	NoiseRange = zeros(1, NbMcMovies);
end


%--------------------------------------------- FIGURE --------------------------------------------------------
% A first quick figure to have look at the different reactions times
figure(n)
n = n+1;

scatter(15*TotalTrials{1,1}(:,4)+TotalTrials{1,1}(:,2) , TotalTrials{1,1}(:,5))
xlabel 'Trial Number'
ylabel 'Response Time'
set(gca,'tickdir', 'out', 'xtick', [1 16 31] ,'xticklabel', 'Congruent|Incongruent|McGurk', 'ticklength', [0.002 0], 'fontsize', 13)
axis 'tight'
set(gca,'ylim', [0 3])


%------------------------------------------------------------------------------------------------------------------


StimByStimRespRecap = cell(1,2,3);

for i=1:NbMcMovies
	StimByStimRespRecap{1,1,3}(i,:) = McMoviesDirList(i).name(1:end-4);
	StimByStimRespRecap{1,2,3} = zeros(i,7,BlockLength,NbBlockType);
end

for i=1:NbIncongMovies
	StimByStimRespRecap{1,1,1}(i,:) = CongMoviesDirList(i).name(1:end-4); % Which stimuli
	StimByStimRespRecap{1,2,1} = zeros(i,7,BlockLength,NbBlockType); % What answers

	StimByStimRespRecap{1,1,2}(i,:) = IncongMoviesDirList(i).name(1:end-4);
	StimByStimRespRecap{1,2,2} = zeros(i,7,BlockLength,NbBlockType);
end


ReactionTimesCell = cell(3, BlockLength, 2, NbBlockType);


ResponsesCell = cell(3, NbBlockType);
for i=1:NbBlockType*3
	ResponsesCell{i}=zeros(2,BlockLength);
end


PriorResponse=zeros(2,16,2);


for i=1:NbTrials
    
	if TotalTrials{1,1}(i,5)>0.5 & TotalTrials{1,1}(i,5)<2 % Skips trials where answer came after responses window or with impossible RT (negative or before the beginning of the movie)
		
		Context = TotalTrials{1,1}(i,3); % What block we are in
				
		TrialType = TotalTrials{1,1}(i,4); % What type of trial this is
				
		if TotalTrials{1,1}(i,7)==1
			switch TrialType
				case 0
					RightResp = 1;
				case 1
					RightResp = 1;
				case 2
					RightResp = 2;
			end
		else 
			switch TrialType
				case 0
					RightResp = 2;
				case 1
					RightResp = 2;
				case 2
					RightResp = 1;
			end	
        end
		
        
		
		if TrialType==2	
			
            From = TotalTrials{1,1}(i-1,4);
            GoingBack = 1;
            
            while TotalTrials{1,1}(i-GoingBack,4)==From
                GoingBack=GoingBack+1;
                
                if GoingBack==i
                    break
                end
                
            end
					
			PriorResponse(RightResp,GoingBack-1,Context+1)=PriorResponse(RightResp,GoingBack-1,Context+1)+1;
			
		end
		
		
			
			
		
		RT = TotalTrials{1,1}(i,5);
				
		switch KbName( TotalTrials{1,1}(i,6) ) % Check responses given
			case RespB
			Resp = 1;

			case RespD
			Resp = 2;

			case RespG
			Resp = 3;
			
			case RespK
			Resp = 4;
			
			case RespP
			Resp = 5;

			case RespT
			Resp = 6;	

			otherwise
			Resp = 7;
		end
		
		switch TrialType
			case 0
				WhichStim = find( strcmp (cellstr( repmat(TotalTrials{2,1}(i,:), NbCongMovies, 1) ), StimByStimRespRecap{1,1,TrialType+1}) );
			case 1
				WhichStim = find( strcmp (cellstr( repmat(TotalTrials{2,1}(i,:), NbIncongMovies, 1) ), StimByStimRespRecap{1,1,TrialType+1}) );
			case 2
				WhichStim = find( strcmp (cellstr( repmat(TotalTrials{2,1}(i,:), NbMcMovies, 1) ), StimByStimRespRecap{1,1,TrialType+1}) );
		end
		
	
		if TotalTrials{1,1}(i,7)~=999
			ResponsesCell{TrialType+1,Context+1}(RightResp, TotalTrials{1,1}(i,2)) = ResponsesCell{TrialType+1,Context+1}(RightResp, TotalTrials{1,1}(i,2)) + 1;
		end
			
		StimByStimRespRecap{1,2,TrialType+1}(WhichStim,Resp,TotalTrials{1,1}(i,2),Context+1) = StimByStimRespRecap{1,2,TrialType+1}(WhichStim,Resp,TotalTrials{1,1}(i,2),Context+1) + 1;
		
		if TotalTrials{1,1}(i,5)~=999
			ReactionTimesCell{TrialType+1, TotalTrials{1,1}(i,2), RightResp, Context+1} = [ReactionTimesCell{TrialType+1, TotalTrials{1,1}(i,2), RightResp, Context+1} RT];
		end
		
	end
end


clear TrialType Context RT RightResp i WhichStim Resp



Missed = length( [find(TotalTrials{1,1}(:,5)>2)' find(TotalTrials{1,1}(:,5)<0.5)'] ) / length (TotalTrials{1,1}(:,5))



MedianReactionTimes = cell(3, BlockLength, 2, NbBlockType);

for i=1:3*BlockLength*2*NbBlockType
	MedianReactionTimes{i} = median(ReactionTimesCell{i});
end




McGURKinCON_Correct = sum(ResponsesCell{3,1}(1,:))/sum(sum(ResponsesCell{3,1}(1:2,:)))
disp(ResponsesCell{3,1}(1,:)./sum(ResponsesCell{3,1}(1:2,:)))

McGURKinINC_Correct = sum(ResponsesCell{3,2}(1,:))/sum(sum(ResponsesCell{3,2}(1:2,:)))
disp(ResponsesCell{3,2}(1,:)./sum(ResponsesCell{3,2}(1:2,:)))



INCinINC_Correct = sum(ResponsesCell{2,2}(1,:))/sum(sum(ResponsesCell{2,2}(1:2,:)))
disp(ResponsesCell{2,2}(1,:)./sum(ResponsesCell{2,2}(1:2,:)))

INCinCON_Correct = sum(ResponsesCell{2,1}(1,:))/sum(sum(ResponsesCell{2,1}(1:2,:)))
disp(ResponsesCell{2,1}(1,:)./sum(ResponsesCell{2,1}(1:2,:)))



CONinCON_Correct = sum(ResponsesCell{1,1}(1,:))/sum(sum(ResponsesCell{1,1}(1:2,:)))
disp(ResponsesCell{1,1}(1,:)./sum(ResponsesCell{1,1}(1:2,:)))

CONinINC_Correct = sum(ResponsesCell{1,2}(1,:))/sum(sum(ResponsesCell{1,2}(1:2,:)))
disp(ResponsesCell{1,2}(1,:)./sum(ResponsesCell{1,2}(1:2,:)))


PriorResponse


%--------------------------------------------- FIGURE --------------------------------------------------------
figure(n)
n=n+1;


% Plots histograms for % correct for all the McGurk trials
hold on
bar([1], [ McGURKinCON_Correct ], 'g' )
bar([2], [ McGURKinINC_Correct ], 'r' )
errorbar([1], McGURKinCON_Correct, [std(ResponsesCell{3,1}(1,3:end)./sum(ResponsesCell{3,1}(1:2,3:end)))], 'k')
errorbar([2], McGURKinINC_Correct, [std(ResponsesCell{3,2}(1,3:end)./sum(ResponsesCell{3,2}(1:2,3:end)))], 'k')
t=title ('McGurk');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:2 ,'xticklabel', ['In a CON Block';'In a INC Block'], 'ticklength', [0.005 0], 'fontsize', 13);
legend(['In a CON Block';'In a INC Block'], 'Location', 'SouthEast')
axis([0.5 2.5 0 1])



figure(n)
n=n+1;

% Plots histograms for % correct for all the McGurk trials
hold on
plot([ResponsesCell{3,1}(1,:)./sum(ResponsesCell{3,1}(1:2,:))], 'g')
plot([ResponsesCell{3,2}(1,:)./sum(ResponsesCell{3,2}(1:2,:))], 'r')
t=title ('McGurk');
set(t,'fontsize',15);
axis('tight')
set(gca,'tickdir', 'out', 'xtick', 1:max(BlockLength) ,'xticklabel', 1:max(BlockLength), 'ticklength', [0.005 0], 'fontsize', 13, 'ylim', [0 1]);
legend(['In a CON Block';'In a INC Block'], 'Location', 'SouthEast')



figure(n)
n=n+1;

% Plots histograms for % correct for all the CON trials
subplot(211)
bar([ResponsesCell{1,1}(1,:)./sum(ResponsesCell{1,1}(1:2,:)) ], 0.7)
t=title ('Congruent');
ylabel 'In a CON Block';
set(t,'fontsize',15);
axis('tight')
set(gca,'tickdir', 'out', 'xtick', 1:max(BlockLength) ,'xticklabel', 1:max(BlockLength), 'ticklength', [0.005 0], 'fontsize', 13, 'ylim', [0 1]);

subplot(212)
bar([ResponsesCell{1,2}(1,:)./sum(ResponsesCell{1,2}(1:2,:)) ], 0.7)
ylabel 'In a INC Block';
set(t,'fontsize',15);
axis('tight')
set(gca,'tickdir', 'out', 'xtick', 1:max(BlockLength) ,'xticklabel', 1:max(BlockLength), 'ticklength', [0.005 0], 'fontsize', 13, 'ylim', [0 1]);



figure(n)
n=n+1;

% Plots histograms for % correct for all the INC trials
subplot(211)
bar([ResponsesCell{2,2}(1,:)./sum(ResponsesCell{2,2}(1:2,:)) ], 0.7)
t=title ('Incongruent');
ylabel 'In a INC Block';
set(t,'fontsize',15);
axis('tight')
set(gca,'tickdir', 'out', 'xtick', 1:max(BlockLength) ,'xticklabel', 1:max(BlockLength), 'ticklength', [0.005 0], 'fontsize', 13, 'ylim', [0 1]);

subplot(212)
bar([ResponsesCell{2,1}(1,:)./sum(ResponsesCell{2,1}(1:2,:)) ], 0.7)
ylabel 'In a CON Block';
set(t,'fontsize',15);
axis('tight')
set(gca,'tickdir', 'out', 'xtick', 1:max(BlockLength) ,'xticklabel', 1:max(BlockLength), 'ticklength', [0.005 0], 'fontsize', 13, 'ylim', [0 1]);




MedianReactionTimes = cell2mat(MedianReactionTimes);

for i=1:max(BlockLength)
	RT_McGURK_OK_inCON(i) = MedianReactionTimes(3,i,1,1);
	RT_McGURK_OK_inINC(i) = MedianReactionTimes(3,i,1,2);

	RT_McGURK_NO_inCON(i) = MedianReactionTimes(3,i,2,1);
	RT_McGURK_NO_inINC(i) = MedianReactionTimes(3,i,2,2);
	
	RT_CONinCON(i) = MedianReactionTimes(1,i,1,1);
	RT_CONinINC(i) = MedianReactionTimes(1,i,1,2);
	
	RT_INCinINC(i) = MedianReactionTimes(2,i,1,2);
	RT_INCinCON(i) = MedianReactionTimes(2,i,1,1);

end



%--------------------------------------------- FIGURE --------------------------------------------------------
figure(n)
n=n+1;

subplot (121)
% Plot median of RT of INC
plot(1:BlockLength, RT_INCinINC, 'r', 1:BlockLength, RT_INCinCON, 'g')
t=title ('RT Incongruent');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:max(BlockLength) ,'xticklabel', 1:max(BlockLength), 'ticklength', [0.005 0], 'fontsize', 13);
legend(['In a INC Block';'In a CON Block'], 'Location', 'NorthEast')
axis([1 max(BlockLength) .4 2])

subplot (122)
% Plot median of RT of CON
plot(1:BlockLength, RT_CONinCON, 'r', 1:BlockLength, RT_CONinINC, 'g')
t=title ('RT Congruent');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:max(BlockLength) ,'xticklabel', 1:max(BlockLength), 'ticklength', [0.005 0], 'fontsize', 13);
legend(['In a CON Block';'In a INC Block'], 'Location', 'NorthEast')
axis([1 max(BlockLength) .4 2])



figure(n)
n=n+1;

% Plot median of RT of McGurk
subplot (121)
plot(1:BlockLength, RT_McGURK_OK_inCON, 'r', 1:BlockLength, RT_McGURK_OK_inINC, 'g')
t=title ('RT McGurk answers');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:max(BlockLength) ,'xticklabel', 1:max(BlockLength), 'ticklength', [0.005 0], 'fontsize', 13);
legend(['In a CON Block';'In a INC Block'], 'Location', 'NorthEast')
axis([1 max(BlockLength) .4 2])

subplot (122)
plot(1:BlockLength, RT_McGURK_NO_inCON, 'r', 1:BlockLength, RT_McGURK_NO_inINC, 'g')
t=title ('RT non McGurk answers');
set(t,'fontsize',15);
set(gca,'tickdir', 'out', 'xtick', 1:max(BlockLength) ,'xticklabel', 1:max(BlockLength), 'ticklength', [0.005 0], 'fontsize', 13);
legend(['In a CON Block';'In a INC Block'], 'Location', 'NorthEast')
axis([1 max(BlockLength) .4 2])


% StimByStimRespRecap{1,2,TrialType+1}(WhichStim,Resp,TotalTrials{1,1}(i,2),Context+1)

figure(n)
n = n+1;

for j=1:NbMcMovies

    subplot (2,2,j)

    for i=1:max(BlockLength)
        Temp = StimByStimRespRecap{1,2,3}(j,:,i,1);
        G (i,:) = Temp/sum(Temp);
    end

    bar(G, 'stacked')
    
    t=title (StimByStimRespRecap{1,1,3}(j,:));
    set(t,'fontsize',15);
    set(gca,'tickdir', 'out', 'xtick', 1:max(BlockLength) ,'xticklabel', 1:max(BlockLength), 'ticklength', [0.005 0], 'fontsize', 13)
    axis 'tight'

end

for j=1:NbMcMovies

    subplot (2,2,j+NbMcMovies)

    for i=1:max(BlockLength)
        Temp = StimByStimRespRecap{1,2,3}(j,:,i,2);
        G (i,:) = Temp/sum(Temp);
    end

    bar(G, 'stacked')
    
    set(t,'fontsize',15);
    set(gca,'tickdir', 'out', 'xtick', 1:max(BlockLength) ,'xticklabel', 1:max(BlockLength), 'ticklength', [0.005 0], 'fontsize', 13)
    axis 'tight'

end

legend(['b'; 'd'; 'g'; 'k'; 'p'; 't'; ' '])

subplot (2,2,1)
ylabel 'After CON';

subplot (2,2,3)
ylabel 'After INC';



%--------------------------------------------- PRINTING & SAVING --------------------------------------------------------
if (IsOctave==0)

	figure(1) 
	print(gcf, 'Figures.ps', '-dpsc2'); % Print figures in ps format
	for i=2:(n-1)
		figure(i)
		print(gcf, 'Figures.ps', '-dpsc2', '-append'); 
	end
    
	for i=1:(n-1)
		figure(i)
		print(gcf, strcat('Fig', num2str(i) ,'.eps'), '-depsc'); % Print figures in vector format
	end

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


clear G Color i n List Trials legend t Temp X Y

SavedMat = strcat('Results_', SubjID, '.mat');

% Saving the data
if (IsOctave==0)
    save (SavedMat);
else
    save ('-mat7-binary', SavedMat);
end;




SavedTxt = strcat('Results_', SubjID, '.csv');
fid = fopen (SavedTxt, 'w');


fprintf (fid, 'SUBJECT, %s\n\n', SubjID);

fprintf (fid, 'Length of the different condition blocks\n');
fprintf (fid, 'Congruent, %i\n', BlockLength(1,:)');
fprintf (fid, 'Incongruent, %i\n', BlockLength(1,:)');
fprintf (fid, 'McGurk, %i\n\n', BlockLength(1,:)');


fprintf (fid, '\nNoise level for the different McGurk stimuli\n');
for i=1:NbMcMovies
	fprintf (fid, '%s, %6.2f\n', StimByStimRespRecap{1,1,3}(i,:), NoiseRange(3,i) );
end

fprintf (fid, '\nNoise level for the different incongruent stimuli\n');
for i=1:NbIncongMovies
	fprintf (fid, '%s, %6.2f\n', StimByStimRespRecap{1,1,2}(i,:), NoiseRange(2,i) );
end

fprintf (fid, '\nNoise level for the different congruent stimuli\n');
for i=1:NbCongMovies
	fprintf (fid, '%s, %6.2f\n', StimByStimRespRecap{1,1,1}(i,:), NoiseRange(1,i) );
end


fprintf (fid, '\nTotal number of trials, %i\n\n', sum(sum(cell2mat(ResponsesCell))) );



fclose (fid);

cd ..

return



ResponsesMat=cell2mat(ResponsesCell);

fprintf (fid, '\nRESPONSES,Correct (Percent.),Total\n');
fprintf (fid, 'Congruent, %6.4f, %i\n', sum(sum(ResponsesMat([1 3 5],1:BlockLength)))/sum(sum(ResponsesMat(:,1:BlockLength))), sum(sum(ResponsesMat(:,1:BlockLength))) );
fprintf (fid, 'Incongruent, %6.4f, %i\n\n', sum(sum(ResponsesMat([1 3 5],BlockLength+1:2*BlockLength)))/sum(sum(ResponsesMat(:,BlockLength+1:2*BlockLength))), sum(sum(ResponsesMat(:,BlockLength+1:2*BlockLength))) );








fprintf (fid,'Responses for INCONGRENT stimuli,b,d,g,k,p,t,Other\n');
for i=1:NbINCMovies
	fprintf (fid, '%s,' , StimByStimINCRespRecap{1,1}(i,:) ); fprintf (fid, '%6.2f,' , StimByStimINCRespRecap{1,2}(i,:) );
	fprintf (fid, '\n');
end


fprintf (fid, '\nREACTION TIMES,Median,STD\n');
fprintf (fid, 'Congruent,%6.3f,%6.3f\n', MeanAllCongruentRT, SDAllCongruentRT);
fprintf (fid, 'Incongruent,%6.3f,%6.3f\n', MeanAllIncongruentRT, SDAllIncongruentRT);

for i=1:max(BlockLength(1,:))
	A(i)=length(RTBlockCON{1,i,1});
end
fprintf (fid, '\nCONGRUENT\n');
fprintf (fid, 'After incongruent,'); fprintf (fid, '%i,', 1:max(AllCongruent(:,2)) );
fprintf (fid, '\nMean,'); fprintf (fid, '%6.3f,', ResultsRTBlockCON(1,:,1) );
fprintf (fid, '\nSTD,'); fprintf (fid, '%6.3f,', ResultsRTBlockCON(2,:,1) );
fprintf (fid, '\nn,'); fprintf (fid, '%i,', A );


for i=1:max(BlockLength(1,:))
	A(i)=length(RTBlockCON{1,i,2});
end		
fprintf (fid, '\n\nAfter McGurk,'); fprintf (fid, '%i,', 1:max(AllCongruent(:,2)) );
fprintf (fid, '\nMean,'); fprintf (fid, '%6.3f,', ResultsRTBlockCON(1,:,2) );
fprintf (fid, '\nSTD,'); fprintf (fid, '%6.3f,', ResultsRTBlockCON(2,:,2) );
fprintf (fid, '\nn,'); fprintf (fid, '%i,', A );


for i=1:max(BlockLength(1,:))
	A(i)=length(RTBlockINC{1,i,1});
end
fprintf (fid, '\n\nINCONGRUENT\n');
fprintf (fid, 'After congruent,'); fprintf (fid, '%i,', 1:max(AllIncongruent(:,2)) );
fprintf (fid, '\nMean,'); fprintf (fid, '%6.3f,', ResultsRTBlockINC(1,:,1) );
fprintf (fid, '\nSTD,'); fprintf (fid, '%6.3f,', ResultsRTBlockINC(2,:,1) );
fprintf (fid, '\nn,'); fprintf (fid, '%i,', A );

for i=1:max(BlockLength(1,:))
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

B = ['X' ; num2str(BlockLength(1,:)')];
for j=1:length(BlockLength(1,:))+1
	fprintf (fid, 'After %s CONGRUENT trials', B(j) );
	fprintf (fid, '\nTrial number,') ; fprintf (fid, '%i,' , 1:MaxBlockLengthMAC);
	%fprintf (fid, '\nMcGurk,') ; fprintf (fid, '%6.4f,' , RespBlockMAC(1,:,j));
	fprintf (fid, '\nMcGurk (Percent.),') ; fprintf (fid, '%6.4f,' , RespBlockMAC(4,:,j));
	fprintf (fid, '\nOther,') ; fprintf (fid, '%i,' , RespBlockMAC(3,:,j));
	fprintf (fid, '\nTotal,') ; fprintf (fid, '%i,' , sum(RespBlockMAC(1:2,:,j)) );
	fprintf (fid, '\n\n');
end

fprintf (fid,'Responses stimulus per stimulus,b,d,g,k,p,t,Other\n');
for i=1:NbINCMovies
	fprintf (fid, '%s,' , StimByStimMACRespRecap{1,1}(i,:) ); fprintf (fid, '%6.2f,' , StimByStimMACRespRecap{1,2}(i,:) );
	fprintf (fid, '\n');
end


fprintf (fid, '\n\nAfter an INCONGRUENT block \n\n');
B = ['X' ; num2str(BlockLength(1,:)')];
for j=1:length(BlockLength(1,:))+1
	fprintf (fid, 'After %s INCONGRUENT trials', B(j) );
	fprintf (fid, '\nTrial number,') ; fprintf (fid, '%i,' , 1:MaxBlockLengthMAI);
	%fprintf (fid, '\nMcGurk,') ; fprintf (fid, '%6.4f,' , RespBlockMAI(1,:,j));
	fprintf (fid, '\nMcGurk (Percent.),') ; fprintf (fid, '%6.4f,' , RespBlockMAI(4,:,j));
	fprintf (fid, '\nOther,') ; fprintf (fid, '%i,' , RespBlockMAI(3,:,j));
	fprintf (fid, '\nTotal,') ; fprintf (fid, '%i,' , sum(RespBlockMAI(1:2,:,j)) );
	fprintf (fid, '\n\n');
end

fprintf (fid,'Responses stimulus per stimulus,b,d,g,k,p,t,Other\n');
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












catch
cd ..
lasterror
end
