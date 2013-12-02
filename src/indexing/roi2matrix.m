function x = roi2matrix(ROI,imSz,z)
% Convert the ROIs into columns of a matrix, useful for recovering estimates of firing rates,
% but impractical for larger data sets.

if nargin < 3
    x = zeros(prod(imSz(1:3)),length(ROI));
    for i = 1:length(ROI)
        for j = 1:imSz(3)
            idx = ROI{i}(:,3) == j;
            img = full(sparse(ROI{i}(idx,1),ROI{i}(idx,2),ROI{i}(idx,4),imSz(1),imSz(2)));
            x((j-1)*numel(img)+(1:numel(img)),i) = img(:);
        end
    end
else
    x = zeros(prod(imSz(1:2)),length(ROI));
    for i = 1:length(ROI)
        idx = ROI{i}(:,3) == z;
        x(:,i) = vec(full(sparse(ROI{i}(idx,1),ROI{i}(idx,2),ROI{i}(idx,4),imSz(1),imSz(2))));
    end
end