function [X,Y] = admmLassoMat(A,B,l,X0,Y0,verbose)
% Implements ADMM for LASSO regression:
% X = argmin_X l*||X||_1 + 1/2||X*A-B||^2_F
% Here X, B and A are all matrices
% David Pfau, 2013

[m,n] = size(A);
[p,q] = size(B);
assert(q==n)

eps_rel = 1e-3;
eps_abs = 1e-3;
maxIter = 50;
minIter = 10;

shrinkage = @(x,t) sign(x).*max(abs(x)-t,0);

r_p = Inf;  r_d = Inf;
e_p = 0;    e_d = 0;
if nargin < 4, X0 = zeros(p,m); end
if nargin < 5, Y0 = zeros(p,m); end
if nargin < 6, verbose = false; end
if nargin < 7, rho = 10*l;      end
X = zeros(p,m);
Z = X0;
Y = Y0;
iter = 0;
AAr = inv(A*A' + rho*eye(m));
if verbose, fprintf('\tLASSO: Obj\t\t r_p\t\t e_p\t\t r_d\t\t e_d\t\t nnz\n'); end
while ( (r_p > e_p || r_d > e_d) && iter < maxIter ) || iter < minIter
    b  =  (B*A' + rho*Z - Y);
    for i = 1:p
        X(i,:) = b(i,:)*AAr;
    end
    Z_ = shrinkage( X + Y/rho, l/rho );
    Y  = Y + rho*( X - Z_ );
    
    r_p = norm( X - Z_ );
    r_d = rho*norm( Z - Z_ );
    e_p = sqrt(n)*eps_abs + eps_rel*max( norm(X), norm(Z_) );
    e_d = sqrt(n)*eps_abs + eps_rel*max( norm(Y) );
    
    Z = Z_;
    
    if verbose
        fprintf( '\t\t%1.2e\t %1.2e\t %1.2e\t %1.2e\t %1.2e\t %d\n', ...
            l*sum(abs(X(:))) + 1/2*norm( X*A - B )^2, r_p, e_p, r_d, e_d, nnz(abs(X(:))>max(X(:))/1e3) );
    end
    iter = iter + 1;
end