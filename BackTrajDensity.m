% Processes all of the hysplit data files into a single mat file
clear
clc
close all

%% Inputs
% The months that are to be processed
%months = {'01','02','03','04','05','06','07','08','09','10','11','12'};
months = {'09','10'};

%% Preprocessing
% Grabs script directory
loc = fileparts(mfilename('fullpath'));

% Grabs directory of the data files
allfiles = dir(strcat(loc,'/Data/'));

% Gets all the files in that directory
files = allfiles(arrayfun(@(x) x.name(1), allfiles) ~= '.');

%% Processing
for j = 1:length(months)
    % Reset the data matrix when starting a new month
    data = [];
    % Print the month currently being worked on
    disp(strcat('Working on month: ', months(j)));
    
    for i = 1:length(files)
        % I feel like you can do this loop more efficiently by combining the
        % if statement somehow
        if files(i).name(8:9) == months{j}
            
            dataloc = strcat(loc, '/Data/', files(i).name);
            
            % Finds the line containing the text pressure as this is where the
            % data starts
            strtofind = 'PRESSURE';
            if ispc % Windows
                [~,lines] = system(['find /n "' strtofind '" ' dataloc]);
            elseif isunix % Mac, Linux
                [~,lines] = system(['grep -n "' strtofind '" ' '"' dataloc '"']);
            else
                error('Unknown operating system!');
            end
            % I'm not sure this line will work on pc as find may use a different
            % delimiter than grep
            linesplit = strsplit(lines,':');
            linenum = str2num(linesplit{1});
            
            readdata = dlmread(dataloc, '',linenum , 0);
            
            % Reads in the data from each file adding the next on to the previous files 
            % data: location, latt, long
            data = [data; readdata(:,[1,10,11])];
        end
    end
    %for some reason im getting a cell array from this...
    saveloc = strcat(loc,'/Mat', '/', months{j} ,'.mat');
    %saveloc = saveloc{1};
    savemat = data;
    
    save(saveloc, 'savemat');
    
end