function y = recursivePartition(x,sig_i,sig_x,minPix)
% Recursively apply normalized cuts partitioning
% to the image x, with similarity function
% exp(-||x1-x2||^2_2/sig^2), stopping when further
% partitioning would result in a section smaller
% than n

[m,n] = size(x);
[j,i] = meshgrid(1:n,1:m); % Dammit, MATLAB, can't you be consistent about row-major order??
W = sparse(numel(x),numel(x));
k = 2; % extent of the neighborhood in pixels in any direction
for ii = -k:k
	for jj = -k:k
		% simultaneously compute the weights for everything with the same offset
		w = exp(-(x(max(1,1+ii):min(m,m+ii),max(1,1+jj):min(n,n+jj))...
			     -x(max(1,1-ii):min(m,m-ii),max(1,1-jj):min(n,n-jj))).^2/sig_i^2)*exp(-(ii^2+jj^2)/sig_x^2); 
		% drop these weights into the right place in the matrix
		W(sub2ind([m*n,m*n],sub2ind([m,n],i(max(1,1+ii):min(m,m+ii),max(1,1+jj):min(n,n+jj)),...
		                                  j(max(1,1+ii):min(m,m+ii),max(1,1+jj):min(n,n+jj))),...
		                    sub2ind([m,n],i(max(1,1-ii):min(m,m-ii),max(1,1-jj):min(n,n-jj)),...
		                                  j(max(1,1-ii):min(m,m-ii),max(1,1-jj):min(n,n-jj))))) = w;
	end
end
y = reshape(recursiveMinNCut(W,minPix),m,n);
if nargout == 0
	edges = edge(y,'Canny');
	imgEdge = repmat(mat2gray(x),[1,1,3]);
	imgEdge(logical(cat(3,edges,zeros([size(x),2])))) = 1; % Make red edges

	figure
	image(imgEdge)
	axis image
end

function z = recursiveMinNCut(W,n)

y = minNCut(W);
% if nnz(y) < n || nnz(~y) < n
% 	z = zeros(size(y));
% else
% 	y1 = recursiveMinNCut(W(y,y),n);
% 	y2 = recursiveMinNCut(W(~y,~y),n);
% 	z = zeros(size(y));
% 	z(y) = y1;
% 	z(~y) = y2;
% 	z = z + 2*y; % encode the partition hierarchy as a binary number, with larger bits for larger partitions
% end
z = zeros(size(y));
if nnz(y) > n,  z(y)  = recursiveMinNCut(W(y,y),n); end
if nnz(~y) > n, z(~y) = recursiveMinNCut(W(~y,~y),n); end
z = z + 2*y; % encode the partition hierarchy as a binary number, with larger bits for larger partitions