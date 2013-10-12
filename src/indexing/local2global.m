function globalROI = local2global(localROI,imSz,patchRng)
% Convert a 3D array of ROI values in one patch into a list of
% nonzero indices, with (x,y,z) values along the first three
% columns and the pixel value along the fourth.
%
% localROI  - array of ROI values in a patch
% imSz      - size of full image
% patchRng  - cell array of indices that make up the patch
%
% globalROI - cell array of ROI values in global coordinates

patchSz = size(localROI);
for i = 1:length(patchSz)
	assert(patchSz(i)==(diff(patchRng{i})+1))
end
if length(patchSz)==2
    assert(patchRng{3}(1)==1 && patchRng{3}(2)==1);
end

idx = find(localROI);
[x,y,z] = ind2sub(patchSz,idx);
globalROI = [x+patchRng{1}(1)-1,y+patchRng{2}(1)-1,z+patchRng{3}(1)-1,localROI(idx)];