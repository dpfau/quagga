function [W,H,mX,sX] = sparsePCAspams(X,l,k,verbose,H0)
% Same as sparsePCA.m, but uses the SPAMS package
% (http://spams-devel.gforge.inria.fr/) to do fast online inference

sX = std(X(:));
X = X/sX; % scale the data to something reasonable
mX = mean(X,2);
X = bsxfun(@minus,X,mX);
l = l*sqrt(size(X,2)); % This allows the results to scale properly as the number of columns in H increases.
if nargin < 4, verbose = false; end
if nargin < 5
    [~,s,v] = svd(X,0);
    H = v(:,1:k)*sqrt(s(1:k,1:k));
else
    H = H0;
end
param.mode=2; % this mode seems to give the same results as Pfau's code
param.lambda=l;
param.lambda2 = 0;
param.posAlpha=0; % default is false
% param.modeD=0; % just the L-2 norm <= 1 restriction
param.modeD=1; % combined L-2 and L-1 (gamma1) norm for the dictionary
param.gamma1=0.3;
param.K=k;  % learns a dictionary with 5 elements
param.numThreads=1; % number of threads
param.iter=1000;  % let us see what happens after 1000 iterations.
param.verbose = verbose;

param.D = H;
H = mexTrainDL(X',param)';
W = mexLasso(X',H',param)';

for i = 1:k
    if mean(W(:,k))<0
        W(:,k) = -W(:,k);
        H(k,:) = -H(k,:);
    end
end
W = full(W);