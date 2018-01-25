% v0 = (y0,x1), v1 = (y1,x1)
% Euclidean distance normalized by the max vector magnitude
% d2(v0,v1)/max(|v1|_2,|v2|_2);
function velSim = vecEuclideanSimilarity(v0,v1)
d0 = sqrt(v0(1)^2 + v0(2)^2);
d1 = sqrt(v1(1)^2 + v1(2)^2);
velSim = sqrt((v0(1) - v1(1))^2 + (v0(2) - v1(2))^2)/max(d0,d1);    
end