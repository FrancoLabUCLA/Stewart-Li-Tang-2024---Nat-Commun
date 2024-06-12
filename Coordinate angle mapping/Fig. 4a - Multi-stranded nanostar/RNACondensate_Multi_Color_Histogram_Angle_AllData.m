% 

clear all

close all

% PIXEL INTENSITIES IN EACH TRIPLICATE
Cy3Col=2;
FitcCol=3;
AllData1 = readmatrix('2021_08_09_trial1_3color_20X_500ms_allPixels_all.csv');
AllData2 = readmatrix('2021_08_09_trial2_3color_20X_500ms_allPixels_all.csv');
AllData3 = readmatrix('2021_08_09_trial3_3color_20X_500ms_allPixels_all.csv');

 
GrayColor1=[.2 .5 .5];
GrayColor2=[.6 .5 .5];


AllCy3=[AllData1(:,Cy3Col);AllData2(:,Cy3Col); AllData3(:,Cy3Col)];
AllFitc=[AllData1(:,FitcCol);AllData2(:,FitcCol); AllData3(:,FitcCol)];

BackgroundSubtraction=1;

if BackgroundSubtraction

AllCy3=AllCy3-min(AllCy3);
AllFitc=AllFitc-min(AllFitc);

end

M=[AllCy3 AllFitc];

[Cy3FitCAngle,rho1] = cart2pol(M(:,1),M(:,2));
Cy3FitCAngle=rad2deg(Cy3FitCAngle);

[FitCCy3Angle,rho2] = cart2pol(M(:,2),M(:,1));
FitCCy3Angle=rad2deg(FitCCy3Angle);

%subplot(1,2,1)
h=histogram(Cy3FitCAngle,1000)
h.FaceColor = GrayColor1;
h.EdgeColor = 'none';
title('Cy3/FitC Multi Color Experiments - Background subtracted')
xlabel('\theta')

h.Normalization = 'probability';
h.BinWidth = 0.25;


% subplot(1,2,2)
% h=histogram(FitCCy3Angle,1000)
% h.FaceColor = GrayColor2;
% h.EdgeColor = 'none';
% title('FitC/Cy3 Multi Color Experiments')
% xlabel('Angle')



Width=15;
Height=8;


set(gcf, 'PaperUnits', 'centimeters'); % SETS THE PAPER UNITS
set(gcf, 'PaperPosition', [0 0 Width Height]); % SETS THE FIGURE SIZE
set(gcf, 'PaperSize', [Width Height]); % CUTS THE FIGURE
print(gcf,'-dpdf', 'RNA_PixelAngle_AllData_RemovedBackground.pdf') % PRINTS TO A FILE.




