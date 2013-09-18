function neighbors = ind2patchNeighbors(ind,imSz,patchSz)

if nargin < 2, imSz = [1472,2048,41,1000]; end
if nargin < 3, patchSz = [64,64,4]; end

[~,sub] = ind2patchRng(ind,imSz,patchSz);
neighbors = zeros(3,3,3);
for i = 1:3
	for j = 1:3
		for k = 1:3
			neighbors(i,j,k) = patchSub2ind(sub+[i-2,j-2,k-2],imSz,patchSz);
		end
	end
end