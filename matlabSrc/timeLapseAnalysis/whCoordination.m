function [] = whCoordination(params,dirs)

time = 1 : params.nTime;

fprintf('starting coordination\n');

for t = time   
    coordinationFname = [dirs.coordination pad(t,3) '_coordination.mat'];
    
    if exist(coordinationFname,'file') && ~params.always
        continue;
    end
    
    mfFname = [dirs.mfData pad(t,3) '_mf.mat']; % dxs, dys
        
    load(mfFname);
    
    [clusters,ROIclusters,clustersMask,outImgDx1,outImgDy1] = doRegionGrowingSegmentCoordination(dxs,dys,params);    
    
    save(coordinationFname,'clusters','ROIclusters','clustersMask','outImgDx1','outImgDy1');
end

end

