function y = sparseCell2ind(x)
% Converts a cell array of sparse matrices (a hack to approximate
% a 3D sparse array, which MATLAB doesn't support) into a 4-column
% matrix of nonzero x,y and z coordinates with values in the
% rightmost column. Contains the same information but does not have
% the same linear-in-the-size-of-the-smallest-dimension-in-memory
% overhead that MATLAB's sparse array does.

% Note - this function is basically deprecated, as local2global now
% directly outputs to this format instead of going through the cell
% array of sparse indices step.

y = zeros(0,4);
for i = 1:length(x)
	[ii,jj,ss] = find(x{i});
	y = [y; ii, jj, i*ones(length(ii),1), ss];
end