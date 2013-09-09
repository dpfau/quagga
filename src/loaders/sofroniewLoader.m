function patch = sofroniewLoader(patchSz,tRng,xyzRng)

dataPath = '/Users/pfau/Documents/Research/Janelia/Svoboda/Nick/data/an216166_2';
filePrefix = 'Image_Registration_4_an216166_2013_07_17_run_01_sbv_01_main_';
fileRange = 195:204;

imlen = zeros(length(fileRange),1);
for i = 1:length(fileRange);
    filename = fullfile(dataPath,[filePrefix num2str(fileRange(i)) '.tif']);
    imlen(i) = length(imfinfo(filename));
end

img = zeros(512,512,sum(imlen));
idx = cumsum([0; imlen]);
for i = 1:length(fileRange)
    for j = 1:imlen(i)
        img(:,:,idx(i)+j) = imread(filename,'Index',j,'PixelRegion',xyzRng(1:2));
    end
end