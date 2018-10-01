function SOT_Compile




% Extract the stimulus onset time (SOTs) of the diferent conditions
% The other is for the non parametric version
% One is for the parametric version


clc
clear all
close all

cd Behavioral

List = dir ('Subject_*.mat');
SizeList = size(List,1);

NbBlockType = 2;
NbRegressorPerBlocType = 3;


% cell(Block_Type_Before, Trial_Position, Block_Type, Run_Number)
SOT = cell(NbRegressorPerBlocType, NbBlockType, SizeList);
% Collects the SOTs
for i=1:SizeList
	
    load(List(i).name);
    
    SOT (3, 1, i)= Trials{6,1}(find(Trials{1,1}(:,5)==0));
    SOT (3, 2, i)= Trials{6,1}(find(Trials{1,1}(:,5)==1));
    
    for j=1:length(Trials{1,1}) 
            if Trials{1,1}(j,4)==2
                SOT{2, Trials{1,1}(j,4)+1, i}(end+1) = Trials{6,1}(j,1);
            end
            
            if Trials{1,1}(j,2)==1
                SOT{1, Trials{1,1}(j,4)+1, i}(end+1) = Trials{6,1}(j,1);
            end
	end	
end;

cd ..

save ('SOT')


return
