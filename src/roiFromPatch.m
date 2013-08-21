function roiFromPatch(patchNum)

imSz = [1472,2048,41,1000];
patchSz = [64,64,4];
dataPath = '/groups/ahrens/ahrenslab/Misha/data_fish7_sharing_sample/data_for_sharing_01/12-10-05/Dre_L1_HuCGCaMP5_0_20121005_154312.corrected.processed';
outputPath = '.'; % can change this as desired

numPC = 15; % number of sparse PCs to look at in patch
sparseWeight = 0.2; % weight on the sparse penalty for patch

% Load patch from data file
[patch,patchRng] = loadPatch(patchNum,imSz,patchSz,dataPath);
% Run sparse PCA on data in patch
[W,H] = sparsePCA(reshape(patch,prod(patchSz),imSz(4)),sparseWeight,numPC);
% Split ROI in the same sparse PC that aren't connected, and merge ROI that are
% in different sparse PCs but significantly overlap in space. This is all within
% one patch. This will be followed by a step that merges ROIs across different
% patches
ROI = cellfun(@(x) local2global(x,imSz(1:3),patchRng),...
              segregateComponents(reshape(W,[patchSz,numPC])),...
              'UniformOutput', 0);

save(fullfile(outputPath,['patch_' num2str(patchNum)]), ROI)