
%output = [1 1 1 0 1 0 1 0 0 1 0 1 1 1 0 1 0 1 1 1];
output = enc_result;
DB = 16;
r = 1/2;
db = 10^(DB/20);
sigma = (1/sqrt(r))*(1/db);
noise = normrnd(0, sigma, [1,length(output)]);

for num = 1:length(output)
    if output(num) == 0
        output(num) = -1;
    else
        output(num) = 1;
    end
end

o = output + 2*noise;
N = size(output,2);
e = 0;
k=9;
input = zeros(1,N/2); %input 뒤쪽 가장의 0 까지
I = size(input,2); %input 뒤 쪽 가정된 0의 길이 까지
map = zeros(2^(k+1)-1, k);%계산된input값 저장
state_map = zeros(2^k,k);
input_result = zeros(1,N/2-k+1);%error가 가장큰 input값 저장을 얻기위해
%decide status length k
if k==5
    n1 = [1,1,1,0,1];
    n2 = [1,0,0,1,1];
elseif k ==6
    n1 = [1,0,1,0,0,1];
    n2 = [1,1,1,0,1,1];
elseif k ==7
    n1 = [1,1,1,1,0,0,1];
    n2 = [1,0,1,1,0,1,1];
elseif k ==8
    n1 = [1,1,1,1,1,0,0,1];
    n2 = [1,0,1,0,0,1,1,1];
elseif k ==9
    n1 = [1,1,1,1,0,1,0,1,1];
    n2 = [1,0,1,1,1,0,0,0,1];
end
state = zeros(1,I);
result = zeros(1,2);%set result
a = 0;
for n = 1:k
    if n==1
        state = map(1,:);
        state(1,1) = 0;
        for r = 1:k
            map(2,r) =  state(1, r);
        end
        state(1,1) = 1;
        for r = 1:k
           map(3,r) =  state(1, r);
        end
    else
        max_a = 2^(n-1)-1;
        while a <= max_a
            state(1,:) = map(2^(n-1)+a,:);
            state = circshift(state,1);
            state(1,1) = 0;
            for r = 1:k
                map(2^n+2*a,r) =  state(1, r);
            end
            state(1,1) = 1;
            for r = 1:k
                map(2^n+2*a+1,r) =  state(1, r);
            end
            a = a + 1;
        end
        a = 0;
    end
end
for q = 1:2^(k)
    state_map(q,:) = map(2^(k)+q-1,:);
end
%2열짜리 배열 1열에 input이 0일 때 길 저장, 2열에 input이 1일 때 길 저장
way = zeros(2^(k-1),2);
state_m1 = zeros(2^(k-1),2);
state_m0 = zeros(2^(k-1),2);
all_state = zeros(2^(k-1),k-1);
%state 저장
for i = 1:2^(k-1)
    for  j = 1:(k-1)
    all_state(i,j) = state_map(i*2,j+1);
    end
end
after_s = zeros(1,k-1);
for q = 1 : 2^(k-1)
    %input : 0
    state_way = [0 all_state(q,:)];
    for a = 1:2^(k-1)
        after_s = circshift(all_state(q,:),1);
        after_s(1,1) = 0;
        if isequal(all_state(a,:), after_s(1,:))
            way(q,1) = a;
            x = 0;
            y = 0;
            for b=1:k
                if n1(1,b)==1
                    x = x + state_way(1,b);
                end
                if n2(1,b)==1
                    y = y + state_way(1,b);
                end
            end
            result1 = mod(x,2);
            result2 = mod(y,2);
    
            state_m0(q,1) = result1;
            state_m0(q,2) = result2;
        end
    end
    
    %input : 1
    state_way = [1 all_state(q,:)];
    for a = 1:2^(k-1)
        after_s = circshift(all_state(q,:),1);
        after_s(1,1) = 1;
        if isequal(all_state(a,:), after_s(1,:))
            way(q,2) = a;
            x = 0;
            y = 0;
            for b=1:k
                if n1(1,b)==1
                    x = x + state_way(1,b);
                end
                if n2(1,b)==1
                    y = y + state_way(1,b);
                end
            end
            result1 = mod(x,2);
            result2 = mod(y,2);
    
            state_m1(q,1) = result1;
            state_m1(q,2) = result2;
        end
    end
end
error_map = zeros(2^(k-1),I+1);
error_map(:,:) = -999;
error_map(1,N/2+1) = 0;
out_data = zeros(1,2);
size_m0_1 = size(state_m0,1);
size_m0_2 = size(state_m0,2);
compare_m0 = state_m0;
for i = 1:size_m0_1
    for j = 1:size_m0_2
        if state_m0(i,j) == 0
        compare_m0(i,j) = -1;
        end
    end
end
size_m1_1 = size(state_m1,1);
size_m1_2 = size(state_m1,2);
compare_m1 = state_m1;
for i = 1:size_m1_1
    for j = 1:size_m1_2
        if state_m1(i,j) == 0
        compare_m1(i,j) = -1;
        end
    end
end
leng = size(error_map,2);
oz_map = zeros(2^(k-1),I+1);
oz_map(1,I+1) = 1;
big_num = 1;
select_num = 1;

for c = N/2+1:-1:2
    error_cal = zeros(1,2);%에러 계산 초기화
    
    data1 = o(1,2*(c-1)-1);
    data2 = o(1,2*(c-1));
    out_data = [data1, data2];%ouput2자리 가져오기
    p = select_num;
    
    [rowIndices, colIndices] = find(way == p);
    find_way = [rowIndices, colIndices];
    first = find_way(1,1);
    second = find_way(2,1);
    
    if mod(find_way(1,2),2) == 1
        e0 = compare_m0(first,1)*out_data(1,1) + compare_m0(first,2)*out_data(1,2);
        error_cal(1,1) = e0 + error_map(p,c);
    else
        e0 = compare_m1(first,1)*out_data(1,1) + compare_m1(first,2)*out_data(1,2);
        error_cal(1,1) = e0 + error_map(p,c);
    end
    
    if mod(find_way(2,2),2) == 1
        e1 = compare_m0(second,1)*out_data(1,1) + compare_m0(second,2)*out_data(1,2);
        error_cal(1,2) = e1 + error_map(p,c);
    else
        e1 = compare_m1(second,1)*out_data(1,1) + compare_m1(second,2)*out_data(1,2);
        error_cal(1,2) = e1 + error_map(p,c);
    end
    
    if error_cal(1,1) > error_cal(1,2)
        e = e + e0;
        error_map(first,c-1) = e;
        oz_map(first,c-1) = 1;
        select_num = first;
    elseif error_cal(1,1) < error_cal(1,2)
        e = e + e1;
        error_map(second,c-1) = e;
        oz_map(second,c-1) = 1;
        select_num = second;
    end
end

for i = 1:I
    for j = 1:2^(k-1)
        if oz_map(j, i+1) == 1
            cal_oz = mod(j,2);
            
            if cal_oz == 0
                input(1,i) = 1;
            elseif cal_oz == 1
                input(1,i) = 0;
            end
    
        end
    end
end

for i = 1:I-k+1
    input_result(1,i) = input(1,i);
end

%disp(input_result);

for i = 1:I-k+1
    if start_i(1,i) ~= input_result(1,i)
        error_stack = error_stack + 1;
    end
end

disp(error_stack);