function gamma = cal_gamma(xy, perc_map ,per_0, per_1, bottom, input_length)

gamma= -1e100*ones(8,input_length,2);

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

distance = zeros(8,input_length,2);

for s = 1:input_length
    for f = 1:8
        ref_0 = [input_0(f, 3), input_0(f, 4)];
        distance(input_0(f,2)+1,s,1) = vecnorm(ref_0 - xy(s,:));
        ref_1 = [input_1(f, 3), input_1(f, 4)];
        distance(input_1(f,2)+1,s,2) = vecnorm(ref_1 - xy(s,:));
    end
end


for s = 1:input_length
    for f = 1:8
        if perc_map(f,s,1) ~= 0
            gamma(f, s, 1) = per_0(1,s) - ((distance(f,s,1))^2 / bottom);
        end
        if perc_map(f,s,2) ~= 0
            gamma(f, s, 2) = per_1(1,s) - ((distance(f,s,2))^2 / bottom);
        end
    end
end

