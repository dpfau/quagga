function loadPatch(patchNum,patchSz)

x = 1472;
y = 2048;
z = 41;
t = 1000;
dataPath = '/groups/ahrens/ahrenslab/Misha/data_fish7_sharing_sample/data_for_sharing_01/12-10-05/Dre_L1_HuCGCaMP5_0_20121005_154312.corrected.processed';

tRng = [1:t];
% use the patchNum (scalar) and patchSz (3x1) to figure out the range of x and y values
xRng = [];
yRng = [];
zRng = [];

patch = zeros(length(xRng),length(yRng),length(zRng),length(tRng));
for it=1:length(tRng)
  for iz=1:length(zRng)
    tmp = imread(fullfile(basePath,exptDir,['/dff_aligned/dff_aligned_T' num2str(tRng(it)) '_slice' num2str(zRng(iz)) '.jp2']));
    patch(:,:,iz,it) = (double(tmp) - 15000)/5000;
  end
end