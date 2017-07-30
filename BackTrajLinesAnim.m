clear
clc
close all

monthname = {'06'};

locationname = {'Gunn Point'};

xmin = 129;
xmax = 141;
ymin = -21;
ymax = -9;

f1 = figure;
hold on

for i = 1:length(monthname)
    monthname(i)
    loc = fileparts(mfilename('fullpath')); %returns directory of the script
    load(strcat(loc, '/',char(monthname(i)), '.mat'));
    
    startingloc = [-12.249 131.0449];
    
    for j = 1:length(locationname)
        
        ref = savemat(:,1) == j;
        X = savemat(ref,2);
        Y = savemat(ref,3);
        
        hoursback = 48;
        
        h1 = 0;
        h2 = 0;%trying to find a way to keep the last late then delete and build and so on
        h3 = 0;
        h4 = 0;
        t1=0;
        
     
        
        
        load coast
        
        plot(long, lat,'Color','b')
        set(gcf,'Renderer','zbuffer');
        %axis xy
        axis equal
        
        axis([xmin xmax ymin ymax]);
        ploc = plot(startingloc(j,2),startingloc(j,1),'.k','MarkerFaceColor','r','MarkerSize',16);
        writerObj = VideoWriter('linesovertime.avi','MPEG-4');
        writerObj.FrameRate = 10;
        open(writerObj)
        
            days = 1;
            hours = 0;
        
        for k = 1:hoursback:length(savemat)
            
            if hours == 20
                days = days + 1;
                hours = 0;
            end
            hours = hours + 4;
            
            h4 = h3;
            h3 = h2;
            h2 = h1;
            h1 = plot(X(k:k+hoursback-1),Y(k:k+hoursback-1),'-k','Marker','.');
            if h2 ~= 0
                set(h2,'Color',[0.5,0.5,0.5]);
            end
            if h3 ~= 0
                set(h3,'Color',[0.75,0.75,0.75]);
            end
            if h4 ~= 0
                delete(h4);
            end
            
            title(['Days: ' num2str(days) ' Hours: ' num2str(hours)], 'Units', 'normalized', ...
            'Position', [0.3 1],'HorizontalAlignment', 'left');
            
            
%             if t1 ~= 0
%             delete(t1);
%             end
%             if hours < 10
%             legend(sprintf('%s\n%s', ['days: ' num2str(days)], [' hours: ' num2str(hours)]))
%                l1 = legend([ploc],['days: ' num2str(days) ' hours: ' num2str(hours)],-1);
%        set(l1, 'horizontalAlignment', 'left')
% %b=findobj(l1,'Linewidth');
% %set(b,'Visible','Off');
% legend boxoff
%             else
%             legend(strcat('days: ',num2str(days), 'hours: ',num2str(hours)))
%             end
            

            frame = getframe(f1);
            writeVideo(writerObj,frame);
            
            %plot(X(inGBR),Y(inGBR),'.')
            
            %hold off
            %pause(0.1);
            %print(strcat(loc,'/Fig/', char(monthname(i)), num2str(j),'lines'),'-depsc')
        end
        close(writerObj);
    end
    
end