function [X,Y] = larsMat(A,B,l,X0,Y0,verbose)
% Implements least angle regression:
% X = argmin_X l*||X||_1 + 1/2||X*A-B||^2_F
% which is equivalent to
% X = argmin_X l*||vec(X)||_1 + 1/2||kron(A'*eye(size(X,1)))*vec(X)-vec(B)||^2_2
% to which we can apply the LARS algorithm, which is only applicable when the
% predictor is one dimensional. We take advantage of the structure in kron(A'*eye(size(X,1)))
% to save on memory and speed up computation.
% Here X, B and A are all matrices
% David Pfau, 2013