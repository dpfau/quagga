function X = roiadmm(A,y,lam,sz)
% Minimize 1/2*||A(X)-y||^2 + lam||X||_* by ADMM. For debugging.

m = sz(1);
n = sz(2);
assert(prod(sz)==size(A,2));
assert(numel(y)==size(A,1));
X = zeros(sz);
Z = zeros(sz);
Z_ = Z;
U = zeros(sz);
rho = 100;

maxIter = 10000;
r_p = Inf;
r_d = Inf;
e_p = 0;
e_d = 0;
eps_rel = 1e-6;
eps_abs = 1e-6;

iter = 0;
fprintf('Iter:\tObj:\t\tr_p\t\te_p\t\tr_d\t\te_d\n');
% aug_lgrn = @(x,z,u) 1/2*norm(A*x(:)-y)^2 + lam*sum(svd(z)) + rho/2*norm(x-z+u,'fro')^2;
while iter < maxIter && (r_p > e_p || r_d > e_d)
    iter = iter+1;
    
    Z_ = U - Z_;
    X = reshape(pinv([A; sqrt(rho)*eye(m*n)])*[y+A*(Z_(:)); zeros(m*n,1)],sz) - Z_;
    U = U + X;
    [u,s,v] = svd(U,0);
    s(1:m+1:end) = max(0,s(1:m+1:end)-lam/rho);
    Z_ = u*s*v';    
    U = U - Z_;
    
    r_p = norm(X-Z_,'fro');
    r_d = norm(Z-Z_,'fro');
    e_p = eps_abs*sqrt(n) + eps_rel*(norm(X,'fro')+norm(Z_,'fro'))/2;
    e_d = eps_abs*sqrt(n) + eps_rel*norm(U,'fro');
    fprintf('%d\t%f\t%f\t%f\t%f\t%f\n',iter,1/2*norm(A*X(:)-y)^2+lam*sum(svd(X)),r_p,e_p,r_d,e_d);
    
    Z = Z_;
end