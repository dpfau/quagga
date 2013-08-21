function [x,y,z] = numPatch(imSz,patchSz)
% Simple utility to get the total number of patches for a given image size and patch size
nPatches = arrayfun(@(imDim,patchDim) 2*ceil(imDim/patchDim)-1, imSz, patchSz);
if nargout == 1 % give the total number
	x = prod(nPatches);
elseif nargout == 3 % give the number along each dimension
	x = nPatches(1);
	y = nPatches(2);
	z = nPatches(3);
else 
	error('Not a valid number of output arguments');
end