function alpha = cal_alpha(gamma)

T = size(gamma,2);
alpha = -1e100*ones(8,T+1);
alpha(1,1) = log(1);

for r = 1:T

    alpha(1,r+1) = max((alpha(1,r)+gamma(1,r,1)), (alpha(2,r)+gamma(1,r,2)));%0
    alpha(2,r+1) = max((alpha(4,r)+gamma(2,r,1)), (alpha(3,r)+gamma(2,r,2)));%1
    alpha(3,r+1) = max((alpha(5,r)+gamma(3,r,1)), (alpha(6,r)+gamma(3,r,2)));%2
    alpha(4,r+1) = max((alpha(8,r)+gamma(4,r,1)), (alpha(7,r)+gamma(4,r,2)));%3
    alpha(5,r+1) = max((alpha(2,r)+gamma(5,r,1)), (alpha(1,r)+gamma(5,r,2)));%4
    alpha(6,r+1) = max((alpha(3,r)+gamma(6,r,1)), (alpha(4,r)+gamma(6,r,2)));%5
    alpha(7,r+1) = max((alpha(6,r)+gamma(7,r,1)), (alpha(5,r)+gamma(7,r,2)));%6
    alpha(8,r+1) = max((alpha(7,r)+gamma(8,r,1)), (alpha(8,r)+gamma(8,r,2)));%7
end

