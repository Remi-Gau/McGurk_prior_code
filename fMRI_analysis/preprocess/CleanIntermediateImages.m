clc
clear


% Subject's Identity and Session number
SubjID = input('Subject''s ID? ','s');


%  Folders definitions
StartFolder = pwd;

SubjectFolder = strcat(pwd, filesep, SubjID, filesep);

% NiftiSourceFolder = strcat(SubjectFolder, 'Nifti_EPI', filesep);
NiftiSourceFolder = strcat(SubjectFolder, 'Nifti_EPI_Despiked', filesep);

cd(NiftiSourceFolder)


List = dir;

NbRuns = length(List)-2;

for i=3:length(List)
    
    i-2

	cd(List(i).name)

% 	delete('f*.img')
% 	delete('f*.hdr')

	delete('g*.img')
	delete('g*.hdr')

% 	delete('u*.img')
% 	delete('u*.hdr')
 
% 	delete('a*.img')
% 	delete('a*.hdr')
 
% 	delete('w*.img')
% 	delete('w*.hdr')

	cd ..

end

cd(StartFolder)
