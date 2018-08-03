function AnalyseWithoutCompiling

%

% Returns a {5,1,rMAX} cell where rMAX is the total number of run

% {1,1} contains the trial number and the type of stimuli presented on this trial
% Trials(i,1:5) = [i p Choice n m RT Resp RespCat];
% i		 is the trial number
% p		 is the trial number in the current block
% TrialOnset
% BlockType
% Choice	 contains the type of stimuli presented on this trial : 0--> Congruent, 1--> Incongruent, 2--> Counterphase.
% RT
% Resp
% RespCat	 For Congruent trials : 1 --> Hit; 0 --> Miss // For Incongruent trials : 1 --> Hit; 0 --> Miss // For McGurk trials : 0 --> McGurk effect worked; 0 --> Miss


% {2,1} contains the name of the stim used
% {3,1} contains the level of noise used for this stimuli
% {4,1} contains the absolute path of the corresponding movie to be played
% {5,1} contains the absolute path of the corresponding sound to be played


clc
clear all
close all

KbName('UnifyKeyNames');


% Figure counter
n=1;


cd Subjects_Data


try

ResultsFilesList = dir ('Results*.mat');
SizeList = size(ResultsFilesList,1);

% Compile all the trials of all the runs
load(ResultsFilesList(1).name);


NbTrials = length(TotalTrials{1,1}(:,1));

if exist('NoiseRange')==0
	NoiseRange = zeros(1, NbMcMovies);
end


%--------------------------------------------- FIGURE --------------------------------------------------------
% A first quick figure to have look at the different reactions times
figure(n)
n = n+1;

scatter(15*TotalTrials{1,1}(:,5)+TotalTrials{1,1}(:,2) , TotalTrials{1,1}(:,6))
xlabel 'Trial Number'
ylabel 'Response Time'
set(gca,'tickdir', 'out', 'xtick', [1 16 31] ,'xticklabel', 'Congruent|Incongruent|McGurk', 'ticklength', [0.002 0], 'fontsize', 13)
axis 'tight'
set(gca,'ylim', [-.5 4])


%------------------------------------------------------------------------------------------------------------------


