function [ROI, junk] = segregateComponents(W)
% From the results of sparsification, find connected components, merge
% components that appear to be from the same neuron, discard components
% that are too small and separate components that look like different
% neurons.
%
% David Pfau, 2013

%% Parameters

% threshold for counting a pixel 
% (since we usually don't run LASSO to convergence, most pixels aren't *exactly* zero)
thresh = 0.01;

% If a connected component has pixels outside this range, throw it out.
minPix = 75;
maxPix = 3000;

% Fraction of one component that must be overlapping another to be
% considered part of that component
overlap = 0.5;

% Maximum surface area to volume ratio, a measure of how compact an ROI is
minSA2Vol = 2;

%% Threshold pixels and find connected components

ROI = {};
if nargout == 2
    junk = {};
end

accept = @(x) nnz(x) > minPix && nnz(x) < maxPix;
for i = 1:size(W,4)
    img = W(:,:,:,i);
    CC = bwconncomp(abs(img)>thresh*max(W(:)),26);
    tempROI = cellfun(@(x) makeImg(x,W(:,:,:,i)), CC.PixelIdxList, 'UniformOutput', 0); % Before filtering
    ROI = [ROI tempROI(cellfun(accept, tempROI))];
    if nargout == 2
        junk = [junk tempROI(cellfun(@(x) ~accept(x) && nnz(x) > 50, tempROI))]; 
        % for debugging, keep some junk to make sure we aren't tossing out any 
    end
end

%% Merge overlapping connected components recursively until convergence
ROI = connectComponents(ROI,overlap);
%% Filter out anything with too high a surface area to volume ratio
goodIdx = cellfun(@(x) SA2Vol(x) < minSA2Vol, ROI);
junk = [junk ROI(~goodIdx)];
ROI = ROI(goodIdx);

function img = makeImg(idx,W)

img = zeros(size(W));
img(idx) = W(idx);

function x = SA2Vol(ROI)
% approximates the surface area to volume ratio, which should be small for a neuron and high for junk
dilation = zeros(size(ROI));
for i = 1:size(dilation,3)
    dilation(:,:,i) = bwmorph(ROI(:,:,i),'dilate');
end
x = (nnz(dilation)-nnz(ROI))/nnz(ROI);