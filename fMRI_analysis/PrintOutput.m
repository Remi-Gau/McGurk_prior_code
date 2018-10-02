% Prints SPM output (clusters and peak activation to a file)

%% Get Data
Data = TabDat.dat;
Format = TabDat.fmt;
Header = TabDat.hdr;
Footer = TabDat.ftr;
Title = xSPM.title;

%% Prints

OutputFileName = ['Results_' Title '.csv'];
fid = fopen (OutputFileName, 'w');

CoordinatesOnly = ['Coord_' Title '.txt'];
fid2 = fopen (CoordinatesOnly, 'w');

fprintf (fid, Title);
fprintf(fid, '\n');

% Prints Header
for i=1:size(Header,2); fprintf(fid, [Header{1,i}, ',']); end;
fprintf(fid, '\n');

for i=1:size(Header,2); fprintf(fid, [Header{2,i}, ',']); end;
fprintf(fid, '\n');

% Prints data
for i=1:size(Data,1)
    for j=1:size(Data,2)-1
        fprintf(fid, [num2str(Data{i,j}) ',']);
    end; 
    for j=1:3
        fprintf(fid, [num2str(Data{i,12}(j)) ',']);
    end; 
    fprintf(fid, '\n');
    
    for j=1:3
        fprintf(fid2, [num2str(Data{i,12}(j)) ' ']);
    end; 
    fprintf(fid2, '\n');
end

fclose (fid);
fclose (fid2);

