function scaledData = scaleData(data)
% Takes the raw fluorescence data and scales it in a way that pixels with variable fluorescence activity should stand out.
% First, subtract the median. Then, rescale each pixel so that the 75th percentile is +1 and 25th percentile is -1.
% This is more robust to outliers than using mean and standard deviation, and should put pixels with and without fluorescence
% activity on roughly the same scale. The highest percentiles of activity for cells with fluorescence activity should still
% be much higher.

sz = size(data);
data = reshape(data,prod(sz(1:end-1)),sz(end));
y = prctile(data,[25 75],2);
scaledData = zeros(size(data));
for i = 1:size(data,1)
	scaledData(i,:) = (2*data(i,:)-(y(i,1)+y(i,2)))/(y(i,2)-y(i,1));
end
scaledData = reshape(scaledData,sz);