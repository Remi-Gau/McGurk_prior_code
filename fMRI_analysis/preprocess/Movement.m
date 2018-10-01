clc
clear

% Subject's Identity and Session number
SubjID = input('Subject''s ID? ','s');


%  Folders definitions
A = pwd;

SubjectFolder = strcat(pwd, filesep, SubjID, filesep);

NiftiSourceFolder = strcat(SubjectFolder, 'Nifti_EPI', filesep);



cd(NiftiSourceFolder)

FoldersLists = dir;

NbRuns = length(FoldersLists)-2;

for i=2:NbRuns+1
    
    fprintf('\nSession %i \n', i)
    
    cd(FoldersLists(i+1).name)
    
    RealignParametersFile = dir('*.txt');
    
    RealignParameters = load(RealignParametersFile(1).name);
    
    max(RealignParameters);
    
    min(RealignParameters);
    
    max(RealignParameters)-min(RealignParameters)
    
    mean(RealignParameters)
    
    figure(i-1)
    subplot(211)
    plot([1:length(RealignParameters(:,2))], RealignParameters(:,1), 'b',[1:length(RealignParameters(:,2))], RealignParameters(:,2), 'g',[1:length(RealignParameters(:,2))], RealignParameters(:,3), 'r')
    subplot(212)
    plot([1:length(RealignParameters(:,2))], RealignParameters(:,4), 'b',[1:length(RealignParameters(:,2))], RealignParameters(:,5), 'g',[1:length(RealignParameters(:,2))], RealignParameters(:,6), 'r')

    cd ..

end


cd(A)


