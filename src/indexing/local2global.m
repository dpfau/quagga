function globalROI = local2global(localROI,imSz,patchRng)
% Convert a 3D array of ROI values in one patch into a cell array of sparse
% matrices, one for each slice of the data in the Z direction.
%
% localROI  - array of ROI values in a patch
% imSz      - size of full image
% patchRng  - cell array of indices that make up the patch
%
% globalROI - cell array of ROI values in global coordinates

for i = 1:3
	assert(size(localROI,i)==(diff(patchRng{i})+1),['Why is one of these ' num2str(size(localROI,i)) ' and the other ' (diff(patchRng{i}+1)+1) '?'])
end

globalROI = cell(imSz(3),1);
for i = 1:imSz(3)
    globalROI{i} = sparse([],[],[],imSz(1),imSz(2));
end

patchSz = size(localROI);
for i = 1:size(localROI,3)
    globalROI{patchRng{3}(1)+i-1}(patchRng{1}(1):patchRng{1}(2),patchRng{2}(1):patchRng{2}(2)) = localROI(:,:,i);
end