function foo = local2global(roi,dim,offset)
% Convert a 3D array of ROI values in one patch into a cell array of sparse
% matrices, one for each slice of the data in the Z direction.
%
% roi    - array of ROI values in a patch
% dim    - size of frame
% offset - offset of patch within image. [0,0,0] means patch is in upper
%   left corner of image
%
% foo    - cell array of ROI values in global coordinates

foo = cell(dim(3),1);
for i = 1:dim(3)
    foo{i} = sparse([],[],[],dim(1),dim(2));
end

pdim = size(roi);
for i = 1:size(roi,3)
    foo{i+offset(3)}((1:pdim(1))+offset(1),(1:pdim(2))+offset(2)) = roi(:,:,i);
end