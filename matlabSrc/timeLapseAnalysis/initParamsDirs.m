% params, mainDirname, expname, nFrames
function [params,dirs] = initParamsDirs(filename,params) 

[mainDirname, expname, ext] = fileparts(filename);

if ~(strcmp(ext, '.tif') || strcmp(ext, '.zvi')|| strcmp(ext, '.lsm'))
    error('filename %s not supported',ext);
end

%% Parameters
if ~isfield(params,'pixelSize') || ~isfield(params,'timePerFrame')
    error('pixelSize and timePerFrame are obligatory parameters');
end

if ~isfield(params,'isDx')
    params.isDx = true;
else
    if ~params.isDx
        error('currently supporting only dx, rotate you images');
    end
end

if ~isfield(params,'frameJump')
    params.frameJump = 1;
end

if ~isfield(params,'maxSpeed')
    params.maxSpeed = 90; % um / hr    
end

if ~isfield(params,'fixGlobalMotion')
    params.fixGlobalMotion = false; % correct for bias due to motion
end

if ~isfield(params,'nRois')
    params.nRois = 1; 
end

params.searchRadiusInPixels = ...
    ceil((params.maxSpeed/params.pixelSize)*...
    (params.timePerFrame*params.frameJump/60)); 

params.toMuPerHour = params.pixelSize * 60/(params.timePerFrame*params.frameJump);


if ~isfield(params,'patchSize')
    params.patchSize = ceil(params.patchSizeUm/params.pixelSize); % 15 um in pixels
end

if ~isfield(params,'nBilateralIter')
    params.nBilateralIter = 1;
end

if ~isfield(params,'minClusterArea') % in mu^2
    params.minClusterArea = 5000;
end

if ~isfield(params,'regionMerginParams')
    params.regionMerginParams.P = 0.03;% small P --> more merging
    params.regionMerginParams.Q = 0.005;% large Q --> more merging (more significant than P)
end

if ~isfield(params,'kymoResolution') % jumps of patchSize
    params.kymoResolution.maxDistMu = 180; % um
    params.kymoResolution.min = params.patchSize;
    params.kymoResolution.stripSize = params.patchSize;    
end

params.kymoResolution.nPatches = floor(params.kymoResolution.maxDistMu / params.patchSizeUm);
params.kymoResolution.max = params.kymoResolution.nPatches * params.patchSize;%ceil(params.kymoResolution.maxDistMu/params.pixelSize); % 500 um in pixels

params.strips =  params.kymoResolution.min : params.kymoResolution.stripSize : params.kymoResolution.max;
params.nstrips = length(params.strips);

if ~isfield(params,'maxNFrames')
    params.maxNFrames = 300;
end

if ~isfield(params,'always')
    params.always = false;
end


%% Directories

dirs.main = [mainDirname filesep];
dirs.dirname = [dirs.main expname];
dirs.expname = expname;

% images
dirs.images = [dirs.dirname filesep 'images' filesep];

% MF
dirs.mf = [dirs.dirname filesep 'MF' filesep];
dirs.mfData = [dirs.mf 'mf' filesep];
dirs.mfDataOrig = [dirs.mf 'mfOrig' filesep];
dirs.mfScores = [dirs.mf 'scoresVis' filesep];
dirs.mfBilateral = [dirs.mf 'bilateral' filesep];
dirs.mfVis = [dirs.mf 'mfVis' filesep];

% ROI
dirs.roi = [dirs.dirname filesep 'ROI' filesep];
dirs.roiData = [dirs.roi 'roi' filesep];
dirs.roiVis = [dirs.roi 'vis' filesep];

% Coordination
dirs.coordination = [dirs.dirname filesep 'coordination' filesep];
dirs.coordinationVis = [dirs.coordination filesep 'vis'];

% kymographs
dirs.kymographs = [dirs.main 'kymographs' filesep];
dirs.speedKymograph = [dirs.kymographs 'speed' filesep];
dirs.directionalityKymograph = [dirs.kymographs 'directionality' filesep];
dirs.coordinationKymograph = [dirs.kymographs 'coordination' filesep];

