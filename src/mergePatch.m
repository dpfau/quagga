function Z = mergePatch(ind,imSz,patchSz,roiPath)

if nargin < 2, imSz = [1472,2048,41,1000]; end
if nargin < 3, patchSz = [64,64,4]; end
if nargin < 4, roiPath = '/Users/pfau/Documents/Research/Janelia/data/ROIs/test'; end

ROI = {};
junk = {}; % need this here because of static workspace rules in Matlab, I guess.
load(fullfile(roiPath, ['patch_' num2str(ind)]))
centerROI = ROI; % to avoid name conflicts when loading other ROIs

[~,patchSub] = ind2patchRng(ind,imSz(1:3),patchSz);

Z = recursiveFor(@findROIToMerge,-1:1,-1:1,-1:1);

	function Z = findROIToMerge(dx,dy,dz)

	% Index of the patch elements that overlap
	offset = [dx,dy,dz];
	toLoad = fullfile(roiPath, ['patch_' num2str(patchSub2ind(patchSub+offset)) '.mat']);
	if ~exist(toLoad,'file')
		Z = [];
    else
        ROI = {};
		ROI = load(toLoad);
        ROI = ROI.ROI; % ugly, but handles loading in a way that works with static workspaces
		overlap = arrayfun(@(x,y,z) intersect((x-1)/2*z+(1:z),(y-1)/2*z+(1:z)),patchSub,patchSub+[dx,dy,dz],patchSz,'UniformOutput',0);
		p = length(centerROI);
		q = length(ROI);
		Z = zeros(p,q);
		for i = 1:p
			for j = 1:q
				idx1 = find(slice(centerROI{p},overlap{:}));
				idx2 = find(slice(ROI{q},overlap{:}));
				if length(intersect(idx1,idx2))/length(union(idx1,idx2)) > 0.5 % Compute Jaccard index between parts of ROIs shared between patches
	            	Z(i,j) = 1;
	            end
	        end
		end
	end

	end

end