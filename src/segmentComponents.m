function [ROI,junk] = segmentComponents(spatialPC, patchSz, patch)
% Uses normalized cuts library of Cour, Yu and Shi
% ()
% to separate out ROI from background in the results
% of sparse PCA, then uses spatial crossvalidation
% to pick out which segments are neurons and which
% segments are junk.

addpath('~/Documents/Code/Ncut_9') % change as appropriate
[nSpatial,nPC] = size(spatialPC);
nSeg = 5; % number of segments

%% 
% Segment each sparse PC by normalized cuts
SegLabel = zeros(nSpatial,nPC); % note the 'squeeze' here, because patchSz might have a superfluous entry due to compatibility between 2D and 3D data
for i = 1:nPC
	I = reshape(spatialPC(:,i),squeeze(patchSz(1:end-1)));
	SegLabel(:,i) = vec(NcutImage(I,nSeg));
end

%%
% Drop out a fraction of pixels, try to predict them from the segmented
% sparse PCs, if prediction is not significantly above chance, throw out
% the segment as junk
holdOut = rand(nSpatial,1)<0.2; % drop out 20% of pixels
spatialSegments = zeros(nSpatial,nPC*nSeg);
for i = 1:nPC
	for j = 1:nSeg
		spatialSegments(:,sub2ind([nPC,nSeg],i,j)) = SegLabel(:,i)==j;
	end
end
temporalPC = pinv(spatialSegments(~holdOut,:))*patch; % least-squares approximation of the patch using the combined segments across PCs
% predict held-out pixels
heldOutPrediction = spatialSegments(holdOut,:)*temporalPC;

%%
% Merge together overlapping segments