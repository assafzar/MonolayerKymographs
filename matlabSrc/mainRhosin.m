%% mainRhosin
% Replicates the Rhosin pertubation from the GEF screen

% Input:
%   filename - input time lapse
%   params - parameters for processing, default values set for Angeles_20150402_14hrs_5min_AA01_7.tif

% Example:
%   RhosinDname = 'C:\Assaf\Research\MonolayerDynamics\data\RhosinKymographs';
%   mainRhosin(RhosinDname);

% Assaf Zaritsky, Jan. 2018 (implemented for the NEUBIAS training school)

function mainRhosin(RhosinDname,params)

p = inputParser;
p.addRequired('RhosinDname', @(x)validateattributes(x,{'char'},{'nonempty'}));
p.addOptional('params', @(x)validateattributes(x,{'struct'},{'nonempty'}));

if nargin < 2
    pixelSize = 0.908;
    params = setDefaultParams(pixelSize);
else
    params.pixelSize = 0.908;
end

%% meta data parameters (based on the original paper)
metaData.timePerFrame = params.timePerFrame;
metaData.timeToAnalyze = 200;
metaData.spaceToAnalyze = 12; % in patches, 12 x 15um = 180um
metaData.timePartition = 4;
metaData.spatialPartition = 3;
metaData.initialTimePartition = 0; %2

%% Information about the treatments
expPrefix = 'Yunyu_20160407_16hr_5min_01_s';

orderCondsStr = {'DMSO','25uM','50uM','100uM','200uM'};
condInds = [1:6,7:12,13:18,25:30,19:24];
orderCondsInds = {1:6,7:12,13:18,25:30,19:24};

cmap = colormap(hsv(length(orderCondsStr))); % for visualization

%% was used to produce the kymographs, in directories that held the intermediately processed data
% for iLocation = 1 : n
%     locationFakeFname = [RhosinDname filesep expPrefix sprintf('%02d.tif',iLocation)]; % does not exist, only used for the directory + experiment
%     [params,dirs] = initParamsDirs(locationFakeFname,params); % set missing parameters, create output directories
%     whKymographs(params,dirs);
%     close all;
% end

%%
nFeats = (metaData.timePartition-metaData.initialTimePartition) * metaData.spatialPartition;
n = length(condInds);

%% Directories

% input (kymographs)
RhosinKymographDname = [RhosinDname filesep 'kymographs'];

% output
RhosinOutDname = [RhosinDname filesep 'output'];
if ~exist(RhosinOutDname,'dir')
    mkdir(RhosinOutDname);
end
%% Transfrom kymographs to feature vectros, use pre-calculated PCA to project to lower dimension and compare KD to Control
allMeasureStr = {'speed','directionality','coordination'};

for iMeasure = 1 : length(allMeasureStr)  
    measureStr = allMeasureStr{iMeasure};
    feats = nan(nFeats,n);
    for iLocation = 1 : n
        feats(:,iLocation) = kemogrpah2Feats(RhosinKymographDname,measureStr,expPrefix,iLocation,metaData);
    end
    
    % Use pre-calculated PCA to project to lower dimension
    load([RhosinDname filesep 'precalcPcaParams_' measureStr '.mat']); % precalcPcaParams (.nFeats,.meanFeats,stdFeats,coeff)
    [score] = getPrecalcPCA(feats,precalcPcaParams);           
 
    featsSort = feats(:,condInds);
    h = figure; imagesc(featsSort); saveas(h,[RhosinOutDname filesep 'feats_' measureStr '.jpg']);
    
    fontsize = 18;
    for ipc = 1 : 3
        curPCs = score(:,ipc);
        h = figure;
        haxes = get(h,'CurrentAxes');
        xlabel('Experiment','FontSize',fontsize);
        ylabel(sprintf('PC%d',ipc),'FontSize',fontsize);
        hold on;
        curX = 1;
        for icond = 1 : length(orderCondsStr)
            curInds = orderCondsInds{icond};
            %         curStr = orderCondsStr{icond};
            plot(curX:(curX + length(curInds) - 1),curPCs(curInds),'o','MarkerEdgeColor',cmap(icond,:),'LineWidth',2,'MarkerSize',8);
            curX = curX + length(curInds);
        end
                
        legend([orderCondsStr(:)],'Location','eastoutside');
        set(haxes,'FontSize',fontsize);
        set(h,'Color','w');
        
        hold off;
        saveas(h,[RhosinOutDname filesep 'feats_' measureStr '_PC' num2str(ipc) '.jpg']);
        close all;
    end
end
end


%%
function [feats] =  kemogrpah2Feats(RhosinKymographDname,measureStr,expPrefix,iLocation,metaData)
load([RhosinKymographDname filesep measureStr filesep sprintf('%s%02d_%sKymograph.mat',expPrefix,iLocation,measureStr)]);
eval(sprintf('kymograph = %sKymograph;',measureStr)); % kymograph
assert(exist('kymograph','var') > 0);

distancesFromWound = find(isnan(kymograph(:,1)),1,'first')-1;
if isempty(distancesFromWound)
    distancesFromWound = size(kymograph,1);
end

if distancesFromWound < metaData.spaceToAnalyze % 180 um
    warning('Too few cells %s!',expPrefix);
end

feats = getFeatures(kymograph,metaData);

end


%%
function [features] = getFeatures(kymograph,metaData)

nTime = floor(metaData.timeToAnalyze/metaData.timePerFrame);
nFeats = (metaData.timePartition-metaData.initialTimePartition) * metaData.spatialPartition;
features = zeros(nFeats,1);

ys = 1 : floor(metaData.spaceToAnalyze/(metaData.spatialPartition)) : (metaData.spaceToAnalyze+1);
xs = 1 : floor(nTime/(metaData.timePartition)) : (nTime+1);

curFeatI = 0;
for y = 1 : metaData.spatialPartition
    for x = (1+metaData.initialTimePartition) : metaData.timePartition%x = 1 : metaData.timePartition
        curFeatI = curFeatI + 1;
        values = kymograph(ys(y):(ys(y+1)-1),xs(x):(xs(x+1)-1));
        values = values(~isinf(values));
        values = values(~isnan(values));
        features(curFeatI) = mean(values(:));
    end
end
end


%% Given the features and precalculated PCA transformation, calculate the PCA transformation
function [score] = getPrecalcPCA(features,precalcPCA)
features = features';
[nObs mFeats] = size(features);
curFeatsNorm = (features - repmat(precalcPCA.meanFeats,[nObs 1])) ./ repmat(precalcPCA.stdFeats,[nObs 1]); % zscore(A)

score = curFeatsNorm * precalcPCA.coeff;
end