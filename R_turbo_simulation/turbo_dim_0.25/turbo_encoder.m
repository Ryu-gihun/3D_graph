function [x,z] = turbo_encoder(input)

tale_input = [input 0 0 0];
input_l = length(tale_input);
x = zeros(1,input_l);
z = zeros(1,input_l);
d_array = zeros(1,3);


for i = 1:input_l
    a = d_array(1,2) + d_array(1,3);
    if i > length(input)
        tale_input(1,i) = mod(a,2);
    end
    k = mod(a + tale_input(1,i),2);
    b = k + d_array(1,1);
    c = b + d_array(1,3);

    z_k = mod(c,2);
    x_k = tale_input(1,i);

    d_array = circshift(d_array,1);
    d_array(1,1) = k;

    x(1,i) = x_k;
    z(1,i) = z_k;
end