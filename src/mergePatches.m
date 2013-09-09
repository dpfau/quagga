function ROI = mergePatches(ind,imSz,patchSz,roiPath)
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
		patches{i} = cellfun(@sparseCell2ind,ROI,'UniformOutput',0);
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
		[rng1,sub1] = ind2patchRng(ind(i),imSz,patchSz);
		[rng2,sub2] = ind2patchRng(ind(j),imSz,patchSz);
		if ~any(abs(sub1-sub2)>1) % if the patches overlap (i.e. no subscript is off by more than one)...
			rng = cellfun(@(x,y) [max(x(1),y(1)) min(x(2),y(2))], rng1, rng2, 'UniformOutput', 0); % the range of the overlap
            ni = length(patches{i});
            nj = length(patches{j});
			Z = zeros(ni,nj);
            for p = 1:ni % ...then iterate over ROIs in the patch
                for q = 1:nj
					roiInd1 = ones(size(patches{i}{p},1),1); % Index of roi pixels in the overlap between patches
					roiInd2 = ones(size(patches{j}{q},1),1);
					% Filter out the pixels that aren't in the overlap between patches
					for k = 1:3
						roiInd1 = roiInd1 & patches{i}{p}(:,k) >= rng{k}(1) & patches{i}{p}(:,k) <= rng{k}(2);
						roiInd2 = roiInd2 & patches{j}{q}(:,k) >= rng{k}(1) & patches{j}{q}(:,k) <= rng{k}(2);
					end
					% turn the subscripts into actual lists of indices
					ind1 = sub2ind(imSz,patches{i}{p}(roiInd1,1),patches{i}{p}(roiInd1,2),patches{i}{p}(roiInd1,3)); 
					ind2 = sub2ind(imSz,patches{j}{q}(roiInd2,1),patches{j}{q}(roiInd2,2),patches{j}{q}(roiInd2,3));
                    if length(intersect(ind1,ind2))/length(union(ind1,ind2)) > 0.5 % The Jaccard index between sets of indices
						Z(p,q) = 1;
                    end
                end
            end
			toMerge(patchInd(i)+(1:ni),patchInd(j)+(1:nj)) = Z;
			toMerge(patchInd(j)+(1:nj),patchInd(i)+(1:ni)) = Z';
		end
	end
end
[S,C] = graphconncomp(sparse(toMerge),'Directed',false);
unmerged = [patches{:}]; % flatten ROI cell array
ROI = cell(S,1);
for i = 1:S
    ROI{i} = apply(@(x,y) mergeROIs(x,y,imSz), unmerged{C==i});
end
save('mergedROIs','ROI')

function roi = mergeROIs(roi1,roi2,imSz)
% Given two ROIs in index list format, join them together. Pretty easy.
ind1 = sub2ind(imSz,roi1(:,1),roi1(:,2),roi1(:,3)); 
ind2 = sub2ind(imSz,roi2(:,1),roi2(:,2),roi2(:,3)); 
[~,i1,i2] = intersect(ind1,ind2); % the indices in each set of the intersection between them
[~,x1,x2] = setxor(ind1,ind2);
roi = [roi1(x1,:); roi2(x2,:); roi1(i1,1:3), sign(max(abs([roi1(i1,4), roi2(i2,4)]),[],2)).*max(abs([roi1(i1,4), roi2(i2,4)]),[],2)];