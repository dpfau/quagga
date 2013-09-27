function X = larsMat(A,B,l)
% Implements least angle regression:
% X = argmin_X l*||X||_1 + 1/2||X*A-B||^2_F
% which is equivalent to
% X = argmin_X l*||vec(X)||_1 + 1/2||kron(A'*eye(p)*vec(X)-vec(B)||^2_2
% to which we can apply the LARS algorithm. We take advantage of the structure 
% in kron(A'*eye(p)) to save on memory and speed up computation.
% Here X, B and A are all matrices
% David Pfau, 2013

[m,n] = size(A);
[p,q] = size(B);
assert(q==n)

% scale A so that kron(A',eye(p)) has zero mean and unit variance in each column
mA = mean(A,2)/p; % mean(kron(A'),eye(p)) = mean(A')/p
A  = bsxfun(@minus,A,mA);
sA = sum(A.^2,2);
A  = bsxfun(@rdivide,A,sqrt(sA));
mB = mean(B(:));
B  = B-mB;
cA = A*A'; % inner product of the rows of A, precomputed for speed

X = zeros(p,m);
mu = zeros(p,q); % prediction
active = zeros(p,m);
resid = B;
obj_old = 1/2*norm(resid,'fro');
for k = 1:numel(X)
	% Pretty much switch to Efron et al notation here, which might get a bit confusing with my notation X, A and B (their beta, X and Y)
	c = resid*A'; % the current correlations.
	C = max(abs(C(:)));
	active = abs(c)==C; % active set (should have at least one more element than on the last iteration)
	keyboard % debug point: check that the active set grows by one each step, and that numerical rounding isn't screwing us

	u_A = zeros(p,q);
	for i = 1:p
		u_A(i,:) = sum(pinv(diag(sign(c(i,active(i,:))))*A(active(i,:),:)));
	end
	u_A = u_A/norm(u_A,'fro'); % normalize equiangular vector
	A_A = A(1,:)*u_A(1,:)'; % since this is equiangular, should be the same for all rows
	keyboard % debug point: check that the equiangular vector is actually equiangular
	a = u_A*A';
	gamma_1 = (C-c)./(A_A-a);
	gamma_2 = (C+c)./(A_A+a);
	gamma_1(gamma_1<=0 || active) = Inf; % remove elements that are already active or would result in an increase of the residual
	gamma_2(gamma_2<=0 || active) = Inf;
	gamma_mat = min(gamma_1,gamma_2);
	[gamma,j] = min(gamma_mat); % the new coefficient to add to the prediction, as well as the index of the new element in the active set (to check on the next iteration)
	mu = mu + gamma*u_A;
	resid = B-mu;

	% obj_new = l*sum(abs(X(:))) + 1/2*norm(resid,'fro')^2;
	% if obj_new > obj_old
	% 	X(i) = 0; % set the newest nonzero index back to zero
	% 	break
	% end
end
% scale columns of X to account for the normalization of the rows of A
X = bsxfun(@divide,X,sqrt(sA)');