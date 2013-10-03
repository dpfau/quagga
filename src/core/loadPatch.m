function [patch,xyzRng] = loadPatch(patchNum,imSz,patchSz,loader)

% use the patchNum (scalar) and patchSz (3x1) to figure out the range of x and y values
tRng = [1,imSz(end)];
xyzRng = ind2patchRng(patchNum,imSz(1:end-1),patchSz);
patch = loader(patchSz,xyzRng,tRng);