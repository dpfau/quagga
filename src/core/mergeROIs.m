function toMerge = mergeROIs(ROI1,ROI2,xyzRng1,xyzRng2,imSz)
% Given two cell arrays, each containing all the ROIs in a single patch, find the neurons

rng = cellfun(@(x,y) [max(x(1),y(1)) min(x(2),y(2))], xyzRng1, xyzRng2, 'UniformOutput', 0); % the range of the overlap
ni = length(ROI1);
nj = length(ROI2);
toMerge = zeros(ni,nj);
for p = 1:ni % ...then iterate over ROIs in the patch
    for q = 1:nj
        roiInd1 = ones(size(ROI1{p},1),1); % Index of roi pixels in the overlap between patches
        roiInd2 = ones(size(ROI2{q},1),1);
        % Filter out the pixels that aren't in the overlap between patches
        for k = 1:3
            roiInd1 = roiInd1 & ROI1{p}(:,k) >= rng{k}(1) & ROI1{p}(:,k) <= rng{k}(2);
            roiInd2 = roiInd2 & ROI2{q}(:,k) >= rng{k}(1) & ROI2{q}(:,k) <= rng{k}(2);
        end
        % turn the subscripts into actual lists of indices
        ind1 = sub2ind(imSz,ROI1{p}(roiInd1,1),ROI1{p}(roiInd1,2),ROI1{p}(roiInd1,3));
        ind2 = sub2ind(imSz,ROI2{q}(roiInd2,1),ROI2{q}(roiInd2,2),ROI2{q}(roiInd2,3));
        if length(intersect(ind1,ind2))/length(union(ind1,ind2)) > 0.5 % The Jaccard index between sets of indices
        	toMerge(p,q) = 1;
        end
    end
end