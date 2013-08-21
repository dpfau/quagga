function loadPatch(patchNum,patchSz)

x = 1472;
y = 2048;
z = 41;
t = 1000;
dataPath = '/groups/ahrens/ahrenslab/Misha/data_fish7_sharing_sample/data_for_sharing_01/12-10-05/Dre_L1_HuCGCaMP5_0_20121005_154312.corrected.processed';

tRng = [1:t];
% use the patchNum (scalar) and patchSz (3x1) to figure out the range of x and y values
patchSz = [64,64,4];
xyzRng = ind2patchLoc(patchNum,[x,y,z],patchSz);

patch = zeros([patchSz,length(tRng)]);
for it=1:length(tRng)
  for iz=1:length(xyzRng{3})
    tmp = imread(fullfile(basePath,exptDir,...
  	       ['/dff_aligned/dff_aligned_T' num2str(tRng(it)) '_slice' num2str(xyzRng{3}(iz)) '.jp2']),...
          'PixelRegion',xyzRng(1:2));
  	 patch(1:length(xyzRng{1}),1:length(xyzRng{2}),iz,it) = (double(tmp) - 15000)/5000;
  end
end