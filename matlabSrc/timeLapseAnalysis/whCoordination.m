function [] = whCoordination(params,dirs)

time = 1 : params.nTime;

fprintf('starting coordination\n');

for t = time   
    coordinationFname = [dirs.coordination sprintf('%03d',t) '_coordination.mat'];
    
    if exist(coordinationFname,'file') && ~params.always
        continue;
    end
    
    mfFname = [dirs.mfData sprintf('%03d',t) '_mf.mat']; % dxs, dys
        
    load(mfFname);
    
    [clusters,ROIclusters,clustersMask,outImgDx1,outImgDy1] = doRegionGrowingSegmentCoordination(dxs,dys,params);    
    
    % Visualization
    I = imread([dirs.images sprintf('%03d',t) '.tif']);
    outFname = [dirs.coordination sprintf('%03d',t) '_coordVis.jpg'];
    visualizeCoordination(I,ROIclusters,outFname); % extraColor - default is 100 graylevel
    close all;
    
    save(coordinationFname,'clusters','ROIclusters','clustersMask','outImgDx1','outImgDy1');
end

end

