function plotReconstruction(data,ROI,imSz,filename,z)
% from the data and ROIs, reconstruct the firing rates and save a movie
% that compares the original data, best reconstruction, and residual data.

if nargin < 5
	z = 1; % if no z slice is specified, assume the first one, or the data is really 2D
end

T = size(data,ndims(data));
spatialMatrix = roi2matrix(ROI,imSz(1:3));

spatialMatrix = [spatialMatrix, reshape(mean(data,ndims(data)),prod(imSz(1:3)),1)]; % Add mean image
temporalMatrix = pinv(spatialMatrix)*reshape(data,prod(imSz(1:3)),T);
reconstruction = spatialMatrix*temporalMatrix;
residual = reshape(data,prod(imSz(1:3)),T) - reconstruction;

data           = reshape(data,imSz);
reconstruction = reshape(reconstruction,imSz);
residual       = reshape(residual,imSz);

figure;
set(gcf,'Position',[1 1 764 764])
colormap gray
h = imagesc(data(:,:,z,1),[min(data(:)),max(data(:))]);
axis image; hold on
cols = jet(size(spatialMatrix,2)-1);
cols = cols(randperm(size(spatialMatrix,2)-1),:);

for i = 1:size(spatialMatrix,2)-1
	roiImg = reshape(spatialMatrix(:,i),imSz(1:3));
	if any(vec(roiImg(:,:,z)))
		B = bwboundaries(roiImg(:,:,z)~=0,'noholes');
		assert(length(B)==1) % from the way ROIs are constructed, should never be multiple connected components
		line([B{1}(:,2)'; B{1}(2:end,2)', B{1}(1,2)],[B{1}(:,1)'; B{1}(2:end,1)', B{1}(1,1)],'Color',cols(i,:),'LineWidth',1);
	end
end

vidObjData = VideoWriter([filename '_data.avi']);
vidObjData.Quality = 100;
vidObjData.FrameRate = 24;
open(vidObjData);
for i = 1:T
	fprintf('Writing frame %d of %d\n',i,T);
    set(h,'CData',data(:,:,z,i));
    writeVideo(vidObjData, getframe(gcf));
end
close(vidObjData);

vidObjRecon = VideoWriter([filename '_reconstruction.avi']);
vidObjRecon.Quality = 100;
vidObjRecon.FrameRate = 24;
open(vidObjRecon);
set(gca,'CLim',[min(reconstruction(:)),max(reconstruction(:))])
for i = 1:T
	fprintf('Writing frame %d of %d\n',i,T);
    set(h,'CData',reconstruction(:,:,z,i));
    writeVideo(vidObjRecon, getframe(gcf));
end
close(vidObjRecon);

vidObjResid = VideoWriter([filename '_residual.avi']);
vidObjResid.Quality = 100;
vidObjResid.FrameRate = 24;
open(vidObjResid);
set(gca,'CLim',[min(residual(:)),max(residual(:))])
for i = 1:T
	fprintf('Writing frame %d of %d\n',i,T);
    set(h,'CData',residual(:,:,z,i));
    writeVideo(vidObjResid, getframe(gcf));
end
close(vidObjResid);