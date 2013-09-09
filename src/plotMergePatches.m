function plotMergePatches(ind,imSz,patchSz,roiPath)

if nargin < 2, imSz = [1472,2048,41,1000]; end
if nargin < 3, patchSz = [64,64,4]; end
if nargin < 4, roiPath = '/Users/pfau/Documents/Research/Janelia/data/ROIs/test'; end

ROI = mergePatches(ind,imSz,patchSz,roiPath);