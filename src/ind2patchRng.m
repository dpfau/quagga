function [patchRng, patchSub] = ind2patchRng(ind,imSz,patchSz)
% Given the index for a cluster array job, convert that index into an x, y and z range
% for loading in a patch from a full image. If no patch size is provided, assumes the 
% default patch size of [64,64,4]

ind = ind-1; % when calling the script, index from 1, but for modulo arithmetic, easier to index from 0
if nargin < 3
	patchSz = [64,64,4];
end

% The total number of patches along each dimension. 
% Since each patch is halfway over from its neighbor, there are 2*ceil(imSize/patchSize)-1
% patches along each dimension, where imSize is the size of the whole image along that
% dimension and patchSize is the size of the patch along that dimension
patchNum = arrayfun(@(imDim,patchDim) 2*ceil(imDim/patchDim)-1, imSz, patchSz); 

% Convert the global index of a patch into an index for each dimension. 
patchSub = [floor(ind/patchNum(2)/patchNum(3)), mod(floor(ind/patchNum(3)),patchNum(2)),mod(ind,patchNum(3))];

% Convert the index in each dimension into a range to extract from the image. If the patch falls over the edge
% of the image be sure to cut off the range.
patchRng = arrayfun(@(ind,sz,isz) [(ind*sz/2+1), min((ind+2)*sz/2,isz)],  patchSub, patchSz, imSz, 'UniformOutput', 0); 