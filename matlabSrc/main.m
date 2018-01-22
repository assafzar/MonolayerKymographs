function main(filename,params)

p = inputParser;
p.addRequired('filename', @(x)validateattributes(x,{'char'},{'nonempty'}));
p.addOptional('params', @(x)validateattributes(x,{'struct'},{'nonempty'}));

if nargin < 2
    params.timePerFrame = 5; % minutes
    params.nRois = 1; % 1 - for 1-side advancing monolayer, 2 - wound healing 
    params.always = false; % false means that available intermediate results are going to be used
        
    params.pixelSize = 1.267428; % um    
    params.patchSizeUm = 15.0; % 15 um
    params.nTime = floor(200 / params.timePerFrame); % frames to process (200 minutes)
    params.maxSpeed = 90; % um / hr (max cell speed)
    
    % for region growing segmentation
    params.regionMerginParams.P = 0.03;% small P --> more merging
    params.regionMerginParams.Q = 0.005;% large Q --> more merging (more significant than P)
    
    % for kymographs display
    params.kymoResolution.maxDistMu = 180; % how deep to go into the monolayer (um)
    
    params.isDx = true; % main cell motion in x direction
    params.nRois = 1; % just one side of the "wound" is analyzed    
end

% Parameters that depend on previous params..
params.patchSize = ceil(params.patchSizeUm/params.pixelSize); % patch size in pixels

params.kymoResolution.min = params.patchSize;
params.kymoResolution.stripSize = params.patchSize;
params.kymoResolution.maxDistMu = 180; % um

processTimeLapse(filename, params);
close all;
end