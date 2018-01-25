%% doRegionGrowingSegmentCoordination
% Implementation of the region growing segmentation algorithm (Nock & Nielsen, Statistical Region Merging, 2004) 
% for the purpose of clustering spatially consistant velocity-field regions
% (Zaritsky et al., Seeds of locally aligned motion and stress coordinate a collective cell migration, 2015)

% Assaf Zaritsky, Jan. 2018 (implemented for NEUBIAS training school)

function [clusters,ROIclusters,clustersMask,outImgDx1,outImgDy1] = doRegionGrowingSegmentCoordination(dxs,dys,params)

assert((size(dxs,1) == size(dys,1)) & (size(dxs,2) == size(dys,2)));

if nargin < 3            
    params.pixelSize = 1.267428; % um
    params.patchSize = 15.0; % um
    params.nBilateralIter = 1;
    
    % for region growing segmentation
    params.regionMerginParams.P = 0.03;% small P --> more merging
    params.regionMerginParams.Q = 0.005;% large Q --> more merging (more significant than P)
end

sizeXY = size(dxs);

[filterMfsDxs] = bilateralFiltering(dxs,params.patchSize,params.nBilateralIter);
[filterMfsDys] = bilateralFiltering(dys,params.patchSize,params.nBilateralIter);

[outImgDx, outImgDy, unionFind] = RegionMerginSegmentationMF(filterMfsDxs,filterMfsDys,params.regionMerginParams);
[parents] = parentsMap(unionFind,outImgDx);
parents(isnan(outImgDx)) = nan;
[smallY,smallX] = size(parents);

outImgDx1 = imresize(outImgDx,sizeXY,'nearest');
outImgDy1 = imresize(outImgDy,sizeXY,'nearest');
parents1 = imresize(parents,sizeXY,'nearest');

%% Filter small clusters
clusters.nclusters = 0;
clusters.allClusters = {};
ROIclusters = false(size(parents1));
clustersMask = false(size(parents1));
for ind = 1 : smallY * smallX
    cluster = parents1 == ind;
    if sum(cluster(:)) > (params.minClusterArea / (params.pixelSize * params.pixelSize))
        dxc = mean(outImgDx1(cluster));
        dyc = mean(outImgDy1(cluster));
        cluster = bwfill(cluster,'holes');
        clusters.nclusters = clusters.nclusters + 1;
        clusters.allClusters{clusters.nclusters} = cluster;
        ROIclusters(cluster) = true;
        clustersMask(bwperim(cluster)) = true;
        % "fill holes" with correct values
        outImgDx1(cluster) = dxc;
        outImgDy1(cluster) = dyc;
    end
end

ROIclusters = imfill(ROIclusters,'holes');
end


%% Bilateral filtering - reduces resolution!
function [filterMfs] = bilateralFiltering(mfs,patchSize,nIterations)
maxVelocityOrig = max(abs(mfs(:)));
mfs =  mfs + maxVelocityOrig;
maxVelocityNew = max(mfs(:));
mfs =  mfs./maxVelocityNew;
lowResMfs = imresize(mfs,1.0/patchSize);
nanMask = isnan(lowResMfs);
lowResMfs = max(lowResMfs,0);
lowResMfs = min(lowResMfs,1);

% bilateral filtering
filterMfs = lowResMfs;
for i = 1 : nIterations
    filterMfs = bfilter2(filterMfs,2);
end

filterMfs = filterMfs .* maxVelocityNew;
filterMfs = filterMfs - maxVelocityOrig;

filterMfs(nanMask) = nan;

% In case we want to go back to orinigal resolution
% newMfs = imresize(mfs,size(mfs));

end

%% For coordination
function [parents] = parentsMap(unionFind,I)
[sizeY,sizeX] = size(I);
parents = zeros(size(I));

for y = 1 : sizeY
    for x = 1 : sizeX
        parent = unionFind(y,x).parent;
        parents(y,x) = (parent.y-1) * sizeX + parent.x;
    end
end
end


