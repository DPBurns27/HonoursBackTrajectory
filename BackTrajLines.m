clear
clc
close all

monthname = {'01','02','03','04','05','06','07','08','09','10','11','12'};

locationname = {'Heron_Island',...
	'Whitsundays',...
	'AIMS_Cape_Ferguson',...
	'Orpheus_Island',...
	'Lucinda_Jetty',...
	'Cairns',...
	'Lizard_Island'};

xmin = 140;
xmax = 160;
ymin = -30;
ymax = -10;

for i=1:length(monthname)
monthname(i)
loc = fileparts(mfilename('fullpath')); %returns directory of the script
load(strcat(loc, '/',char(monthname(i)), '.mat'));

startingloc = [-23.442297,	151.9148;...
    -20.064914,	148.949486;...
    -19.268172,	147.056733;...
    -18.634008,	146.50035;...
    -18.520314,	146.386336;...
    -16.880572,	145.941811;...
    -14.667689,	145.447906];

for j = 1:length(locationname)
    ref = savemat(:,1) == j;
    
    

% Data (example):
X = savemat(ref,2); 
Y = savemat(ref,3);

[GBRlong, GBRlat] = GBRCoords();

inGBR = inpolygon(X, Y, GBRlong, GBRlat);
GBRfrac = sum(inGBR)/size(X,1);
figure
plot(X,Y,'.')
%plot(X(inGBR),Y(inGBR),'.')
hold on
plot(GBRlong, GBRlat, 'Color','r')

load coast

plot(long, lat,'Color','b')


axis xy
axis equal

axis([xmin xmax ymin ymax])
plot(startingloc(j,2),startingloc(j,1),'.k','MarkerFaceColor','r','MarkerSize',16)

myText = sprintf('%.3f', GBRfrac);
text(156.5, -12, myText);


hold off

print(strcat(loc,'/Fig/', char(monthname(i)), num2str(j),'lines'),'-depsc')


end
end