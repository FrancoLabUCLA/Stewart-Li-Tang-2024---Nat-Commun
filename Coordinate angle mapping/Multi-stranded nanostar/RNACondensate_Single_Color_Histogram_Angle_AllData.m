clear all

close all

% PIXEL INTENSITIES IN EACH TRIPLICATE
Cy3Col=2;
FitcCol=3;
AllDataCorn1 = readmatrix('2020_05_20_Corn_500ms_0_allPixels.csv');
AllDataCorn2 = readmatrix('2020_05_20_Corn_500ms_1_allPixels.csv');
AllDataCorn3 = readmatrix('2020_05_20_Corn_500ms_2_allPixels.csv');

AllDataCorn=[AllDataCorn1; AllDataCorn2; AllDataCorn3];

AllDataOB1 = readmatrix('2020_05_20_OB_500ms_0_allPixels.csv');
AllDataOB2 = readmatrix('2020_05_20_OB_500ms_1_allPixels.csv');
AllDataOB3 = readmatrix('2020_05_20_OB_500ms_2_allPixels.csv');
AllDataOB4 = readmatrix('2020_05_20_OB_500ms_3_allPixels.csv');

AllDataOB=[AllDataOB1; AllDataOB2; AllDataOB3];

AllDataRB1 = readmatrix('2020_05_20_RB_500ms_0_allPixels.csv');
AllDataRB2 = readmatrix('2020_05_20_RB_500ms_1_allPixels.csv');
AllDataRB3 = readmatrix('2020_05_20_RB_500ms_2_allPixels.csv');

AllDataRB=[AllDataRB1; AllDataRB2; AllDataRB3];


%%%%%%%%% COLORS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GrayColor=[.5 .5 .5];
CornColor=[0.9290 0.6940 0.1250];
OrangeBColor=[0.8500 0.3250 0.0980];
RedBColor=[0.6350 0.0780 0.1840];


BackgroundSubtraction=1;

if BackgroundSubtraction
    AllDataCorn=AllDataCorn-min(AllDataCorn);
    AllDataOB=AllDataOB-min(AllDataOB);
    AllDataRB=AllDataRB-min(AllDataRB);
        
end

CornFitC=AllDataCorn(:,3);
CornCy3=AllDataCorn(:,2);
[thetaCorn,rhoCorn] = cart2pol(CornCy3,CornFitC);
thetaCorn=rad2deg(thetaCorn);


OBFitC=AllDataOB(:,3);
OBCy3=AllDataOB(:,2);
 
[thetaOB,rhoOB] = cart2pol(OBCy3,OBFitC);
thetaOB=rad2deg(thetaOB);

RBFitC=AllDataRB(:,3);
RBCy3=AllDataRB(:,2);

[thetaRB,rhoRB] = cart2pol(RBCy3,RBFitC);
thetaRB=rad2deg(thetaRB);



h1=histogram(thetaCorn,1000,'Normalization','probability')
h1.FaceColor = CornColor;
h1.EdgeColor = 'none';
hold on

h2=histogram(thetaOB,1000,'Normalization','probability')
h2.FaceColor = OrangeBColor;
h2.EdgeColor = 'none';
hold on

h3=histogram(thetaRB,1000,'Normalization','probability')
h3.FaceColor = RedBColor;
h3.EdgeColor = 'none';
hold on

h1.Normalization = 'probability';
h1.BinWidth = 0.25;
h2.Normalization = 'probability';
h2.BinWidth = 0.25;
h3.Normalization = 'probability';
h3.BinWidth = 0.25;

if BackgroundSubtraction==0
    
    title('Single Color controls - raw data')
else
    title('Cy3/FitC Single Color controls - background subtracted')
end

legend('Corn','Orange Broccoli','Red Broccoli','Location','North')
legend boxoff
xlabel('\theta');
%ylabel('Count');

%xlim([0 20])
%ylim([0 200])
Width=15;
Height=8;


 

%%%% PDF %%%%%%%%%%%%%
set(gcf, 'PaperUnits', 'centimeters'); % SETS THE PAPER UNITS
set(gcf, 'PaperPosition', [0 0 Width Height]); % SETS THE FIGURE SIZE
set(gcf, 'PaperSize', [Width Height]); % CUTS THE FIGURE
if BackgroundSubtraction==0
    print(gcf,'-dpdf', 'RNA-PixelAngle_SingleColor.pdf') % PRINTS TO A FILE.
else
    print(gcf,'-dpdf', 'RNA-PixelAngle_SingleColor_RemovedBackground.pdf') % PRINTS TO A FILE.
end



