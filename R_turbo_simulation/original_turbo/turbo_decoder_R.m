%map(1,1) 초기화 : -1e100*ones;
%거리값 초기화 : ap_map(1,1) = log(1);

%encoder input = [1 0 0 1 0 0 1 1 0];
encode_result_x = x;
encode_result_z = z;

input_0 = [0 0 0 0
    1 4 0 0
    2 5 0 1
    3 1 0 1
    4 2 0 1
    5 6 0 1
    6 7 0 0
    7 3 0 0];

input_1 = [0 4 1 1
    1 0 1 1
    2 1 1 0
    3 5 1 0
    4 6 1 0
    5 2 1 0
    6 3 1 1
    7 7 1 1];

xz =[encode_result_x(:),encode_result_z(:)];

%set DB
DB = 20;

[a_xz,sigma] = add_noise(xz, DB);
bottom = 2*(sigma^2);

map_long = length(encode_result_x);
perc_map = zeros(8,map_long,2);
perc_map(1,1,1) = 0.5;
perc_map(5,1,2) = 0.5;

input_length = length(encode_result_x);

%(-,-,1) : input 0
%(-,-,2) : input 1

for b = 1:map_long
    for a = 1:8
        if perc_map(a,b,1) ~= 0
            perc_map(input_0(a,2)+1, b+1, 1) = 0.5;%0 input
            perc_map(input_1(a,2)+1, b+1, 2) = 0.5;%1 input
        end
        
        if perc_map(a,b,2) ~= 0
            perc_map(input_0(a,2)+1, b+1, 1) = 0.5;%0 input
            perc_map(input_1(a,2)+1, b+1, 2) = 0.5;%1 input

        end
    end
end

gamma_map = cal_gamma(a_xz, perc_map, bottom,input_length);  % 초기화

alpha_map = cal_alpha(gamma_map);

beta_map = cal_beta(gamma_map);

lamda = cal_lamda(gamma_map, alpha_map, beta_map);
result = zeros(1,length(lamda));

for t = 1:length(lamda)
    if lamda(1,t) >= 0
        result (1,t) = 1;
    elseif lamda(1,t) < 0
        result (1,t) = 0;
    end
end

disp(result);


