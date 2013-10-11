%% Demo of a semi-automated pipeline, where patch centers are specified ahead of time.

%% Set relevant paths
homePath   = '/hpc/stats/users/dbp2112/Janelia';
dataPath   = fullfile(homePath,'data');
resultPath = fullfile(homePath,'results');
logPath    = fullfile(homePath,'logs');
quaggaPath = fullfile(homePath,'quagga');
dataset    = 'an216166_2';
addpath(genpath(quaggaPath));

config.neuronSz = [10,10,1]; % size of the average neuron, in pixels
config.patchSz = [20,20,1];
config.patchLoader = @(x,y,z) tiffLoader(x,y,z,fullfile(dataPath,dataset));
config.stdThresh = 0; % Just let everything through
config.stdPrctile = 50; % So long as stdThresh is zero, this doesn't matter
config.dff = false;

centers = [265, 295;...
           225, 350;...
           400, 240;...
           270, 245;...
           190, 125;...
           200, 290;...
           340, 380;...
           145, 280;...
           410, 280;..
            45, 345];

ROI = cell(size(centers,1),1);
for i = 1:size(centers,1)
	ROI{i} = roiFromPatch([centers(i,:)-floor(config.patchSz(1:2)/2),1],config);
end