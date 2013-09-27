function y = slice(x,ii,jj,kk)
% If x is a cell array of equally-sized sparse matrices (basically a way to
% implement a sparse 3D array), return a vector that slices x along the
% relevant dimensions. The vector is a 1D sparse array with size
% numel(i)*numel(j)*numel(k)

[m,n] = size(x{1});
assert(min(kk)>=1 && max(kk)<=numel(x));
for i = 2:numel(x,1)
    assert(~any([m,n]~=size(x{i})));
end

y = [];
for k = kk
    y = cat(3, y, full(x{k}(ii,jj)));
end