function ROI = mergePatches(ind,imSz,patchSz,roiPath)
% From the output of ROI detection on individual patches, merge together
% the results in patches specified by the range in "ind"

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
    % disp(num2str(i))
    if ~isempty(patches{i})
        [rng1,sub1] = ind2patchRng(ind(i),imSz,patchSz);
        for j = i+1:length(patches) % iterate over patches
            if ~isempty(patches{j})
                [rng2,sub2] = ind2patchRng(ind(j),imSz,patchSz);
                if ~any(abs(sub1-sub2)>1) % if the patches overlap (i.e. no subscript is off by more than one)...
                    Z = mergeROIs(patches{i},patches{j},rng1,rng2,imSz);
                    toMerge(patchInd(i)+(1:size(Z,1)),patchInd(j)+(1:size(Z,2))) = Z;
                    toMerge(patchInd(j)+(1:size(Z,2)),patchInd(i)+(1:size(Z,1))) = Z';
                end
            end
        end
    end
end
[S,C] = graphconncomp(sparse(toMerge),'Directed',false);
unmerged = [patches{:}]; % flatten ROI cell array
ROI = cell(S,1);
for i = 1:S
    ROI{i} = apply(@(x,y) applyMerge(x,y,imSz), unmerged{C==i});
end
save(fullfile(roiPath,'mergedROIs'),'ROI')

function roi = applyMerge(roi1,roi2,imSz)
% Given two ROIs in index list format, join them together. Pretty easy.
ind1 = sub2ind(imSz,roi1(:,1),roi1(:,2),roi1(:,3)); 
ind2 = sub2ind(imSz,roi2(:,1),roi2(:,2),roi2(:,3)); 
[~,i1,i2] = intersect(ind1,ind2); % the indices in each set of the intersection between them
[~,x1,x2] = setxor(ind1,ind2);
roi = [roi1(x1,:); roi2(x2,:); roi1(i1,1:3), sign(max(abs([roi1(i1,4), roi2(i2,4)]),[],2)).*max(abs([roi1(i1,4), roi2(i2,4)]),[],2)];