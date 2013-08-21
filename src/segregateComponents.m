function ROI = segregateComponents(W)
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

% If a connected component has fewer than this many pixels, throw it out.
minPix = 10;

% Fraction of one component that must be overlapping another to be
% considered part of that component
overlap = 0.5;

%% Threshold pixels and find connected components

ROI = {};
if ndims(W) == 3
    for i = 1:size(W,3)
        img = W(:,:,i);
        CC = bwconncomp(abs(img)>thresh*max(W(:)),8);
        ROI = [ROI cellfun(@(x)reshape(sparse(x,1,img(x),size(W,1)*size(W,2),1),size(W,1),size(W,2)),...
            CC.PixelIdxList(cellfun(@numel,CC.PixelIdxList)>minPix),'UniformOutput',0)];
    end
elseif ndims(W) == 4
    for i = 1:size(W,4)
        img = W(:,:,:,i);
        CC = bwconncomp(abs(img)>thresh*max(W(:)),26);
        ROI = [ROI cellfun(@(x)make_img(x,W(:,:,:,i)),...
            CC.PixelIdxList(cellfun(@numel,CC.PixelIdxList)>minPix*size(W,3)),'UniformOutput',0)];
    end
end

%% Merge overlapping connected components recursively until convergence

ROI = connectComponents(ROI,overlap);

function img = make_img(idx,W)

img = zeros(size(W));
img(idx) = W(idx);