function localROI = global2local(globalROI,imSz,patchSz,patchRng)

localROI = zeros(patchSz);
for j = 1:diff(patchRng{3})+1
	localROI(:,:,j) = globalROI{j+patchRng{3}(1)-1}(patchRng{1}(1):patchRng{1}(2),patchRng{2}(1):patchRng{2}(2));
end