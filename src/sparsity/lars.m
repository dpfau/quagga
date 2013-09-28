function lars(X,Y,q)
% For debugging purposes, I'm also implementing standard LARS (where Y is a vector) to make sure I didn't make any stupid mistakes in the code.

[n,m] = size(X);
assert(size(Y,1)==n)
assert(size(Y,2)==1)

Y = Y-mean(Y);
X = bsxfun(@minus,X,mean(X,2));
X = X/diag(std(X));

active = false(m,1);
mu = zeros(n,1);
k = 0;
while k < q && norm(Y-mu) > 1e-12;
	k = k+1;
    disp([num2str(k) ': ' num2str(norm(Y-mu))])
	c = X'*(Y-mu);
	[C,j] = max(c);
	if k == 1
		active(j) = true;
	end

	X_A = X(:,active)*diag(sign(c(active)));
	u_A = X_A*((X_A'*X_A)\ones(k,1));
	u_A = u_A/norm(u_A);
	A_A = mean(X_A'*u_A); % check "equiangularity"
	a = X'*u_A;
	gamma_1 = (C-c)./(A_A-a);
	gamma_2 = (C+c)./(A_A+a);
	gamma_1(gamma_1<=0 | active) = Inf; % remove elements that are already active or would result in an increase of the residual
	gamma_2(gamma_2<=0 | active) = Inf;
	gamma_vec = min(gamma_1,gamma_2);
	[gamma,j] = min(gamma_vec(:)); % the new coefficient to add to the prediction, as well as the index of the new element in the active set (to check on the next iteration)
	mu = mu + gamma*u_A;
    active(j) = true;
end