T  = 1e3; % number of data sets to generate
N  = 1000; % number of data in each set
N_ = 100; % number of held out data

m  = 5; % input dimensions
m_ = 5; % number of extra dimensions to fit
k  = 20;  % output dimensions
b  = randn(k,m); % true parameters

Q = randn(k); % noise covariance
Q = Q*Q';

lr_rel = zeros(N_,1);
lr_irr = zeros(N_,1);
for i = 1:T
    disp(num2str(i))
    X  = randn(m,N); % inputs
    X_ = randn(m,N_); % held out inputs
    Y = b*X + chol(Q)'*randn(k,N); % outputs
    Y_ = b*X_ + chol(Q)'*randn(k,N_); % held out outputs
    
    x  = randn(m_,N); % irrelevant variables
    x_ = randn(m_,N_); % irrelevant held out variables (used for making irrelevant predictions...so judgemental)

    b_hat_all = Y*[X;x]'/([X;x]*[X;x]'); % fitting to all variables
    b_hat_rel = Y*[X(1:m-1,:);x]'/([X(1:m-1,:);x]*[X(1:m-1,:);x]'); % fitting without a relevant variable
    b_hat_irr = Y*X'/(X*X'); % fitting without the irrelevant variable
    
    e_all = Y - b_hat_all*[X;x];
    e_rel = Y - b_hat_rel*[X(1:m-1,:);x];
    e_irr = Y - b_hat_irr*X;
    
    e_all_ = Y_ - b_hat_all*[X_;x_];
    e_rel_ = Y_ - b_hat_rel*[X_(1:m-1,:);x_];
    e_irr_ = Y_ - b_hat_irr*X_;
    
    Q_all = e_all*e_all'/N;
    Q_rel = e_rel*e_rel'/N;
    Q_irr = e_irr*e_irr'/N;
    
    eQe_rel = trace(e_rel_'*(Q_rel\e_rel_));
    eQe_irr = trace(e_irr_'*(Q_irr\e_irr_));
    eQe_all = trace(e_all_'*(Q_all\e_all_));
    
    lr_rel(i) = eQe_rel - eQe_all + 2*N*sum(log(diag(chol(Q_rel)))) - 2*N*sum(log(diag(chol(Q_all))));
    lr_irr(i) = eQe_irr - eQe_all + 2*N*sum(log(diag(chol(Q_irr)))) - 2*N*sum(log(diag(chol(Q_all))));
end

clf

subplot(1,2,1);
[~,x] = hist(lr_rel,100);
hist(lr_rel,x); hold on
plot(x,T*chi2pdf(x,m_*k)*(x(2)-x(1)),'r','LineWidth',2);
title('Log likelihood, Null is false')

subplot(1,2,2);
[~,x] = hist(lr_irr,100);
hist(lr_irr,x); hold on
plot(x,T*chi2pdf(x,m_*k)*(x(2)-x(1)),'r','LineWidth',2);
title('Log likelihood, Null is true')