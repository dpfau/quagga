function plotAllROIs(ROI,img,z,xRng,yRng)
% Plot all ROIs through a particular image in a z stack

if nargin < 3, z = 1; end
if nargin < 4, xRng = [1, size(img,1)]; end
if nargin < 5, yRng = [1, size(img,2)]; end

imSz = size(img);
if length(imSz) == 4
	roiSz = imSz(1:3);
else
	roiSz = [imSz(1:2), 1];
end
roiLen = length(ROI);
roiMat = roi2matrix(ROI,roiSz,z);

cols = jet(roiLen);
cols = cols(randperm(roiLen),:);
clf
imagesc(img(xRng(1):xRng(2),yRng(1):yRng(2),z));
colormap gray
axis image
hold on
for i = 1:roiLen
	roiImg = reshape(roiMat(:,i),roiSz);
	if any(vec(roiImg(:,:)))
		B = bwboundaries(roiImg(:,:)~=0,'noholes');
        B = cellfun(@(x)bsxfun(@minus,x,[xRng(1),yRng(1)]),B,'UniformOutput',0);
		for j = 1:length(B)
            line([B{j}(:,2)'; B{j}(2:end,2)', B{j}(1,2)],[B{j}(:,1)'; B{j}(2:end,1)', B{j}(1,1)],'Color',cols(i,:),'LineWidth',1);
        end
		text(mean(B{1}(:,2)),mean(B{1}(:,1)),num2str(i),'Color','g','FontSize',10);
	end
end