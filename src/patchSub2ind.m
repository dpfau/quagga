function ind = patchSub2ind(sub,imSz,patchSz)
% Inverts ind2patchRng - given an (x,y,z) subscript for a patch location,
% indexed from 0 (makes modulo arithmetic easier), converts it into a global
% index

if nargin < 2, imSz = [1472,2048,41]; end
if nargin < 3, patchSz = [64,64,4]; end

patchNum = arrayfun(@(imDim,patchDim) 2*ceil(imDim/patchDim)-1, imSz, patchSz); 
for i = 1:3
	assert(patchNum(i)>sub(i))
end

ind = sub(1)*patchNum(2)*patchNum(3) + sub(2)*patchNum(3) + sub(3);

ind = ind+1; % finally, switch to index-from-1