Missed = length( [find(TotalTrials{1,1}(:,7)==999)'] ) / length (TotalTrials{1,1}(:,6))



MedianReactionTimes = cell(3, NbTrialsPerBlock, 2, NbBlockType);

for i=1:3*NbTrialsPerBlock*2*NbBlockType
	MedianReactionTimes{i} = median(ReactionTimesCell{i});
end




McGURKinCON_Correct = sum(ResponsesCell{3,1}(1,:))/sum(sum(ResponsesCell{3,1}(1:2,:)))
%disp(ResponsesCell{3,1}(1,:)./sum(ResponsesCell{3,1}(1:2,:)))

McGURKinINC_Correct = sum(ResponsesCell{3,2}(1,:))/sum(sum(ResponsesCell{3,2}(1:2,:)))
%disp(ResponsesCell{3,2}(1,:)./sum(ResponsesCell{3,2}(1:2,:)))

for i=1:NbMcMovies
    disp(McGurkStimByStimRespRecap{i,1})
    disp(McGurkStimByStimRespRecap{i,2}(:,1)./sum(McGurkStimByStimRespRecap{i,2},2))
end



INCinINC_Correct = sum(ResponsesCell{2,2}(1,:))/sum(sum(ResponsesCell{2,2}(1:2,:)))
%disp(ResponsesCell{2,2}(1,:)./sum(ResponsesCell{2,2}(1:2,:)))



CONinCON_Correct = sum(ResponsesCell{1,1}(1,:))/sum(sum(ResponsesCell{1,1}(1:2,:)))
%disp(ResponsesCell{1,1}(1,:)./sum(ResponsesCell{1,1}(1:2,:)))



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
set(gca,'tickdir', 'out', 'xtick', 1:max(NbTrialsPerBlock) ,'xticklabel', 1:max(NbTrialsPerBlock), 'ticklength', [0.005 0], 'fontsize', 13, 'ylim', [0 1]);
legend(['In a CON Block';'In a INC Block'], 'Location', 'SouthEast')





MedianReactionTimes = cell2mat(MedianReactionTimes);

RT_McGURK_OK_inCON_TOTAL = [];
RT_McGURK_OK_inINC_TOTAL = [];
RT_McGURK_NO_inCON_TOTAL = [];
RT_McGURK_NO_inINC_TOTAL = [];

for i=1:max(NbTrialsPerBlock)
	RT_McGURK_OK_inCON(i) = MedianReactionTimes(3,i,1,1);
    RT_McGURK_OK_inCON_TOTAL = [RT_McGURK_OK_inCON_TOTAL ReactionTimesCell{3,i,1,1}];
    
	RT_McGURK_OK_inINC(i) = MedianReactionTimes(3,i,1,2);
    RT_McGURK_OK_inINC_TOTAL = [RT_McGURK_OK_inINC_TOTAL ReactionTimesCell{3,i,1,2}];

	RT_McGURK_NO_inCON(i) = MedianReactionTimes(3,i,2,1);
    RT_McGURK_NO_inCON_TOTAL = [RT_McGURK_NO_inCON_TOTAL ReactionTimesCell{3,i,2,1}];
    
	RT_McGURK_NO_inINC(i) = MedianReactionTimes(3,i,2,2);
    RT_McGURK_NO_inINC_TOTAL = [RT_McGURK_NO_inINC_TOTAL ReactionTimesCell{3,i,2,2}];
	
	RT_CONinCON(i) = MedianReactionTimes(1,i,1,1);
	RT_CON = [RT_CON ReactionTimesCell{1,i,1,1}];
		
	RT_INCinINC(i) = MedianReactionTimes(2,i,1,2);
	RT_INC = [RT_INC ReactionTimesCell{2,i,1,2}];
end

RT_CON = median(RT_CON)
RT_INC = median(RT_INC)


RT_McGURK_OK_inCON_TOTAL = nanmedian(RT_McGURK_OK_inCON_TOTAL)
RT_McGURK_OK_inINC_TOTAL = nanmedian(RT_McGURK_OK_inINC_TOTAL)
RT_McGURK_NO_inCON_TOTAL = nanmedian(RT_McGURK_NO_inCON_TOTAL)
RT_McGURK_NO_inINC_TOTAL = nanmedian(RT_McGURK_NO_inINC_TOTAL)
 



figure(n)
n = n+1;

for j=1:NbMcMovies

    subplot (2,4,j)

    for i=1:max(NbTrialsPerBlock)
        Temp = StimByStimRespRecap{1,2,3}(j,:,i,1);
        G (i,:) = Temp/sum(Temp);
    end

    bar(G, 'stacked')
    
    t=title (StimByStimRespRecap{1,1,3}(j,:));
    set(t,'fontsize',15);
    set(gca,'tickdir', 'out', 'xtick', 1:max(NbTrialsPerBlock) ,'xticklabel', 1:max(NbTrialsPerBlock), 'ticklength', [0.005 0], 'fontsize', 13)
    axis 'tight'

end

for j=1:NbMcMovies

    subplot (2,4,j+NbMcMovies)

    for i=1:max(NbTrialsPerBlock)
        Temp = StimByStimRespRecap{1,2,3}(j,:,i,2);
        G (i,:) = Temp/sum(Temp);
    end

    bar(G, 'stacked')
    
    set(t,'fontsize',15);
    set(gca,'tickdir', 'out', 'xtick', 1:max(NbTrialsPerBlock) ,'xticklabel', 1:max(NbTrialsPerBlock), 'ticklength', [0.005 0], 'fontsize', 13)
    axis 'tight'

end

legend(['b'; 'd'; 'g'; 'k'; 'p'; 't'; ' '])

subplot (2,4,1)
ylabel 'After CON';

subplot (2,4,5)
ylabel 'After INC';








SavedTxt = strcat('Results_', SubjID, '.csv');
fid = fopen (SavedTxt, 'w');


fprintf (fid, 'SUBJECT, %s\n\n', SubjID);

fprintf (fid, 'Length of the different condition blocks\n');
fprintf (fid, 'Congruent, %i\n', NbTrialsPerBlock(1,:)');
fprintf (fid, 'Incongruent, %i\n', NbTrialsPerBlock(1,:)');
fprintf (fid, 'McGurk, %i\n\n', NbTrialsPerBlock(1,:)');


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

catch
cd ..
lasterror
end


























