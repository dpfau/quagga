function patch = sofroniewLoader(patchSz,xyzRng,tRng)
% tRng is superfluous here for the moment. May replace it with something that points to
% a folder and iterates through all files in that folder with the right prefix
dataPath = '/Users/pfau/Documents/Research/Janelia/Svoboda/Nick/data/an216166_2';
filePrefix = 'Image_Registration_4_an216166_2013_07_17_run_01_sbv_01_main_';
fileRange = 195:204;

imlen = zeros(length(fileRange),1);
for i = 1:length(fileRange);
    filename = fullfile(dataPath,[filePrefix num2str(fileRange(i)) '.tif']);
    imlen(i) = length(imfinfo(filename));
end

patch = zeros([cellfun(@(x)diff(x)+1,xyzRng),sum(imlen)]);
idx = cumsum([0; imlen]);
for i = 1:length(fileRange)
    for j = 1:imlen(i)
        patch(:,:,idx(i)+j) = imread(filename,'Index',j,'PixelRegion',xyzRng(1:2));
    end
end

% Sofroniew's data is raw fluorescence (after image registration) not df/f, so we subtract the median
sz = size(patch);
patch = reshape(patch,prod(sz(1:end-1)),sz(end));
patch = bsxfun(@minus,patch,median(patch,2));
patch = reshape(patch,sz);
% lims = prctile(patch(:),[1 99]);
% patch = patch/(lims(2)-lims(1)); % rescale

% If necessary, pad the array.
% The combined arrayfun and cellfun is a horrible hack because MATLAB doesn't let you
% mix double arrays and cell arrays when using cellfun/arrayfun. There's probably a
% better way, and I'm all ears.
patch = padarray(patch,cellfun(@(x,y) y-(diff(x)+1),xyzRng,arrayfun(@(x)x,patchSz,'UniformOutput',0)),'post');