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
% holdOut = rand(nSpatial,1)<0.2; % drop out 20% of pixels
spatialSegments = zeros(nSpatial,nPC*nSeg);
for i = 1:nPC
	for j = 1:nSeg
		spatialSegments(SegLabel(:,i)==j,sub2ind([nPC,nSeg],i,j)) = spatialPC(SegLabel(:,i)==j,i);
	end
end
temporalPC = pinv(spatialSegments)*patch; % Overall least squares solution. We're going to try a chi-squared test approach instead of a 
holdOneOutTemporalPC = zeros([nPC*nSeg-1,size(patch,2),nPC,nSeg]); % The least squares solutions leaving out one spatial segment at a time
residual = spatialSegments*temporalPC - patch;
loglik = gaussianLoglik(residual'); 
% log likelihood of the residual, assuming each row is independenty Gaussian distributed with different variances. 
% Could go for estimating the full covariance, but would need to introduce some smoothing due to lack of data.

% p values for the null hypothesis that a particular spatial segment is superfluous, so the difference of 
% log likelihoods should be chi-squared distributed.
p_val = zeros(nPC,nSeg);
dof = zeros(nPC,nSeg);
doll = zeros(nPC,nSeg);
diffOfVar = zeros(nPC,nSeg);
diffOfResid = zeros(nPC,nSeg);
for i = 1:nPC
	for j = 1:nSeg
		holdOneOutSpatialSegment = spatialSegments(:,[1:sub2ind([nPC,nSeg],i,j)-1 sub2ind([nPC,nSeg],i,j)+1:end]);
		holdOneOutTemporalPC = pinv(holdOneOutSpatialSegment)*patch;
		holdOneOutResidual = holdOneOutSpatialSegment*holdOneOutTemporalPC - patch;
		% Get a p-value from the likelihood ratio test, assuming we're in the asymptotic limit 
		% where the log of the likelihood ratio is chi^2 distributed with as many degrees of
		% freedom as there are more parameters in the nested model.
		diffOfLoglik = 2*(loglik - gaussianLoglik(holdOneOutResidual'));
		pval(i,j) = 1 - chi2cdf(diffOfLoglik,nnz(SegLabel(:,i)==j));
		dof(i,j) = nnz(SegLabel(:,i)==j);
		doll(i,j) = diffOfLoglik;
		diffOfResid(i,j) = 1/2*sum(sum(residual.*(residual/diag(var(residual,[],1)))))-1/2*sum(sum(holdOneOutResidual.*(holdOneOutResidual/diag(var(holdOneOutResidual,[],1)))));
		diffOfVar(i,j) = sum(log(var(holdOneOutResidual,[],1)./var(residual,[],1)));
	end
end
keyboard

%%
% Merge together overlapping segments

function ll = gaussianLoglik(x)

xvar = var(x,[],2);
ll = -1/2*sum(sum(x.*(diag(xvar)\x))) - size(x,2)/2*sum(log(xvar));
