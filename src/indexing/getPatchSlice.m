function inds = getPatchSlice(slice,imSz,patchSz)
% Returns a list of indices that gives every patch along a particular slice
% For instance, slice = [0,3,0] would give every patch in the x and z direction
% with y = 3.

assert(length(patchSz)==3)
if length(imSz==4)
	imSz = imSz(1:3);
end
patchNum = arrayfun(@(imDim,patchDim) 2*ceil(imDim/patchDim)-1, imSz, patchSz); 
inds = [];
rng = cell(3,1);
for i = 1:3
	if slice(i) == 0
		rng{i} = 1:patchNum(i);
	else
		rng{i} = slice(i);
	end
end

for i = rng{1}
	for j = rng{2}
		for k = rng{3}
			inds = [inds, patchSub2ind([i,j,k]-1,imSz,patchSz)]; % remember to convert to indexing from zero
		end
	end
end