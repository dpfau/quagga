function plotReconstruction(data,ROI,imSz,filename,z)
% from the data and ROIs, reconstruct the firing rates and save a movie
% that compares the original data, best reconstruction, and residual data.

if nargin < 5
	z = 1; % if no z slice is specified, assume the first one, or the data is really 2D
end

T = size(data,ndims(data));
spatialMatrix = roi2matrix(ROI,imSz(1:3));
% mask = zeros(imSz(1:2));
% for i = 1:size(spatialMatrix,2)
% 	edges = edge(reshape(spatialMatrix((z-1)*(imSz(1)*imSz(2))+(1:imSz(1)*imSz(2)),i),imSz(1),imSz(2)),'Canny');
% 	mask(edges==1)=1;
% end

spatialMatrix = [spatialMatrix, reshape(mean(data,ndims(data)),prod(imSz(1:3)),1)]; % Add mean image
temporalMatrix = pinv(spatialMatrix)*reshape(data,prod(imSz(1:3)),T);
reconstruction = spatialMatrix*temporalMatrix;
residual = reshape(data,prod(imSz(1:3)),T) - reconstruction;

vidObj = VideoWriter(filename);
vidObj.Quality = 100;
vidObj.FrameRate = 24;
open(vidObj);

data           = reshape(data,imSz);
reconstruction = reshape(reconstruction,imSz);
residual       = reshape(residual,imSz);


figure;
set(gcf,'Position',[1 420 1440 380])
colormap gray
subplot(1,3,1) % original data
% h1 = image(showmask(data(:,:,z,1),mask,false,min(data(:)),max(data(:))));
h1 = imagesc(data(:,:,z,1),[min(data(:)),max(data(:))]);
axis image

subplot(1,3,2) % reconstruction
% h2 = image(showmask(reconstruction(:,:,z,1),mask,false,min(reconstruction(:)),max(reconstruction(:))));
h2 = imagesc(reconstruction(:,:,z,1),[min(reconstruction(:)),max(reconstruction(:))]);
axis image

subplot(1,3,3) % residual
% h3 = image(showmask(residual(:,:,z,1),mask,false,min(residual(:)),max(residual(:))));
h3 = imagesc(residual(:,:,z,1),[min(residual(:)),max(residual(:))]);
axis image

for i = 1:T
	fprintf('Writing frame %d of %d\n',i,T);
% 	set(h1,'CData',showmask(data(:,:,z,i),mask,false,min(data(:)),max(data(:))))
% 	set(h2,'CData',showmask(reconstruction(:,:,z,i),mask,false,min(reconstruction(:)),max(reconstruction(:))))
% 	set(h3,'CData',showmask(residual(:,:,z,i),mask,false,min(residual(:)),max(residual(:))))
    set(h1,'CData',data(:,:,z,i));
    set(h2,'CData',reconstruction(:,:,z,i));
    set(h3,'CData',residual(:,:,z,i));
    writeVideo(vidObj, getframe(gcf));
end
close(vidObj);