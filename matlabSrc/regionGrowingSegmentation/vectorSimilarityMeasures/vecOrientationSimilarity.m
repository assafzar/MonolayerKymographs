% v0 = (y0,x1), v1 = (y1,x1)
% cosine similarity between the two vectors 
function velSim = vecOrientationSimilarity(v0,v1)
velSim = pdist(v0',v1','cosine');
if isnan(velSim)
    velSim = inf;
end
end