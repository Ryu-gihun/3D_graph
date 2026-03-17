function lamda = cal_lamda(gamma, alpha, beta)

T = size(gamma,2);
lamda = -1e100*ones(1, T+1);

i_0 = zeros(8,T);
i_1 = zeros(8,T);

for r = 1:T
    i_0(1,r) = alpha(1,r) + gamma(1,r,1) + beta(1, r+1);
    i_0(2,r) = alpha(4,r) + gamma(2,r,1) + beta(2, r+1);
    i_0(3,r) = alpha(5,r) + gamma(3,r,1) + beta(3, r+1);
    i_0(4,r) = alpha(8,r) + gamma(4,r,1) + beta(4, r+1);
    i_0(5,r) = alpha(2,r) + gamma(5,r,1) + beta(5, r+1);
    i_0(6,r) = alpha(3,r) + gamma(6,r,1) + beta(6, r+1);
    i_0(7,r) = alpha(6,r) + gamma(7,r,1) + beta(7, r+1);
    i_0(8,r) = alpha(7,r) + gamma(8,r,1) + beta(8, r+1);

    i_1(1,r) = alpha(2,r) + gamma(1,r,2) + beta(1, r+1);
    i_1(2,r) = alpha(3,r) + gamma(2,r,2) + beta(2, r+1);
    i_1(3,r) = alpha(6,r) + gamma(3,r,2) + beta(3, r+1);
    i_1(4,r) = alpha(7,r) + gamma(4,r,2) + beta(4, r+1);
    i_1(5,r) = alpha(1,r) + gamma(5,r,2) + beta(5, r+1);
    i_1(6,r) = alpha(4,r) + gamma(6,r,2) + beta(6, r+1);
    i_1(7,r) = alpha(5,r) + gamma(7,r,2) + beta(7, r+1);
    i_1(8,r) = alpha(8,r) + gamma(8,r,2) + beta(8, r+1);
end

max_i1 = max(i_1,[],1);
max_i0 = max(i_0,[],1);

c_t = max_i1 - max_i0;

lamda = min(max(c_t, -700), 700);