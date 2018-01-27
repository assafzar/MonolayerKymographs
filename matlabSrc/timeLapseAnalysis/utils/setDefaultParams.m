%% setDefaultParams
% Sets defualt set of params

% Input:
%   pixelSize
%   timePerFrame - optional (default = 5 min)

% Assaf Zaritsky, Jan. 2018 (implemented for the NEUBIAS training school)

function params = setDefaultParams(pixelSize,timePerFrame)


p = inputParser;
p.addRequired('pixelSize', @(x)validateattributes(x,{'double'},{'nonempty'}));
p.addOptional('timePerFrame', @(x)validateattributes(x,{'double'},{'nonempty'}));

params.pixelSize = pixelSize; % um
if ~exist('timePerFrame','var')
    timePerFrame = 5; % minutes
end
params.timePerFrame = timePerFrame; 

params.nRois = 1; % 1 - for 1-side advancing monolayer, 2 - wound healing
params.always = false; % false means that available intermediate results are going to be used

params.patchSizeUm = 15.0; % 15 um
params.nTime = floor(200 / params.timePerFrame); % frames to process (200 minutes)
params.maxSpeed = 90; % um / hr (max cell speed)

% for region growing segmentation
params.regionMerginParams.P = 0.03;% small P --> more merging
params.regionMerginParams.Q = 0.005;% large Q --> more merging (more significant than P)
params.regionMerginParams.fVecSim = @vecEuclideanSimilarity;
% params.regionMerginParams.fVecSim = @vecOrientationSimilarity;


% for region growing segmentation
params.regionMerginParams.P = 0.03;% small P --> more merging
params.regionMerginParams.Q = 0.005;% large Q --> more merging (more significant than P)
params.regionMerginParams.fVecSim = @vecEuclideanSimilarity;

% for kymographs display
params.kymoResolution.maxDistMu = 180; % how deep to go into the monolayer (um)

params.isDx = true; % main cell motion in x direction


% for kymographs display
params.kymoResolution.maxDistMu = 180; % how deep to go into the monolayer (um)

params.isDx = true; % main cell motion in x direction

params.patchSize = ceil(params.patchSizeUm/params.pixelSize); % patch size in pixels

params.kymoResolution.min = params.patchSize;
params.kymoResolution.stripSize = params.patchSize;
params.kymoResolution.maxDistMu = 180; % um
end