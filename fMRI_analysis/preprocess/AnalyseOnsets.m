%%

clc
clear

SubjectsList = [1 13 14 15 24 28 32 41 48 61 66 69 73 74 82 98];

Sub_SOA = [];
Std_Sub_SOA =[];

for i=1:length(SubjectsList)

    cd (num2str(SubjectsList(i)))

    load SOT.mat

    SOA_List = [];

    for j=1:size(SOT,2)

        Onsets = reshape(SOT{3,j},8,4);

        SOA = diff(Onsets);

        SOA_List = [SOA_List ; SOA'];

    end

    Sub_SOA = [Sub_SOA ; mean(SOA_List)];
    Std_Sub_SOA = [Std_Sub_SOA ; std(SOA_List)];
    
    cd ..
    
end

[Y,I] = sort(Sub_SOA(:,1))
Sub_SOA(I,:)

mean(Sub_SOA)
std(Sub_SOA)

mean(Std_Sub_SOA)




