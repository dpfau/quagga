function [W,H] = sparsePCA(X,l,k,W0)
% Approximately solve min_Y l||W||_1 + 1/2*||W*H-X||^2_F, where W has k columns
% and H has k rows.

verbose = true;
maxIter = 30;
if nargin < 4
    [u,s,~] = svd(X,0);
    W = u(:,1:k)*sqrt(s(1:k,1:k));
else
    W = W0;
end
Y = zeros(size(W)); % Lagrange multiplier. Speeds convergence on later iterations.
obj_ = Inf;
obj  = l*sum(abs(W(:)))+1/2*norm(W*pinv(W)*X-X,'fro')^2;
iter = 0;
while abs(obj-obj_) > 1e-5*obj && iter < maxIter
    iter = iter+1;
    H = trustRegionMin(W,X);
    [W,Y] = admmLassoMat(H,X,l,W,Y,false);
    obj_ = obj;
    obj  = l*sum(abs(W(:)))+1/2*norm(W*H-X,'fro')^2;
    if verbose
        fprintf('Iter %d: %1.4f\n',iter,obj); 
    end
end

for i = 1:k
    if mean(W(:,k))<0
        W(:,k) = -W(:,k);
        H(k,:) = -H(k,:);
    end
end

function H = trustRegionMin(W,X)
% Minimize 1/2*||W*H-X||^2_F under the constraint that each row of H has norm
% less than or equal to one, by ADMM

debug = false;
m = size(W,2);
n = size(X,2);

eps_rel = 1e-3;
eps_abs = 1e-3;
maxIter = 50;
minIter = 3;
rho = 10;

H = zeros(m,n);
Z = zeros(m,n); % aux variable
U = zeros(m,n); % lagrangian

r_p = Inf; r_d = Inf; % primal and dual residual
e_p = 0;   e_d = 0; % primal and dual tolerance
iter = 0;
if debug, fprintf('Obj:\t\t rp:\t\t ep:\t\t rd:\t\t ed:\n'), end
while ( (r_p > e_p || r_d > e_d) && iter < maxIter ) || iter < minIter
    iter = iter+1;
    if debug, obj1 = 1/2*norm(W*H-X,'fro')^2 + rho/2*norm(H-Z+U,'fro')^2; end
    H = (W'*W+rho*(eye(m)))\(W'*X+rho*(Z-U)); % min_H 1/2*||W*H-X||^2_F + rho/2*||H-Z+U||^2_F
    if debug, obj2 = 1/2*norm(W*H-X,'fro')^2 + rho/2*norm(H-Z+U,'fro')^2; end
    Z_ = H+U; % min_Z rho/2*||Z-H-U||^2_F given norm(Z(i,:)) <= 1 for all i
    for i = 1:m
        nrm = norm(Z_(i,:));
        if nrm > 1
            Z_(i,:) = Z_(i,:)/nrm;
        end
    end
    U = U + (H-Z_);
    
    r_p = norm(H-Z_,'fro');
    e_p = eps_abs*sqrt(numel(H)) + eps_rel*max(norm(H,'fro'),norm(Z_,'fro'));
    r_d = norm(Z-Z_,'fro');
    e_d = eps_abs*sqrt(numel(H)) + eps_rel*norm(U,'fro');
    
    Z = Z_;
    if debug
        fprintf('%1.5e->%1.5e\t%1.4e\t%1.4e\t%1.4e\t%1.4e\n',...
                obj1,obj2,...
                r_p,e_p,r_d,e_d)
    end
end