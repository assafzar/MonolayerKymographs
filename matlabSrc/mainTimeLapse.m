%% mainTimeLapse
% Processess a monolayer miration onset spatiotemporal dynamics

% Input:
%   filename - input time lapse
%   params - parameters for processing, default values set for Angeles_20150402_14hrs_5min_AA01_7.tif

% Example:
%   fname = 'C:\Assaf\Research\MonolayerDynamics\data\SpatiotemporalExample\Angeles_20150402_14hrs_5min_AA01_7.tif';
%   mainTimeLapse(fname);

% Assaf Zaritsky, Jan. 2018 (implemented for the NEUBIAS training school)

function mainTimeLapse(filename,params)

p = inputParser;
p.addRequired('filename', @(x)validateattributes(x,{'char'},{'nonempty'}));
p.addOptional('params', @(x)validateattributes(x,{'struct'},{'nonempty'}));

if nargin < 2
    pixelSize = 1.267428; % um    
    params = setDefaultParams(pixelSize);
else
    params.pixelSize = 1.267428;
end

processTimeLapse(filename, params);
close all;
end