% Healing rate
dirs.healingRate = [dirs.main 'healingRate' filesep];
dirs.segmentation = [dirs.main 'segmentation' filesep];

% motion correction (micrscope repeat error)
dirs.correctMotion = [dirs.main 'correctMotion' filesep];

%% Create local directories
if ~exist(dirs.dirname,'dir')
    mkdir(dirs.dirname);
end

if ~exist(dirs.images,'dir')
    mkdir(dirs.images);
end

if ~exist(dirs.mf,'dir')
    mkdir(dirs.mf);
end

if ~exist(dirs.mfData,'dir')
    mkdir(dirs.mfData);
end

if ~exist(dirs.mfDataOrig,'dir')
    mkdir(dirs.mfDataOrig);
end

if ~exist(dirs.mfScores,'dir')
    mkdir(dirs.mfScores);
end

if ~exist(dirs.mfBilateral,'dir')
    mkdir(dirs.mfBilateral);
end

if ~exist(dirs.mfVis,'dir')
    mkdir(dirs.mfVis);
end

if ~exist(dirs.roi,'dir')
    mkdir(dirs.roi);
end

if ~exist(dirs.roiData,'dir')
    mkdir(dirs.roiData);
end

if ~exist(dirs.roiVis,'dir')
    mkdir(dirs.roiVis);
end

if ~exist(dirs.coordination,'dir')
    mkdir(dirs.coordination);
end

if ~exist(dirs.coordination,'dir')
    mkdir(dirs.coordinationVis);
end


%% Global directories
if ~exist(dirs.kymographs,'dir')
    mkdir(dirs.kymographs);
end

if ~exist(dirs.speedKymograph,'dir')
    mkdir(dirs.speedKymograph);
end

if ~exist(dirs.directionalityKymograph,'dir')
    mkdir(dirs.directionalityKymograph);
end

if ~exist(dirs.coordinationKymograph,'dir')
    mkdir(dirs.coordinationKymograph);
end

if ~exist(dirs.healingRate,'dir')
    mkdir(dirs.healingRate);
end

if ~exist(dirs.segmentation,'dir')
    mkdir(dirs.segmentation);
end

if ~exist(dirs.correctMotion,'dir')
    mkdir(dirs.correctMotion);
end

%% create images in directory
nFrames = arrangeImages(mainDirname,expname,ext,dirs.images);

if ~isfield(params,'nTime') || (params.nTime > (min(nFrames,params.maxNFrames) - 1))
    params.nTime = min(nFrames,params.maxNFrames) - 1;
end

end

%% From stack to image folder
function [nFrames] = arrangeImages(mainDirname,expname,ext,imagesdir)
fname = [mainDirname filesep expname ext];

if ~exist(fname,'file')    
    t = 1;
    while exist([imagesdir sprintf('%03d',t) '.tif'],'file')
        t = t + 1;
    end
    nFrames = t - 1;
    
    if nFrames < 2    
        error('File %s nor images exist',fname);
    end
    return;
end


if (strcmp(ext, '.tif'))
    info = imfinfo(fname);
    nFrames = numel(info);
    for t = 1 : nFrames
        I = imread(fname,t);
        if size(I,3) > 1
            I = I(:,:,1);
        end
        eval(['imwrite(I,''' [imagesdir sprintf('%03d',t) '.tif'''] ',''tif'')']);
    end
else if (strcmp(ext, '.zvi'))
        fname = [mainDirname name '.zvi'];
        data = bfopen(fname);
        images = data{1};
        nFrames = size(images,1);
        for t = 1 : nFrames
            I = images(t,1);
            I = I{:};
            eval(['imwrite(I,''' [imagesdir sprintf('%03d',t) '.tif'''] ',''tif'')']);
        end
    else if (strcmp(ext,'.lsm'))
            fname = [mainDirname name '.lsm'];
            stack = tiffread29(fname);
            nFrames = length(stack);
            for t = 1 : nFrames
                data = stack(t).data;
                if length(data) == 2
                    I = data{2};
                else
                    I = data;
                end
                eval(['imwrite(I,''' [imagesdir sprintf('%03d',t) '.tif'''] ',''tif'')']);
            end
        end
    end
end
end