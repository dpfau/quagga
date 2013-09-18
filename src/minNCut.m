function y = minNCut(W)
% Normalized cuts algorithm of Shi and Malik (2000).
% Another function can take an image as input, construct
% the similarity graph and pass that information to this
% function

% W - the symmetric weights of the graph. Can be a sparse matrix

D = diag(sum(W));
[y,~] = eigs(D-W,D,2,'sm');
y = y(:,1);

% do the splitting by checking several thresholds and picking the one with the smallest NCut
l = linspace(min(y),max(y),10);
[~,i] = min(arrayfun(@(x)NCut(W,y>x),l));
y = y>l(i);

function ncut = NCut(W,x)

cut = sum(sum(W(x==0,x~=0)));
assocA = sum(sum(W(x==0,:)));
assocB = sum(sum(W(x~=0,:)));
ncut = cut/assocA + cut/assocB;