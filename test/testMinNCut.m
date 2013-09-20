img = imread('lena.png');
img = imresize(double(rgb2gray(img)),0.5);

partition = recursivePartition(img,5,1,100);
edges = edge(partition,'Canny');

imgEdge = repmat(img/4,[1,1,3]);
imgEdge(logical(cat(3,edges,zeros([size(img),2])))) = 64; % Make red edges

figure; image(imgEdge/64); axis image