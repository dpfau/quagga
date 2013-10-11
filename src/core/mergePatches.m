function ROI = mergePatches(roiList,rngList,imSz)
% From the output of ROI detection on individual patches, merge together
% the results in patches specified by the range in "roiList". If a path
% is specified, load the patches from files (useful in distributed implementations).
% Otherwise, pass a cell array with each entry being the ROIs in a patch.

% Each patch contains multiple ROIs.
% If we were to flatten the cell array of ROIs from each patch,
% to create one global array of all ROIs across patches, then
% patchInd(i)+1 would be the index in that array of the first
% ROI belonging to the patch roiList(i)
patchInd = [0; cumsum(cellfun(@length,patches(:)))];
toMerge = sparse(patchInd(end),patchInd(end));

for i = 1:length(patches)
    % disp(num2str(i))
    if ~isempty(patches{i})
        % [rng1,sub1] = ind2patchRng(roiList(i),imSz,patchSz);
        for j = i+1:length(patches) % iterate over patches
            if ~isempty(patches{j})
                % [rng2,sub2] = ind2patchRng(roiList(j),imSz,patchSz);
                % if ~any(abs(sub1-sub2)>1) % if the patches overlap (i.e. no subscript is off by more than one)...
                if ~any(cellfun(@(x,y) max(x(1),y(1))>min(x(2),y(2)),rngList{i},rngList{j}))
                    Z = mergeROIs(patches{i},patches{j},rngList{i},rngList{j},imSz);
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

function roi = applyMerge(roi1,roi2,imSz)
% Given two ROIs in index list format, join them together. Pretty easy.
ind1 = sub2ind(imSz,roi1(:,1),roi1(:,2),roi1(:,3)); 
ind2 = sub2ind(imSz,roi2(:,1),roi2(:,2),roi2(:,3)); 
[~,i1,i2] = intersect(ind1,ind2); % the indices in each set of the intersection between them
[~,x1,x2] = setxor(ind1,ind2);
roi = [roi1(x1,:); roi2(x2,:); roi1(i1,1:3), sign(max(abs([roi1(i1,4), roi2(i2,4)]),[],2)).*max(abs([roi1(i1,4), roi2(i2,4)]),[],2)];