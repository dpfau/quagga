% a demo of overfitting, by god.

m  = 10; % useful input dimensions
m_ = 100; % useless input dimensions
n = 20; % output dimensions
N = 1e3; % number of time steps
N_ = 100; % number of held out data

b = randn(n,m); % true parameter
X = randn(m,N);
x = randn(m_,N);
Y = b*X + randn(n,N);

X_ = randn(m,N_);
x_ = randn(m_,N_);
Y_ = b*X_ + randn(n,N_);

sq_err  = zeros(m+m_,1);
sq_err_ = zeros(m+m_,1);
ll  = zeros(m+m_,1);
ll_ = zeros(m+m_,1);
for i = 1:m
    b_hat = Y*pinv(X(1:i,:));
    e  = Y  - b_hat*X(1:i,:);
    e_ = Y_ - b_hat*X_(1:i,:);
    Q = e*e'/N;
    sq_err(i)  = norm(e,'fro')^2/N;
    sq_err_(i) = norm(e_,'fro')^2/N_;
    ll(i)  = -1/2*sum(sum(e.*(Q\e))) - N*sum(log(diag(chol(Q))));
    ll_(i) = -1/2*sum(sum(e_.*(Q\e_))) - N*sum(log(diag(chol(Q))));
end

for i = 1:m_
    b_hat = Y*pinv([X;x(1:i,:)]);
    e  = Y  - b_hat*[X;x(1:i,:)];
    e_ = Y_ - b_hat*[X_;x_(1:i,:)];
    Q = e*e'/N;
    sq_err(m+i) = norm(e,'fro')^2/N;
    sq_err_(m+i) = norm(e_,'fro')^2/N_;
    ll(m+i)  = -1/2*sum(sum(e.*(Q\e))) - N*sum(log(diag(chol(Q))));
    ll_(m+i) = -1/2*sum(sum(e_.*(Q\e_))) - N*sum(log(diag(chol(Q))));
end