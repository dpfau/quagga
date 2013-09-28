% Compare admmLassoMat and larsMat for the same optimization problem. Check that they give the same result, and compare speed
p = 400;
q = 800;

X = randn(p,q);
beta = randn(q,1).*(rand(q,1)<0.2);
Y = X*beta + randn(p,1);
tic
x = admmLasso(X,Y,2); 
admm_time = toc;

tic
lars(X,Y,nnz(abs(x)>max(abs(x))/1e3));
lars_time = toc;

fprintf('ADMM: %fs, LARS: %fs\n',admm_time,lars_time)
keyboard

k = 5;

A = randn(k,q);
X = randn(p,k).*(rand(p,k)<0.2);
B = X*A + randn(p,q);

tic, X_lars = larsMat(A,B,100); toc
tic, X_admm = admmLassoMat(A,B,100); toc