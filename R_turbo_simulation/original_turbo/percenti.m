function [per_0 , per_1] = percenti(c_t,input_length)

per_1 = zeros(1,input_length); % p의 값
per_0 = zeros(1,input_length); % 1-p의 값

for i = 1:input_length

    % perl_1(i) = log(p1(i));
    
    % perl_0(i) = log(p0(i));

    per_1(i) = -log1p(exp(-c_t(i)));

    per_0(i) = -log1p(exp(c_t(i)));
end
per_1 = [per_1,log(0.5),log(0.5),log(0.5)];
per_0 = [per_0,log(0.5),log(0.5),log(0.5)];

end