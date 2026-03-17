function [a_xz,sigma] = add_noise_m1(xz, dB)

r = (length(xz))/((length(xz)+3)*3);

dB = 10^(dB/20);

sigma = (1/sqrt(r))*(1/dB);

noise = normrnd(0,sigma,size(xz));

a_xz = xz + 2*noise;

end