function [patch,xyzRng] = loadPatch(patchNum,imSz,patchSz,loader)

% use the patchNum (scalar) and patchSz (3x1) to figure out the range of x and y values
tRng = [1,imSz(end)];
switch numel(patchNum) 
	case 1% If we pass a single number, it's an index.
		xyzRng = ind2patchRng(patchNum,imSz(1:end-1),patchSz);
	case numel(patchSz)
		xyzRng = arrayfun(@(x,y,z) [x,min(z,x+y-1)],patchNum,patchSz,imSz,'UniformOutput',0);
	otherwise
		error('Patch must either be specified by index or by location vector') 
end
patch = loader(patchSz,xyzRng,tRng);