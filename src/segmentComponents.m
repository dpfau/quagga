function [ROI,junk] = segmentComponents(spatialPC, patchSz, patch)
% Uses normalized cuts library of Cour, Yu and Shi
% (www.timotheecour.com/software/ncut/ncut.html)
% to separate out ROI from background in the results
% of sparse PCA, then uses spatial crossvalidation
% to pick out which segments are neurons and which
% segments are junk.

if ndims(patch) > 2
	patch = reshape(patch,numel(patch)/size(patch,ndims(patch)),size(patch,ndims(patch)));
end
addpath('~/Documents/Code/Ncut_9') % change as appropriate
[nSpatial,nPC] = size(spatialPC);
nTemporal = size(patch,2);
nSeg = 6; % number of segments

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
		spatialSegments(SegLabel(:,i)==j,sub2ind([nPC,nSeg],i,j)) = spatialPC(SegLabel(:,i)==j,i);
	end
end
temporalPC = pinv(spatialSegments)*patch; % Overall least squares solution. We're going to try a chi-squared test approach instead of a 
holdOneOutTemporalPC = zeros([nPC*nSeg-1,size(patch,2),nPC,nSeg]); % The least squares solutions leaving out one spatial segment at a time
residual = spatialSegments*temporalPC - patch;

for i = 1:nPC
	for j = 1:nSeg
		holdOneOutSpatialSegment = spatialSegments(:,[1:sub2ind([nPC,nSeg],i,j)-1 sub2ind([nPC,nSeg],i,j)+1:end]);
		holdOneOutTemporalPC = pinv(holdOneOutSpatialSegment)*patch;
		holdOneOutResidual = holdOneOutSpatialSegment*holdOneOutTemporalPC - patch;
	end
end
keyboard

%%
% Merge together overlapping segments

