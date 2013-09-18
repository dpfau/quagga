function y = recursivePartition(x,sig,n)
% Recursively apply normalized cuts partitioning
% to the image x, with similarity function
% exp(-||x1-x2||^2_2/sig^2), stopping when further
% partitioning would result in a section smaller
% than n

sz = size(x);
W = zeros(numel(x));
for t = 1:numel(x)
	W(t,t) = 1;
	[i,j] = ind2sub(sz,t);
	for ii = [-1,1]
		try
			u = sub2ind(sz,i+ii,j);
			W(t,u) = exp(-(x(t)-x(u))^2/sig^2);
		end
	end
	for jj = [-1,1]
		try
			u = sub2ind(sz,i,j+jj);
			W(t,u) = exp(-(x(t)-x(u))^2/sig^2);
		end
	end
end
y = recursiveMinNCut(W,n);

function z = recursiveMinNCut(W,n)

y = minNCut(W);
if nnz(y) < n || nnz(~y) < n
	z = zeros(size(y));
else
	y1 = recursiveMinNCut(W(y,y),n);
	y2 = recursiveMinNCut(W(~y,~y),n);
	z = zeros(size(y));
	z(y) = y1;
	z(~y) = y2;
	z = z + 2*y; % encode the partition hierarchy as a binary number, with larger bits for larger partitions
end