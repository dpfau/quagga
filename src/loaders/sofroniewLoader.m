function patch = sofroniewLoader(patchSz,xyzRng,tRng)
% tRng is superfluous here for the moment. May replace it with something that points to
% a folder and iterates through all files in that folder with the right prefix
dataPath = '/Users/pfau/Documents/Research/Janelia/Svoboda/Nick/data/an216166_2';
filePrefix = 'Image_Registration_4_an216166_2013_07_17_run_01_sbv_01_main_';
fileRange = 195:204;

imlen = zeros(length(fileRange),1);
filename = cell(length(fileRange),1);
for i = 1:length(fileRange);
    filename{i} = fullfile(dataPath,[filePrefix num2str(fileRange(i)) '.tif']);
    imlen(i) = length(imfinfo(filename{i}));
end

patch = zeros([cellfun(@(x)diff(x)+1,xyzRng),sum(imlen)]);
idx = cumsum([0; imlen]);
for i = 1:length(fileRange)
    for j = 1:imlen(i)
        patch(:,:,idx(i)+j) = imread(filename{i},'Index',j,'PixelRegion',xyzRng(1:2));
    end
end

% If necessary, pad the array.
% The combined arrayfun and cellfun is a horrible hack because MATLAB doesn't let you
% mix double arrays and cell arrays when using cellfun/arrayfun. There's probably a
% better way...
patch = padarray(patch,cellfun(@(x,y) y-(diff(x)+1),xyzRng,arrayfun(@(x)x,patchSz,'UniformOutput',0)),'post');