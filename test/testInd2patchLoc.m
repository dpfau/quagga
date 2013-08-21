pSz = [64,64,4]; % test patch size
iSz = [400,150,7]; % test image size

nPatch = numPatch(iSz,pSz);

for i = 1:nPatch
	img = zeros(iSz);
	patchRng = ind2patchLoc(i,iSz,pSz);
	img(patchRng{:}) = 1;
	for j = 1:iSz(3)
		subplot(ceil(sqrt(iSz(3))),ceil(sqrt(iSz(3))),j)
		imagesc(img(:,:,j),[0 1])
		axis image
	end
	drawnow
	pause(0.2)
end