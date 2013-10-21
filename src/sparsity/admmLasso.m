function x = admmLasso(A,b,l,optose)
% Implements ADMM for LASSO regression:
% x = argmin_x l*||x||_1 + 1/2||Ax-b||^2_2
% David Pfau, 2013

if nargin < 4, optose = true; end
[m,n] = size(A);
assert(numel(b)==m)

rho = 10*l;
eps_rel = 1e-3;
eps_abs = 1e-6;
maxIter = 500;

shrinkage = @(x,t) sign(x).*max(abs(x)-t,0);

r_p = Inf;  r_d = Inf;
e_p = 0;    e_d = 0;
z = zeros(n,1);
y = zeros(n,1);
tic, X = eye(n)/rho - A'/(eye(m)+A*A'/rho)*A/rho^2; toc
iter = 0;
if optose, figure; end
fprintf('Obj:\t\t r_p:\t\t e_p:\t\t r_d:\t\t e_d:\t\t nnz:\n')
while (r_p > e_p || r_d > e_d) && iter < maxIter
    x  = X*(A'*b + rho*z - y);
    z_ = shrinkage( x + y/rho, l/rho );
    y  = y + rho*( x - z_ );
    
    r_p = norm( x - z_ );
    r_d = rho*norm( z - z_ );
    e_p = sqrt(n)*eps_abs + eps_rel*max( norm(x), norm(z_) );
    e_d = sqrt(n)*eps_abs + eps_rel*max( norm(y) );
    
    z = z_;
    
    fprintf( '%1.2e\t %1.2e\t %1.2e\t %1.2e\t %1.2e\t %d\n', ...
        l*sum(abs(x(:))) + 1/2*norm( A*x - b )^2, r_p, e_p, r_d, e_d, nnz(abs(x)>max(abs(x))/1e3) );
    if optose && mod(iter,10) == 0
        hold off, scatter(1:numel(x),x), hold on
        for i = 1:numel(x)
            line([i i],[0 x(i)]); 
        end
        drawnow
    end
    iter = iter + 1;
end