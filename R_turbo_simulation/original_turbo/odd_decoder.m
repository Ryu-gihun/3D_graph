function lamda3 = odd_decoder(a_xz, perc_map, lamda2, lamda2_1, bottom, cal_length, num)

c_t = lamda2 - lamda2_1;
%c_t = min(max(c_t, 700), -700);

[per_0, per_1] = percenti(c_t,num);
gamma_map = cal_gamma(a_xz, perc_map, per_0, per_1, bottom, cal_length);
alpha_map = cal_alpha(gamma_map);
beta_map = cal_beta(gamma_map);
lamda3 = cal_lamda(gamma_map, alpha_map, beta_map);