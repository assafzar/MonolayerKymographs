%% mainCoordination
% 1. Simulate coordinated cluster and assess sensitivity of clustering
% 2. Use real data and demonstrate clustering

% Input:
%   outSimDname - where to output simulation results
%   inFname - actual data to process

% Example:
%   outSimDname = 'C:\Assaf\Research\MonolayerDynamics\data\Coordination\simulations';
%   inFname = 'C:\Assaf\Research\MonolayerDynamics\data\Coordination\Angeles_20140308_16hr_5min_0001_0002_AB01_03.tif';
%   mainCoordination(outSimDname,inFname);

% Assaf Zaritsky, Jan. 2018 (implemented for the NEUBIAS training school)

function mainCoordination(outSimDname,inFname)

p = inputParser;
p.addRequired('ourDname', @(x)validateattributes(x,{'char'},{'nonempty'}));
p.addOptional('inFname', @(x)validateattributes(x,{'char'},{'nonempty'}));

if ~exist(outSimDname,'dir')
    mkdir(outSimDname);
end

%% Simulation parameters
sizeYX = [100,100];
coordFrac = 0.3;
sXBack = 1;
sYBack = 0.3;
% parameters to construct the coordinated cluster will be defined
% independently for each experiment (see below)

%% Region growing segmentation parameters
params.pixelSize = 1; % um
params.patchSize = 1; % um - resolution is reduced!
params.nBilateralIter = 1;
params.minClusterArea = 500; % in um^2

params.regionMerginParams.P = 0.03;% small P --> more merging
params.regionMerginParams.Q = 0.005;% large Q --> more merging (more significant than P)
params.regionMerginParams.fVecSim = @vecEuclideanSimilarity;
% params.regionMerginParams.fVecSim = @vecOrientationSimilarity; 

%% Simulations
sXCoords = [0,0,0.1,0.1,0.2,0.1,0.2,0.3,0.3];
sYCoords = [0,0.1,0,0.1,0.1,0.2,0.2,0.2,0.3];

assert(length(sXCoords) == length(sYCoords));

nSimulations = length(sXCoords);

for isim = 1 : nSimulations
    sXCoord = sXCoords(isim);
    sYCoord = sYCoords(isim);
    outPrefix = [outSimDname filesep xy2str(sXCoord,sYCoord)];
    [IySim,IxSim,Ispeed,Iorientation,coordROI] = simulateCoordination(sizeYX,coordFrac,sXBack,sYBack,sXCoord,sYCoord,outPrefix);
    %     params.regionMerginParams.Q = 0.01; % more merging
    [~,ROIclusters,~,~,~] = doRegionGrowingSegmentCoordination(IxSim,IySim,params);
    visualizeCoordinationSim(Ispeed,ROIclusters,[outPrefix '_coordVisSpeed.jpg']);
    visualizeCoordinationSim(Iorientation,ROIclusters,[outPrefix '_coordVisOrientation.jpg']);
    close all;
end

if exist('inFname','var')
    if ~exist(inFname,'file')
        error('file %s does not exists',inFname);
    end
    
    pixelSize = 1.249902; % um  
    params = setDefaultParams(pixelSize);

    processTimeLapse(inFname,params);
end

end

%%
function xyStr = xy2str(x,y)
xyStr = ['Sx' num2str(x) 'Sy' num2str(y)];
xyStr = strrep(xyStr,'.','');
end