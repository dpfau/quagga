function plotPerim(ind,imSz,patchSz)

if ~exist(['patch_' num2str(ind) '.mat'],'file')
	roiFromPatch(num2str(ind));
end

load(['patch_' num2str(ind) '.mat'])

if nargin < 2, imSz = [1472,2048,41]; end
if nargin < 3, patchSz = [64,64,4]; end
	
patchRng = ind2patchRng(ind,imSz,patchSz);
numPatch = length(ROI);
patch = zeros([patchSz,numPatch]);

for i = 1:numPatch
	for j = 1:diff(patchRng{3})+1
		patch(:,:,j,i) = ROI{i}{j+patchRng{3}(1)-1}(patchRng{1}(1):patchRng{1}(2),patchRng{2}(1):patchRng{2}(2));
	end
end

for i = 1:numPatch
	S = zeros(patchSz);
	for j = 1:4
		S(:,:,j) = bwmorph(patch(:,:,j,i),'dilate');
	end
	perimAndRoi = zeros([patchSz, 3]);
	perimAndRoi(:,:,:,1) = logical(patch(:,:,:,i));
	perimAndRoi(:,:,:,2) = S;
	perimAndRoi = permute(perimAndRoi,[1 2 4 3]);
	for j = 1:4
		subplot(2,2,j)
		image(perimAndRoi(:,:,:,j))
		axis image
	end
	drawnow
	pause(3)
end