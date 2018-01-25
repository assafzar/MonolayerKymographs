%% visualizeCoordination
% Overlay coordination clusters on gray level image
% Input:
%   I - image (could be IySim,IxSim,Ispeed,Iorientation)
%   ROIclusters - mask of cell in clusters
%   outFname - to save the figure

% Assaf Zaritsky, Jan. 2018 (implemented for NEUBIAS training school)

function [] = visualizeCoordination(I,ROIclusters,outFname,extraColor)

p = inputParser;
p.addRequired('I', @(x)validateattributes(x,{'uint8'},{'nonempty'}));
% p.addRequired('I', @(x)validateattributes(x,{'nonempty'}));
p.addRequired('ROIclusters', @(x)validateattributes(x,{'uint8'},{'nonempty'}));
p.addRequired('outFname', @(x)validateattributes(x,{'char'},{'nonempty'}));
p.addOptional('extraColor', @(x)validateattributes(x,{'uint8'},{'nonempty'}));

if nargin < 4
    extraColor = 100;
end

[sizeY,sizeX] = size(I);

% Icoord = uint8(zeros(sizeY,sizeX,3));%16
I8 = imadjust(I);
Icoord = uint8(zeros(sizeY,sizeX,3));%16
I8red = I8; % assumes that the main motion is on the x-axis
I8red(ROIclusters) = min(I8(ROIclusters) + extraColor, 255);% 65535
Icoord(:,:,1) = I8red;
Icoord(:,:,2) = I8;
Icoord(:,:,3) = I8;

hCoord = figure;
imagesc(Icoord);
hold on;
haxes = get(hCoord,'CurrentAxes');
set(haxes,'XTick',[]);
set(haxes,'YTick',[]);
set(haxes,'XTickLabel',[]);
set(haxes,'YTickLabel',[]);
set(hCoord,'Color','none');
axis equal; % no image stretching
axis off;
axis tight;
hold off;
saveas(hCoord,outFname);
end