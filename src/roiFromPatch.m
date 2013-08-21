function roiFromPatch(patchNum)

imSz = [1472,2048,41,1000];
patchSz = [64,64,4];
dataPath = '/groups/ahrens/ahrenslab/Misha/data_fish7_sharing_sample/data_for_sharing_01/12-10-05/Dre_L1_HuCGCaMP5_0_20121005_154312.corrected.processed';

numPC = 15; % number of sparse PCs to look at in patch
sparseWeight = 0.2; % weight on the sparse penalty for patch

% Load patch from data file
patch = loadPatch(patchNum,imSz,patchSz,dataPath);
% Run sparse PCA on data in patch
[W,H] = sparsePCA(patch,sparseWeight,numPC);
% Split ROI in the same sparse PC that aren't connected, and merge ROI that are
% in different sparse PCs but significantly overlap in space. This is all within
% one patch. This will be followed by a step that merges ROIs across different
% patches
 cellfun(@(x) local2global(x,cellfun(@(x,y)x*y,np,pdim),cellfun(@(x,y)(x-1)*y,{i,j,k},pdim)),...
                segregateComponents(reshape(W,[patchSz,numPC])),...
                'UniformOutput', 0);