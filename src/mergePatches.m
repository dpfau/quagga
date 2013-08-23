function Z = mergePatches(ind,imSz,patchSz,roiPath)
% From the output of ROI detection on individual patches, merge together
% the results in patches specified by the range in "ind"

if nargin < 2, imSz = [1472,2048,41,1000]; end
if nargin < 3, patchSz = [64,64,4]; end
if nargin < 4, roiPath = '/Users/pfau/Documents/Research/Janelia/data/ROIs/test'; end

patches = cell(length(ind),1);
for i = 1:length(ind)
	roiFile = fullfile(roiPath,['patch_' num2str(ind(i)) '.mat']);
	if exist(roiFile,'file')
		load(roiFile);
		patches{i} = sparseCell2ind(ROI);
	end
end

% Each patch contains multiple ROIs.
% If we were to flatten the cell array of ROIs from each patch,
% to create one global array of all ROIs across patches, then
% patchInd(i)+1 would be the index in that array of the first
% ROI belonging to the patch ind(i)
patchInd = [0; cumsum(cellfun(@length,patches(:)))];
toMerge = sparse(patchInd(end),patchInd(end));

for i = 1:length(patches)
	for j = i+1:length(patches) % iterate over patches
		[rng1,sub1] = ind2patchRng(ind(i));
		[rng2,sub2] = ind2patchRng(ind(j));
		if ~any(abs(sub1-sub2)>1) % if the patches overlap (i.e. no subscript is off by more than one)...
			rng = cellfun(@(x,y) [max(x(1),y(1)) min(x(2),y(2))], rng1, rng2, 'UniformOutput', 0); % the range of the overlap
			Z = zeros(length(patches{i}),length(patches{j}));
			for p = 1:length(patches{i}) % ...then iterate over ROIs in the patch
				for q = 1:length(patches{j})
					ind1 = ones(size(patches{i}{p}),1);
					ind2 = ones(size(patches{j}{q}),1);
					% Filter out the pixels that aren't in the overlap between patches
					for k = 1:3
						ind1 = ind1 & patches{i}{p}(:,k) >= rng{k}(1) & patches{i}{p}(:,k) <= rng{k}(2);
						ind2 = ind2 & patches{j}{q}(:,k) >= rng{k}(1) & patches{j}{q}(:,k) <= rng{k}(2);
					end
				end
			end
		end
	end
end
[S,C] = graphconncomp(sparse(toMerge),'Directed',false);
ROI_ = [patches{:}]; % flatten ROI cell array
ROI = cell(S,1);