
%%
clc
clear



%% Define folder
% data_path = 'C:\data\path-to-data';
data_path = spm_select(1,'dir','Select the attention data directory');

cd(data_path)



%% Working directory (useful for .ps outputs only)

clear jobs
jobs{1}.util{1}.cdir.directory = pwd;
spm_jobman('run',jobs);



%% Lists the contrasts
ContrastsList = dir('con*.img');



%% Display the contrast results
load SPM

for i=1:length(ContrastsList)   
    clear jobs
    jobs{1}.stats{1}.results.spmmat = cellstr(fullfile(data_path,'SPM.mat'));
    jobs{1}.stats{1}.results.conspec(1).titlestr = SPM.xCon(1,i).name;
    jobs{1}.stats{1}.results.conspec(1).contrasts = i;
    jobs{1}.stats{1}.results.conspec(1).threshdesc = 'none';
    jobs{1}.stats{1}.results.conspec(1).thresh = 0.01;
    jobs{1}.stats{1}.results.conspec(1).extent = 0;
    jobs{1}.stats{1}.results.print = 1;
    spm_jobman('run',jobs);
end



%%
for i=1:length(ContrastsList) 
    disp(strcat(num2str(i),'_-->_', SPM.xCon(1,i).name))
end

i=input('Choose a contrast. ');

clear jobs
jobs{1}.stats{1}.results.spmmat = cellstr(fullfile(data_path,'SPM.mat'));
jobs{1}.stats{1}.results.conspec(1).titlestr = SPM.xCon(1,i).name;
jobs{1}.stats{1}.results.conspec(1).contrasts = i;
jobs{1}.stats{1}.results.conspec(1).threshdesc = 'none';
jobs{1}.stats{1}.results.conspec(1).thresh = 0.01;
jobs{1}.stats{1}.results.conspec(1).extent = 0;
jobs{1}.stats{1}.results.print = 1;
spm_jobman('run',jobs);



%% Print a csv files of the results
% =========================================================================
%
% =========================================================================

Results_file = strcat('Results_file_', xSPM.title,'SVC_ROI_Werner_JoN_2010_.csv');

fid = fopen (Results_file, 'w');

fprintf (fid, '%s', xSPM.title);
fprintf (fid, '\n\n');

fprintf (fid, '%s', TabDat.tit);
fprintf (fid, '\n\n');

fprintf (fid, TabDat.ftr{6,1}, TabDat.ftr{6,2});
fprintf (fid, '\n\n');

fprintf (fid, 'Cluster forming threshold = %s;', xSPM.thresDesc);
fprintf (fid, '\n\n');

fprintf (fid, 'Minimum cluster size %i;', xSPM.k);
fprintf (fid, '\n\n');

fprintf (fid, 'Smoothness (FWHM in mm);');
fprintf (fid, '%6.3f;', xSPM.FWHM .* xSPM.VOX);
fprintf (fid, '\n\n');

fprintf (fid, 'Resel count %6.3f;', TabDat.ftr{8,2}(3));
fprintf (fid, '\n\n');

fprintf (fid, 'Voxel count %6.3f;', TabDat.ftr{8,2}(2));
fprintf (fid, '\n\n');

fprintf (fid, '\n');



%% Print the header
for i=1:size(TabDat.hdr,1)-1
    for j=1:size(TabDat.hdr,2)
        fprintf (fid, '%s;', TabDat.hdr{i,j});
    end
    fprintf (fid, '\n');
end



%% Print the data
for i=1:size(TabDat.dat,1)
    for j=1:size(TabDat.dat,2)
        fprintf (fid, '%6.3f;', TabDat.dat{i,j});
    end
    fprintf (fid, '\n\n\n\n');
end



%%
fclose (fid);



%%
% =========================================================================
%
% =========================================================================

load SPM

CoordinatesOfInterest = [-58 0 40];
CoordinatesOfInterest(:,end+1) = 1;

ImgsMat = fullfile(pwd, SPM.Vbeta) ;

ImgsInfo = spm_vol(ImgsMat);

BetaDifference = spm_read_vols(ImgsInfo(1));
    
% Getting the coordinates of the voxel of interest
Transf_Matrix = spm_get_space(BetaDifferenceFile);
VoxelsOfInterest = [];
for i=1:size(CoordinatesOfInterest,1) 
    VoxelsOfInterest(i,:) = inv(Transf_Matrix)*CoordinatesOfInterest(i,:)';
end
VoxelsOfInterest(:,4)=[]
         


beta  = spm_get_data(SPM.Vbeta, XYZ);
ResMS = spm_get_data(SPM.VResMS,XYZ);
Bcov  = ResMS*SPM.xX.Bcov;


%% number of Beta estimates = 1
n = 1;
Legend = {'Context'};



%% number of Beta estimates = 2
n = 2;
Legend = {'CON_A' ; 'INC_A'};



%% number of Beta estimates = 4
n = 4;
Legend = {'MG_{A-C}' ; 'MG_{F-C}' ; 'MG_{A-I}' ; 'MG_{F-I}'};



%% Make figure with Beta estimates

NameFigure = xSPM.title;

Coordinates = strcat(' [-54 2 34]');

Color = 'kwkw';

figure('name', NameFigure)

clf

hold on
for i=1:n
    bar(i, contrast.contrast(i), Color(i))
end


for i=1:n
    errorbar(i, contrast.contrast (i), contrast.standarderror(i), 'linewidth', 2)
end

A = floor(min(contrast.contrast)-max(contrast.standarderror));
B = ceil(max(contrast.contrast)+max(contrast.standarderror));

if B>0 & A>0; A=0; elseif B<0 & A<0; B=0; else; end

axis([0.5 n+0.5 A B])

set(gca,'tickdir', 'out', 'xtick', 1:n ,'xticklabel', char(Legend), 'ticklength', [0.002 0], 'fontsize', 13)

ylabel(strcat('Contrast estimates at ', Coordinates));



%% Plots the correlation

Coordinates = strcat(' [ -42 -36 -16 ]');

NameFigure = strcat(xSPM.title, 'Blocks_Percent_Fused_', Coordinates, '.eps') ;

figure(4)
%clf
hold on
grid on

% Plots the dots
A = dir('*.mat');
load(A(1,1).name);

%x = Y/10;
x = matlabbatch{1,1}.spm.stats.factorial_design.des.mreg.mcov.c;

plot(x, y, '+g')

% Plots the regression line
x = [x, ones(size(x))];
B = x\y;
y1 = B(1)*x(:,1)+B(2);
plot(x(:,1),y1,'-g');

axis([min(x(:,1))-0.05 max(x(:,1))+0.05 min(y)-0.2 max(y)+0.2])

ylabel(strcat('Contrast estimates at ', Coordinates));

set(gca,'tickdir', 'out', 'ticklength', [0.02 0])


%%

print(gcf, NameFigure, '-dpsc2')
