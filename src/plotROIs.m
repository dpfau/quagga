function plotROIs(ind,staticImg,imSz,patchSz)

if nargin < 2
	load('/Users/pfau/Documents/Research/Janelia/data/Ahrens Group/save_stack_av_fishN7.mat'); % Change this to the appropriate stack file as necessary
	staticImg = permute(stack_av,[2 1 3]);
end
if nargin < 3, imSz = [1472,2048,41,1000]; end
if nargin < 4, patchSz = [64,64,4]; end
patchRng = ind2patchRng(ind,imSz(1:3),patchSz);

if ~exist(['patch_' num2str(ind) '.mat'],'file')
	roiFromPatch(num2str(ind));
end

load(['patch_' num2str(ind) '.mat'])
patchImg = zeros([patchSz,3]);
patchImg(:,:,:,3) = mat2gray(staticImg(patchRng{1}(1):patchRng{1}(2), patchRng{2}(1):patchRng{2}(2), patchRng{3}(1):patchRng{3}(2)));

colormap gray
for i = 1:length(ROI)
	patchImg(:,:,:,1) = mat2gray(global2local(ROI{i},imSz,patchSz,patchRng));
	for j = 1:4
		subplot(2,2,j)
		image(squeeze(patchImg(:,:,j,:)))
		axis image
		title('ROI')
	end
	pause
end

for i = 1:length(junk)
	patchImg(:,:,:,1) = mat2gray(global2local(junk{i},imSz,patchSz,patchRng));
	for j = 1:4
		subplot(2,2,j)
		image(squeeze(patchImg(:,:,j,:)))
		axis image
		title('junk')
	end
	pause
end