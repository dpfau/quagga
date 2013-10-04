function patch = tiffLoader(patchSz,xyzRng,tRng,dataPath,prefix)
% tRng is superfluous here for the moment. 
files = dir(dataPath);
imgs = {};
for i = 1:length(files)
	if ~isempty(strfind(lower(files(i).name),'.tif'))
		if nargin < 5 || ~isempty(strfind(files(i).name,prefix))
			info = imfinfo(fullfile(dataPath,files(i).name));
			img = zeros([cellfun(@(x)diff(x)+1,xyzRng),length(info)]);
			for j = 1:length(info)
				img(:,:,j) = imread(fullfile(dataPath,files(i).name),'Index',j,'PixelRegion',xyzRng(1:2));
	        end
	        imgs{length(imgs)+1} = img;
	    end
	end
end

imgSz = size(imgs{1});
patch = zeros([imgSz(1:end-1),0]);
for i = 1:length(imgs)
	patch = cat(ndims(imgs{i}),patch,imgs{i});
end