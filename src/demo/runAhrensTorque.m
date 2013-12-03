%% Jeremy, you change these as needed
homePath   = '/hpc/stats/users/dbp2112/Janelia';
dataPath   = '/hpc/astrostats/stats/users/dbp2112';
resultPath = fullfile(homePath,'results');
logPath    = fullfile(homePath,'logs');
quaggaPath = fullfile(homePath,'quagga');

dataset    = 'light_sheet_data';
addpath(genpath(quaggaPath));

%% These should be set correctly
config.imSz = [1472,2048,41,1000];
config.neuronSz = [15,15,2]; % size of the average neuron, in pixels
config.patchSz = [64,64,4];
config.patchLoader = @ahrensLoader;
config.stdThresh = 0.07;
config.stdPrctile = 99;
config.dff = false; % df/f has already been computed on this data
config.saveROI = true;
config.savePath = fullfile(resultPath,dataset);
config.spamsPath = fullfile(homePath,'spams-matlab');
config.slice = 10;
if config.slice
	config.inds = getPatchSlice([0 0 config.slice],config.imSz(1:end-1),config.patchSz);
end
configPath = fullfile(resultPath,dataset,'config.mat');
save(configPath,'config'); % save the config struct so that it can be loaded by nodes on the cluster

runQuaggaTorque