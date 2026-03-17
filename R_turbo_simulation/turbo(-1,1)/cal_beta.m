function beta = cal_beta(gamma)

beta = -1e100*ones(8,length(gamma)+1);
T = size(gamma,2);
beta(1, T+1) = log(1);

for r = T:-1:1
    beta(1,r) = max((beta(1,r+1)+gamma(1,r,1)), (beta(5,r+1)+gamma(5,r,2)));%0
    beta(2,r) = max((beta(5,r+1)+gamma(5,r,1)), (beta(1,r+1)+gamma(1,r,2)));%1
    beta(3,r) = max((beta(6,r+1)+gamma(6,r,1)), (beta(2,r+1)+gamma(2,r,2)));%2
    beta(4,r) = max((beta(2,r+1)+gamma(2,r,1)), (beta(6,r+1)+gamma(6,r,2)));%3
    beta(5,r) = max((beta(3,r+1)+gamma(3,r,1)), (beta(7,r+1)+gamma(7,r,2)));%4
    beta(6,r) = max((beta(7,r+1)+gamma(7,r,1)), (beta(3,r+1)+gamma(3,r,2)));%5
    beta(7,r) = max((beta(8,r+1)+gamma(8,r,1)), (beta(4,r+1)+gamma(4,r,2)));%6
    beta(8,r) = max((beta(4,r+1)+gamma(4,r,1)), (beta(8,r+1)+gamma(8,r,2)));%7
end

