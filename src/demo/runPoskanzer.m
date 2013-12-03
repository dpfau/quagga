%% Set relevant paths
homePath   = '/hpc/stats/users/dbp2112/Janelia';
dataPath   = fullfile(homePath,'data');
resultPath = fullfile(homePath,'results');
logPath    = fullfile(homePath,'logs');
quaggaPath = fullfile(homePath,'quagga');
dataset    = 'kira';
addpath(genpath(quaggaPath));

config.neuronSz = [32,32,1]; % size of the average neuron, in pixels
config.patchSz = [64,64,1];
config.patchLoader = @(x,y,z) tiffLoader(x,y,z,fullfile(dataPath,dataset));
config.stdThresh = 0; % Just let everything through
config.stdPrctile = 50; % So long as stdThresh is zero, this doesn't matter
config.dff = true; % flag to indicate whether or not to compute df/f on a patch
config.saveROI = true;
config.spamsPath = fullfile(homePath,'../spams-matlab');
config.TIFF = true;

runQuaggaTorque