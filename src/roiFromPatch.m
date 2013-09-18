function [ROI,junk,patch] = roiFromPatch(ind, imSz, patchSz, outputPath, loader)

debug = true;
ind = str2num(ind); % Has to be passed as a string because of the way arguments are passed to compiled matlab
if nargin < 2, imSz = [1472,2048,41,1000]; end
if nargin < 3, patchSz = [64,64,4]; end
if nargin < 4
	outputPath = '/groups/freeman/freemanlab/Janelia/quagga/test/'; % can change this as desired
end
if nargin < 5
	loader = @ahrensLoader;
end

if length(patchSz) == 3
	numPC = 15; % number of sparse PCs to look at in patch
else
	numPC = 5;
end
sparseWeight = 3; % weight on the sparse penalty for patch

% Load patch from data file
[patch,patchRng] = loadPatch(ind,imSz,patchSz,loader);

patch = reshape(patch,prod(patchSz),imSz(end));
if prctile(std(patch,[],2),99) > 0.07 % threshold to decide there is more than noise in this patch
	% Run sparse PCA on data in patch
	patch = bsxfun(@minus,patch,mean(patch,2));
	[W,H] = sparsePCA(patch,sparseWeight,numPC);
	% Split ROI in the same sparse PC that aren't connected, and merge ROI that are
	% in different sparse PCs but significantly overlap in space. This is all within
	% one patch. This will be followed by a step that merges ROIs across different
	% patches
	if debug
		[ROI, junk] = segregateComponents(reshape(W,[patchSz,numPC]));
		ROI  = cellfun(@(x) local2global(x,imSz(1:3),patchRng), ROI,  'UniformOutput', 0);
		junk = cellfun(@(x) local2global(x,imSz(1:3),patchRng), junk, 'UniformOutput', 0);
	else
		ROI = cellfun(@(x) local2global(x,imSz(1:3),patchRng),...
	          	     segregateComponents(reshape(W,[patchSz,numPC])),...
	           	     'UniformOutput', 0);
	end
else
	ROI = {};
	if debug
		junk = {};
	end
end

if debug
	save(fullfile(outputPath,['patch_' num2str(ind)]), 'ROI', 'junk','W','H')
else
	save(fullfile(outputPath,['patch_' num2str(ind)]), 'ROI')
end
