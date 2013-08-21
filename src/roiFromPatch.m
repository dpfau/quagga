function roiFromPatch(patchNum)

imSz = [1472,2048,41,1000];
patchSz = [64,64,4];
dataPath = '/groups/ahrens/ahrenslab/Misha/data_fish7_sharing_sample/data_for_sharing_01/12-10-05/Dre_L1_HuCGCaMP5_0_20121005_154312.corrected.processed';

patch = loadPatch(patchNum,imSz,patchSz,dataPath);