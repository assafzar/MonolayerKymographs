function [] = whKymographs(params,dirs)

params.always = false;

params.xStepMinutes = 60;
params.yStepUm = 50;
params.yMaxUm = params.kymoResolution.maxDistMu;
params.fontsize = 24;

fprintf('start kymographs\n');
close all;
generateSpeedKymograph(params,dirs);
generateDirectionalMigrationKymograph(params,dirs);
generateCoordinatedMigrationKymograph(params,dirs);

close all;
end

function [] = generateSpeedKymograph(params,dirs)

speedKymographFname = [dirs.speedKymograph dirs.expname '_speedKymograph.mat'];

if exist(speedKymographFname,'file') && ~params.always
    return;
end

speedKymograph = nan(params.nstrips,params.nTime);
speedKymographX = nan(params.nstrips,params.nTime);
speedKymographY = nan(params.nstrips,params.nTime);
for t = 1 : params.nTime
    roiFname = [dirs.roiData sprintf('%03d',t) '_roi.mat']; % ROI
    mfFname = [dirs.mfData sprintf('%03d',t) '_mf.mat']; % dxs, dys
    
    load(roiFname);
    load(mfFname);
    
    speed = sqrt(dxs.^2 + dys.^2);
    DIST = bwdist(~ROI);
    
    for d = 1 : params.nstrips
        inDist = ...
            (DIST > (params.strips(d)-params.kymoResolution.stripSize)) & ...
            (DIST < params.strips(d)) & ...
            ~isnan(speed);
        speedInStrip = speed(inDist);
        speedKymograph(d,t) = mean(speedInStrip);
        % For directional migration
        speedInStripX = dxs(inDist);
        speedKymographX(d,t) = mean(abs(speedInStripX));
        speedInStripY = dys(inDist);
        speedKymographY(d,t) = mean(abs(speedInStripY));
    end
end

% Translate to mu per hour
speedKymograph = speedKymograph .* params.toMuPerHour;

save(speedKymographFname,'speedKymograph','speedKymographX','speedKymographY');

metaData.fname = [dirs.speedKymograph dirs.expname '_speedKymograph.jpg'];
metaData.fnameFig = [dirs.speedKymograph dirs.expname '_speedKymograph.fig'];
metaData.caxis = [0 60];

params.caxis = metaData.caxis;
params.fname = metaData.fname;

plotKymograph(speedKymograph,params);

end

function [] = generateDirectionalMigrationKymograph(params,dirs)

directionalityKymographFname = [dirs.directionalityKymograph dirs.expname '_directionalityKymograph.mat'];

if exist(directionalityKymographFname,'file') && ~params.always
    return;
end


load([dirs.speedKymograph dirs.expname '_speedKymograph.mat']); % 'speedKymograph','speedKymographX','speedKymographY';
if params.isDx
    directionalityKymograph = speedKymographX ./ speedKymographY;
else
    directionalityKymograph = speedKymographY ./ speedKymographX;
end

save(directionalityKymographFname,'directionalityKymograph');

metaData.fname = [dirs.directionalityKymograph dirs.expname '_directionalityKymograph.jpg'];
metaData.fnameFig = [dirs.directionalityKymograph dirs.expname '_directionalityKymograph.fig'];
metaData.caxis = [0 8];
% metaData.caxis = [0.9 1.4]; % Zhuo
metaData.caxis = [0 10]; % Georgio

% plotKymograph(directionalityKymograph,metaData,params);

params.caxis = metaData.caxis;
params.fname = metaData.fname;

plotKymograph(directionalityKymograph,params);
end


%%
function [] = generateCoordinatedMigrationKymograph(params,dirs)
coordinationKymographFname = [dirs.coordinationKymograph dirs.expname '_coordinationKymograph.mat'];

if exist(coordinationKymographFname,'file') && ~params.always
    return;
end

coordinationKymograph = nan(params.nstrips,params.nTime);
for t = 1 : params.nTime
    roiFname = [dirs.roiData sprintf('%03d',t) '_roi.mat']; % ROI
    coordinationFname = [dirs.coordination sprintf('%03d',t) '_coordination.mat']; % ROIclusters
    
    load(roiFname);
    load(coordinationFname);
        
    DIST = bwdist(~ROI);
    
    for d = 1 : params.nstrips        
        inDist = ((DIST > (params.strips(d)-params.kymoResolution.stripSize)) & (DIST < params.strips(d))) & ~isnan(ROIclusters);
                
        coordinationInStrip = ROIclusters(inDist);
        coordinationKymograph(d,t) = sum(coordinationInStrip)/length(coordinationInStrip);
    end
end

save(coordinationKymographFname,'coordinationKymograph');

metaData.fname = [dirs.coordinationKymograph dirs.expname '_coordinationKymograph.jpg'];
metaData.fnameFig = [dirs.coordinationKymograph dirs.expname '_coordinationKymograph.fig'];
metaData.caxis = [0 1];

% plotKymograph(coordinationKymograph,metaData,params);

params.caxis = metaData.caxis;
params.fname = metaData.fname;

plotKymograph(coordinationKymograph,params);
end