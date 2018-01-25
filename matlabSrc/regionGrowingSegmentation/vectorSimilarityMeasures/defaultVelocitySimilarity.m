% v0 = (y0,x1), v1 = (y1,x1)
% mean of (1) dx = (x0-x1)/max(x0,x1), and (2) dy  = (x0-x1)/max(x0,x1) 
function velSim = defaultVelocitySimilarity(v0,v1)
diffDy = abs(v0(1) - v1(1)) / max(abs(v0(1)),abs(v1(1)));
diffDx = abs(v0(2) - v1(2)) / max(abs(v0(2)),abs(v1(2)));

if ~isnan(diffDy) && ~isnan(diffDx)
    velSim = mean([diffDy,diffDx]);
end

if isnan(diffDy) && isnan(diffDx)
    velSim = inf;
else
    if isnan(diffDy)
        velSim = diffDx;
    else
        if isnan(diffDx)
            velSim = diffDy;        
        end
    end
end
end