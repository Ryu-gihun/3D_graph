function lamda4 = even_decoder(a_xz2, perc_map, lamda3, lamda3_1, bottom, cal_length, num, rule, inv_rule)

c_t = lamda3 - lamda3_1;
%c_t = min(max(c_t, 700), -700);

[per_0, per_1] = percenti(c_t,num);
per_0(1:num) = per_0(rule);
per_1(1:num) = per_1(rule);

gamma_map = cal_gamma(a_xz2, perc_map, per_0, per_1, bottom, cal_length);
alpha_map = cal_alpha(gamma_map);
beta_map = cal_beta(gamma_map);
lamda4_int = cal_lamda(gamma_map, alpha_map, beta_map);

lamda4 = lamda4_int;                 % 길이 유지 (num+3 등)
lamda4(1:num) = lamda4_int(inv_rule);
