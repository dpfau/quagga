function ROI = mergePatchesFromFile(ind,imSz,patchSz,roiPath)
% From the output of ROI detection on individual patches, merge together
% the results in patches specified by the range in "ind", loaded from the
% folder "roiPath".

patches = cell(length(ind),1);
rngList = cell(length(ind),1);
for i = 1:length(ind)
	roiFile = fullfile(roiPath,['patch_' num2str(ind(i)) '.mat']);
	if exist(roiFile,'file')
		load(roiFile);
		patches{i} = ROI;
		rngList{i} = ind2patchRng(ind(i),imSz,patchSz);
	end
end
ROI = mergePatches(patches,rngList,imSz);
save(fullfile(roiPath,'mergedROIs'),'ROI');