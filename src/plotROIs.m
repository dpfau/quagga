function plotROIs(ind,imSz,patchSz)

if nargin < 2, imSz = [1472,2048,41,1000]; end
if nargin < 3, patchSz = [64,64,4]; end
patchRng = ind2patchRng(ind,imSz(1:3),patchSz);

if ~exist(['patch_' num2str(ind) '.mat'],'file')
	roiFromPatch(num2str(ind));
end

load(['patch_' num2str(ind) '.mat'])

colormap gray
for i = 1:length(ROI)
	patch = global2local(ROI{i},imSz,patchSz,patchRng);
	for j = 1:4
		subplot(2,2,j)
		imagesc(patch(:,:,j),[-1 1])
		axis image
		title('ROI')
	end
	pause
end

for i = 1:length(junk)
	patch = global2local(junk{i},imSz,patchSz,patchRng);
	for j = 1:4
		subplot(2,2,j)
		imagesc(patch(:,:,j),[-1 1])
		axis image
		title('junk')
	end
	pause
end