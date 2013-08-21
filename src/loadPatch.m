function [patch,xyzRng] = loadPatch(patchNum,imSz,patchSz,dataPath)

tRng = [1,imSz(4)];
% use the patchNum (scalar) and patchSz (3x1) to figure out the range of x and y values
patchSz = [64,64,4];
xyzRng = ind2patchRng(patchNum,imSz(1:3),patchSz);

patch = zeros([patchSz,length(tRng)]);
nImg = (diff(tRng)+1)*(diff(xyzRng{3})+1);
fprintf('Loading %d images\n',nImg)
for it=1:diff(tRng)+1
  for iz=1:diff(xyzRng{3})+1
    tmp = imread(fullfile(dataPath,...
  	       ['/dff_aligned/dff_aligned_T' num2str(tRng(1)+it-1) '_slice' num2str(xyzRng{3}(1)+iz-1) '.jp2']),...
          'PixelRegion',xyzRng(1:2));
  	 patch(1:diff(xyzRng{1})+1,1:diff(xyzRng{2})+1,iz,it) = (double(tmp) - 15000)/5000;
  end
  fprintf('t=%d\n',it)
end