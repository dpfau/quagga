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
roiIdx = true(1,nPC*nSeg); % Index of which spatial segments are ROIs

%% 
% Segment each sparse PC by normalized cuts
segLabel = zeros(nSpatial,nPC); % note the 'squeeze' here, because patchSz might have a superfluous entry due to compatibility between 2D and 3D data
for i = 1:nPC
	I = reshape(spatialPC(:,i),squeeze(patchSz(1:end-1)));
	segLabel(:,i) = vec(NcutImage(I,nSeg));
end

%%
% Group the different segments into a single matrix
spatialSegments = zeros(nSpatial,nPC*nSeg);
for i = 1:nPC
	for j = 1:nSeg
		spatialSegments(segLabel(:,i)==j,sub2ind([nPC,nSeg],i,j)) = spatialPC(segLabel(:,i)==j,i);
	end
end

%%
% Cut out any segments where fewer than 10 pixels are above 0.1% of the higher end (here, 95th percentile) 
% of pixel magnitudes in the spatial PCs
threshold = 0.001*prctile(abs(spatialPC(:)),95);
for i = 1:nPC*nSeg
	if nnz(abs(spatialSegments(:,i))>threshold) < 10
		roiIdx(i) = 0;
	end
end

%%
% Drop out a fraction of pixels, try to predict them from the segmented
% sparse PCs, if prediction is not significantly above chance, throw out
% the segment as junk
testIdx = rand(nSpatial,1)<0.2; % drop out 20% of pixels
temporalPC = pinv(spatialSegments(~testIdx,roiIdx))*patch(~testIdx,:); % Overall least squares solution. We're going to try a chi-squared test approach instead of a 
testResidual = spatialSegments(testIdx,roiIdx)*temporalPC - patch(testIdx,:);

residPower = zeros(nPC,nSeg);
for i = 1:nPC
	for j = 1:nSeg
		idx = sub2ind([nPC,nSeg],i,j);
		if roiIdx(idx)
			holdOneOutSpatialSegment = spatialSegments(:,[1:idx-1 idx+1:end]);
			holdOneOutTemporalPC = pinv(holdOneOutSpatialSegment(~testIdx,:))*patch(~testIdx,:);
			holdOneOutTestResidual = holdOneOutSpatialSegment(testIdx,:)*holdOneOutTemporalPC - patch(testIdx,:);
			residPower(i,j) = norm(holdOneOutTestResidual,'fro').^2;
		else
			residPower(i,j) = norm(testResidual,'fro').^2;
		end
	end
end
keyboard

%%
% Merge together overlapping segments

