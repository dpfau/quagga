function patch = loadPatch(patchNum,imSz,patchSz,dataPath)

tRng = [1:imSz(4)];
% use the patchNum (scalar) and patchSz (3x1) to figure out the range of x and y values
patchSz = [64,64,4];
xyzRng = ind2patchLoc(patchNum,imSz(1:3),patchSz);

patch = zeros([patchSz,length(tRng)]);
for it=1:length(tRng)
  for iz=1:length(xyzRng{3})
    tmp = imread(fullfile(basePath,exptDir,...
  	       ['/dff_aligned/dff_aligned_T' num2str(tRng(it)) '_slice' num2str(xyzRng{3}(iz)) '.jp2']),...
          'PixelRegion',xyzRng(1:2));
  	 patch(1:length(xyzRng{1}),1:length(xyzRng{2}),iz,it) = (double(tmp) - 15000)/5000;
  end
end