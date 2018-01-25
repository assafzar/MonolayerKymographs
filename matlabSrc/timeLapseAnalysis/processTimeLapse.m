function [] = processTimeLapse(filename,params) % pixelSize, timePerFrame, mainDirname, exp, initParams

[params,dirs] = initParamsDirs(filename,params); % set missing parameters, create output directories

whLocalMotionEstimation(params,dirs); % velocity fields estimation
whTemporalBasedSegmentation(params,dirs); % cellular-background segmentation
whCorrectGlobalMotion(params,dirs); % correction of stage-location errors
whSegmentationMovie(params,dirs); % segmentation movie
whHealingRate(params,dirs); % wound healing rate over time
whCoordination(params,dirs); % coordinated clusters
whKymographs(params,dirs); % spatiotemporal kymographs
end