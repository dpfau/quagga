function plotAllROIs(ROI,img,z,xRng,yRng)
% Plot all ROIs through a particular image in a z stack

if nargin < 3, z = 1; end
if nargin < 4, xRng = [1, size(img,1)]; end
if nargin < 5, yRng = [1, size(img,2)]; end
assert(diff(xRng)+1==size(img,1))
assert(diff(yRng)+1==size(img,2))

mask = zeros(size(img));
center = zeros(length(ROI),2);
for i = 1:length(ROI)
	disp(num2str(i))
	idx = ROI{i}(:,3) == z & ...
          ROI{i}(:,1) >= xRng(1) & ...
          ROI{i}(:,1) <= xRng(2) & ...
          ROI{i}(:,2) >= yRng(1) & ...
          ROI{i}(:,2) <= yRng(2);
    center(i,1) = mean(ROI{i}(idx,1));
    center(i,2) = mean(ROI{i}(idx,2));   
	roi = sparse(ROI{i}(idx,1),ROI{i}(idx,2),ROI{i}(idx,4),size(img,1),size(img,2));
	edges = edge(full(roi),'Canny');
	mask(edges==1) = 1;
end
clf
showmask(img,mask,true);
hold on
for i = 1:length(ROI)
	if ~any(isnan(center(i,:)))
		text(center(i,2),center(i,1),num2str(i),'Color','g','FontSize',10)
	end
end