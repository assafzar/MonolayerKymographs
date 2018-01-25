%% simulateCoordination
% Simulates artificial image with coordinated cluster in the middle. This
% is implemented by having a constant vector in each pixel in the image
% (dy,dx) = (0,1), but different noise models for the coordinated cluster and the rest of the image.

% Input:
%   sizeYX - size of image tuple (e.g., [1024,1024])
%   coordFrac - what faction of the image will be considered as
%       coordinated (1 - all image, 0 - no coordination)
%   sXBack,sYBack - standard deviation of background (could be different becuase of prefered direction)
%   sXCoord,sYCoord - standard deviation in coordinated clusters
%   outPrefix - for saving figures (e.g., path/coord1), suffixes will be
%       included for the different outputs (e.g., path/coord1_simSpeed.jpg - for the simulated speed)

% Output:
%   IySim,IxSim - The simulated velocity field 
%   Ispeed,Iorientation - derived..
%   coordROI - ground truth for coordination
%   Save figures of the simulated velocity fields: prefix with the suffix
%   _simX, simY, simSpeed, simOrientation

% Assaf Zaritsky, Jan. 2018 (implemented for the NEUBIAS training school)

function [IySim,IxSim,Ispeed,Iorientation,coordROI] = simulateCoordination(sizeYX,coordFrac,sXBack,sYBack,sXCoord,sYCoord,outPrefix)

% p = inputParser;
% p.addRequired('I', @(x)validateattributes(x,{'uint8'},{'nonempty'}));
% p.addRequired('ROIclusters', @(x)validateattributes(x,{'uint8'},{'nonempty'}));
% p.addRequired('ROIclusters', @(x)validateattributes(x,{'char'},{'nonempty'}));
% p.addOptional('extraColor', @(x)validateattributes(x,{'uint8'},{'nonempty'}));

sizeY = sizeYX(1);
sizeX = sizeYX(2);
midY = round(sizeY/2);
midX = round(sizeX/2);
widthY = round(0.5*sizeY*coordFrac);
widthX = round(0.5*sizeX*coordFrac);

% simulate noise
coordROI = false(sizeYX);
coordROI((midY - widthY):(midY + widthY),(midX - widthX):(midX + widthX)) = true;

% mean vector is (dy,dx) = (0,1)
IxSim = doSimulate(coordROI,1,sXBack,sXCoord);
IySim = doSimulate(coordROI,0,sYBack,sYCoord);

%% figures
hx = figure;
imagesc(IxSim);
colormap('gray');
hold on;
haxes = get(hx,'CurrentAxes');
set(haxes,'XTick',[]);
set(haxes,'YTick',[]);
set(haxes,'XTickLabel',[]);
set(haxes,'YTickLabel',[]);
set(hx,'Color','none');
axis equal; % no image stretching
axis off;
axis tight;
hold off;
saveas(hx,[outPrefix '_simX.jpg']);

hy = figure;
imagesc(IySim);
colormap('gray');
hold on;
haxes = get(hy,'CurrentAxes');
set(haxes,'XTick',[]);
set(haxes,'YTick',[]);
set(haxes,'XTickLabel',[]);
set(haxes,'YTickLabel',[]);
set(hy,'Color','none');
axis equal; % no image stretching
axis off;
axis tight;
hold off;
saveas(hy,[outPrefix '_simY.jpg']);

Ispeed = sqrt(IxSim.^2 + IySim.^2); 
hspeed = figure;
imagesc(Ispeed);
colormap('gray');
hold on;
haxes = get(hspeed,'CurrentAxes');
set(haxes,'XTick',[]);
set(haxes,'YTick',[]);
set(haxes,'XTickLabel',[]);
set(haxes,'YTickLabel',[]);
set(hspeed,'Color','none');
axis equal; % no image stretching
axis off;
axis tight;
hold off;
saveas(hspeed,[outPrefix '_simSpeed.jpg']);

Iorientation = atan(IySim./IxSim) * 180/pi;
horientation = figure;
imagesc(Iorientation);
colormap('gray');
hold on;
haxes = get(horientation,'CurrentAxes');
set(haxes,'XTick',[]);
set(haxes,'YTick',[]);
set(haxes,'XTickLabel',[]);
set(haxes,'YTickLabel',[]);
set(horientation,'Color','none');
axis equal; % no image stretching
axis off;
axis tight;
hold off;
saveas(horientation,[outPrefix '_simOrientation.jpg']);
end

%%
function Isim = doSimulate(coordROI,mu,sBack,sCoord)
Isim = ones(size(coordROI)) * mu;
IsimBack = normrnd(mu,sBack,size(Isim));
Isim(~coordROI) = IsimBack(~coordROI);
IsimCoord = normrnd(mu,sCoord,size(Isim));
Isim(coordROI) = IsimCoord(coordROI);
end