clear
clc
close all

%% Variables to be entered

% The months we are producing plots for
monthname = {'01','02','03','04','05','06','07','08','09','10','11','12'};

% The names of the locations we ran hysplit for
locationname = {'Heron_Island',...
	'Whitsundays',...
	'AIMS_Cape_Ferguson',...
	'Orpheus_Island',...
	'Lucinda_Jetty',...
	'Cairns',...
	'Lizard_Island'};

% The lat long of the locations
startingloc = [-23.442297,	151.9148;...
    -20.064914,	148.949486;...
    -19.268172,	147.056733;...
    -18.634008,	146.50035;...
    -18.520314,	146.386336;...
    -16.880572,	145.941811;...
    -14.667689,	145.447906];

% Defines the bounds of the map
xmin = 140;
xmax = 160;
ymin = -30;
ymax = -10;

% Sets the size of the box that the pdf function uses as it's
% containers
containernumber = 30;

% The strength of the 2D interpolation performed after the pdf is constructed
interpStrength = 4;

% The number of levels used for contouring and the colormap
visLevels = 10;

% Min and max colormap and contouring values
cmin = 0;
cmax = 0.17;

% Do you need pdf mat files to be made?
bPDFFiles = false;

%% Loading data

% Opens up the gshhs file to import high definition coastal data: _i is
% medium res, _f is full resolution
latlim = [ymin ymax];
lonlim = [xmin xmax];
S = gshhs('gshhs_i.b', latlim, lonlim);
% Pulls out the different levels of the map ie, coastline, rivers, etc
levels = [S.Level];
% Picks out just the coastal data
L1 = S(levels == 1);

% Gets the directory of the script
loc = fileparts(mfilename('fullpath'));

% Load in the Great Barrier Reef coordinates
[GBRlong, GBRlat] = GBRCoords();
% Cut off the coastline section of the reef
GBRlong = GBRlong(1:8);
GBRlat = GBRlat(1:8);

%% Processing and plotting

maxgrid = zeros(length(monthname)*length(locationname),1);

% Loops over the months listed
for i=1:length(monthname)
    
    % Loads in the first months matrix file (this file contains data for all of the locations)
    load(strcat(loc, '/Mat/',char(monthname(i)), '.mat'));
    
    % Loops over the locations listed
    for j = 1:length(locationname)
        
        % Rips out just a single locations data from the matrix opened
        % above (savemat is the name of the variable inside the .mat file)
        ref = savemat(:,1) == j;
        
        % Splits the matrix up into just the lattitude and longitude
        % vectors. Data comes in as Long in column 2 and Latt in column 3
        Long = savemat(ref,3);
        Lat = savemat(ref,2);
        
        numPoints = length(Long);
        
        % Restrict the X Y data to just within the xmin and ymin
        % values
        refX = Long >= lonlim(1) & Long <= lonlim(2);
        Long = Long(refX);
        Lat = Lat(refX);
        refY = Lat >= latlim(1) & Lat <= latlim(2);
        Long = Long(refY);
        Lat = Lat(refY);

        % Specify the horiz and vert domains        
        x_axis = linspace(xmin, xmax, containernumber); 
        y_axis = linspace(ymin, ymax, containernumber); 
        
        % Produce the histogram of the data
        [N,c] = hist3([Lat,Long],{y_axis,x_axis});
        
        % Normalise the histogram
        N = N./numPoints;
        
        % Smooth the pdf
        interppdf = interp2(N,interpStrength,'spline');
        
        % Save the pdf to a mat file in case someone wants to use it
        if bPDFFiles == true
            save(strcat(loc, '/pdf_', char(monthname(i)),'_', char(locationname(j)), '.mat'), 'interppdf');
        end
        %% Plot the pdf on a proper map
        
        figure
        hold on
        
        % Sets the projection type, and axis limits of the map
        axesm('mercator', 'MapLatLimit', latlim, 'MapLonLimit',lonlim)
        gridm; mlabel; plabel
        % Changes the distance between subdivisions of the grid
        setm(gca, 'MLineLocation', 5, 'MLabelLocation', 5, 'PLineLocation', 5, 'PLabelLocation', 5)
        
        % Sets the image location
        R = georasterref('RasterSize',size(interppdf),...
            'Latlim',latlim, 'Lonlim', lonlim);
        
        % Zero all the negative values so the matrix doesn't turn complex
        % in the next step
        interppdf(interppdf < 0) = 0;
        
        % Scale the data so that contours and coloring arent so bunched up
        % (my excuse for this being ok is the 1/r^2 law)
        interppdf = interppdf.^(0.5);
        
        % Plots the pdf onto the map defined above
        geoshow(interppdf, R, 'DisplayType', 'texturemap')
        %geoshow(Y,X)
        
        % Sets the colormap for the pdf
        mycmap = (flipud(gray(visLevels-1)));
        colormap(mycmap)
        
        % Force the colormap to use preset min and max values
        caxis([cmin,cmax])
        
        % Plots the coastal data on the map
        geoshow([L1.Lat], [L1.Lon], 'Color', 'blue')
        
        % Plots the GBR on the map
        geoshow(GBRlat, GBRlong, 'Color', 'red')

        % Plots the contour lines of the pdf
        %contourlines = linspace(min(min(interppdf)),max(max(interppdf)),visLevels);
        contourlines = linspace(cmin,cmax,visLevels);
        contplot = contourm(interppdf,R,contourlines(2:end),'Color','black');
        
        geoshow(startingloc(j,1), startingloc(j,2), 'DisplayType', 'Point', 'Marker', '+', 'Color', 'red');
        
        tightmap
        
        cbar = colorbar;
        cbar.Label.String = 'Fraction of trajectory points';
        
        set(gcf,'Renderer','zbuffer')
        
        hold off
        
        print(strcat(loc,'/Fig/', 'Map_', char(monthname(i)), num2str(j)),'-depsc')
        
        close all
        
    end
end