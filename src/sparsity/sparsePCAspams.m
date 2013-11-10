function [W,H,mX,sX] = sparsePCAspams(X,l,k,W0)
% Same as sparsePCA.m, but uses the SPAMS package
% (http://spams-devel.gforge.inria.fr/) to do fast online inference

sX = std(X(:));
X = X/sX; % scale the data to something reasonable
mX = mean(X,2);
X = bsxfun(@minus,X,mX);
l = l*sqrt(size(X,2)); % This allows the results to scale properly as the number of columns in H increases.
if nargin < 4
    [u,s,~] = svd(X,0);
    W = u(:,1:k)*sqrt(s(1:k,1:k));
else
    W = W0;
end
param.mode=2; % this mode seems to give the same results as Pfau's code
param.lambda=l;
param.lambda2 = 0;
param.posAlpha=0; % default is false
param.modeD=0; % just the L-2 norm <= 1 restriction
%param.modeD=1; % combined L-2 and L-1 (gamma1) norm for the dictionary
%param.gamma1=0.3;
param.K=k;  % learns a dictionary with 5 elements
param.numThreads=1; % number of threads
param.iter=1000;  % let us see what happens after 1000 iterations.

param.D = W';
H = mexTrainDL(X',param)';
W = mexLasso(X',H',param)';