function plotAllROIs(ROI,img,z,xRng,yRng)
% Plot all ROIs through a particular image in a z stack

if nargin < 3, z = 1; end
if nargin < 4, xRng = [1, size(img,1)]; end
if nargin < 5, yRng = [1, size(img,2)]; end
assert(diff(xRng)+1==size(img,1))
assert(diff(yRng)+1==size(img,2))

imSz = size(img);
if length(imSz) == 4
	roiSz = imSz(1:3);
else
	roiSz = [imSz(1:2), 1];
end
roiLen = length(ROI);
roiMat = roi2matrix(ROI,roiSz);

cols = jet(roiLen);
cols = cols(randperm(roiLen),:);
clf
imagesc(img(:,:,z)');
colormap gray
axis image
hold on
for i = 1:roiLen
	roiImg = reshape(roiMat(:,i),roiSz);
	if any(vec(roiImg(:,:,z)))
		B = bwboundaries(roiImg(:,:,z)~=0,'noholes');
		assert(length(B)==1) % from the way ROIs are constructed, should never be multiple connected components
		line([B{1}(:,1)'; B{1}(2:end,1)', B{1}(1,1)],[B{1}(:,2)'; B{1}(2:end,2)', B{1}(1,2)],'Color',cols(i,:),'LineWidth',1);
		text(mean(B{1}(:,1)),mean(B{1}(:,2)),num2str(i),'Color','g','FontSize',10);
	end
end