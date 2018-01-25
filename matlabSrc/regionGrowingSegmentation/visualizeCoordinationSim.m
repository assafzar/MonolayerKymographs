%% visualizeCoordinationSim
% Visualize coordination clusters on simulation
% Input:
%   I - image
%   ROIclusters - mask of cell in clusters
%   outFname - to save the figure

% Assaf Zaritsky, Jan. 2018 (implemented for NEUBIAS training school)

function [] = visualizeCoordinationSim(I,ROIclusters,outFname)

p = inputParser;
p.addRequired('I', @(x)validateattributes(x,{'nonempty'}));
p.addRequired('ROIclusters', @(x)validateattributes(x,{'logical'},{'nonempty'}));
p.addRequired('coordROI', @(x)validateattributes(x,{'logical'},{'nonempty'}));
p.addRequired('outFname', @(x)validateattributes(x,{'char'},{'nonempty'}));

Icoord = stretchTo256(I,2);
Icoord(bwperim(ROIclusters)) = 255;

hCoord = figure;
imagesc(Icoord);
colormap('gray');
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

function Inew = stretchTo256(I,p)
pmin = prctile(I(:),p);
pmax = prctile(I(:),100-p);
Inew = I;
Inew(I > pmax) = pmax;
Inew(I < pmin) = pmin;
Inew = ((Inew - pmin) / (pmax - pmin)) * 255;
end