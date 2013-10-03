function patch = sofroniewLoader2(patchSz,xyzRng,tRng,dataPath)
% tRng is superfluous here for the moment. 
files = dir(dataPath);
imgs = {};
for i = 1:length(files)
	if ~isempty(strfind(files(i).name,'.tif'))
		info = imfinfo(fullfile(dataPath,files(i).name));
		img = zeros([cellfun(@(x)diff(x)+1,xyzRng),length(info)]);
		for j = 1:length(info)
			img(:,:,j) = imread(fullfile(dataPath,files(i).name),'Index',j,'PixelRegion',xyzRng(1:2));
        end
        imgs{length(imgs)+1} = img;
	end
end

imgSz = size(imgs{1});
patch = zeros([imgSz(1:end-1),0]);
for i = 1:length(imgs)
	patch = cat(ndims(imgs{i}),patch,imgs{i});
end

% If necessary, pad the array.
% The combined arrayfun and cellfun is a horrible hack because MATLAB doesn't let you
% mix double arrays and cell arrays when using cellfun/arrayfun. There's probably a
% better way...
% patch = padarray(patch,cellfun(@(x,y) y-(diff(x)+1),xyzRng,arrayfun(@(x)x,patchSz,'UniformOutput',0)),'post');