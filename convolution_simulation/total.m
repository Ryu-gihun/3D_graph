x = zeros(5,100);
y = zeros(5,100);
figure;
hold on;
grid on;
set(gca, 'YScale', 'log'); % X, Y축 로그 스케일 적용
xlabel('DB');
ylabel('BER');
title('Bit Error Rate vs DB for Different Constraint Lengths (k)');
colors = ['b','g','r','c','m'];
k = 9;

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

I = 200 + k - 1;%input 뒤 쪽 가정된 0의 길이 까지

map = zeros(2^(k+1)-1, k);%계산된input값 저장
state_map = zeros(2^k,k);

state = zeros(1,I);
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


for DB = 9:16
    error_stack = 0;
    run_count = 0;

    r = 1/2;
    db = 10^(DB/20);
    sigma = (1/sqrt(r))*(1/db);
    while(1)
        %incoder
        start_i = randi([0 1], 1, 200);
        n = size(start_i,2);

        state = zeros(1,k);
        enc_result = zeros(1, 2*(n+k-1));

        for a=1:(n+k-1)

            x=0;
            y=0;

            if a<= n
                state(1,1) = start_i(1,a);
            else
                state(1,1) = 0;
            end

            for b=1:k
                if n1(1,b)==1
                    x = x + state(1,b);
                end
                if n2(1,b)==1
                    y = y + state(1,b);
                end
            end
            result1 = mod(x,2);
            result2 = mod(y,2);

            state = circshift(state,1);


            enc_result(1,2*a-1) = result1;
            enc_result(1,2*a) = result2;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % decoder

        output = enc_result;
        o_length = length(output);
        for num = 1:o_length
            if output(num) == 0
                output(num) = -1;
            else
                output(num) = 1;
            end
        end


        noise=normrnd(0,sigma,[1,length(output)]);
        o = output+ 2*noise;

        N = size(output,2);
        e = 0;

        input = zeros(1,N/2); %input 뒤쪽 가장의 0 까지
        input_result = zeros(1,N/2-k+1);%error가 가장큰 input값 저장을 얻기위해

        error_map = zeros(2^(k-1),I);
        error_map(:,:) = -999;
        error_map(1,1) = 0;

        out_data = zeros(1,2);
        compare_output = zeros(1,N);
        for w = 1:N
            if o(1,w) == 0
                compare_output(1,w) = -1;
            end
        end

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

        oz_map = zeros(2^(k-1),I+1);
        oz_map(1,I+1) = 1;
        oz_way = ones(2^(k-1),I).*-1000;

        for c = 1:N/2
            error_cal = zeros(2^k,2);%에러 계산 초기화
            data1 = o(1,2*c-1);
            data2 = o(1,2*c);
            out_data = [data1, data2];%ouput2자리 가져오기
            for i = 1:2^(k-1)
                %input 0 경로
                e = compare_m0(i,1)*out_data(1,1) + compare_m0(i,2)*out_data(1,2);
                if error_cal(way(i,1),1)==0
                    error_cal(way(i,1),1) = e + error_map(i,c);
                else
                    error_cal(way(i,1),2) = e + error_map(i,c);
                end
                %input 1 경로
                e = compare_m1(i,1)*out_data(1,1) + compare_m1(i,2)*out_data(1,2);
                if error_cal(way(i,2),1)==0
                    error_cal(way(i,2),1) = e + error_map(i,c);
                else
                    error_cal(way(i,2),2) = e + error_map(i,c);
                end
            end

            for i=1:2^(k-1)
                if error_cal(i,1)> error_cal(i,2)
                    error_map(i,c+1)=error_cal(i,1);
                    oz_way(i,c)=0;
                else
                    error_map(i,c+1)=error_cal(i,2);
                    oz_way(i,c)=1;
                end
            end

            for i = 1:2^(k-1)
                error_map(i,c+1) = max(error_cal(i,:));
            end
        end

        for i = I:-1:2
            for j=1:2^(k-1)
                if oz_map(j,i+1) == 1
                    if oz_way(j,i) == 0
                        for jj = 1:2^(k-2)
                            if way(jj,1) == j
                                jjj=jj;
                                break;
                            elseif way(jj,2) == j
                                jjj=jj;
                                break;
                            end
                        end
                        oz_map(jjj,i) = 1;

                    elseif oz_way(j,i) ==1
                        for jj = 2^(k-2)+1:2^(k-1)
                            if way(jj,1)== j
                                jjj=jj;
                                break;
                            elseif way(jj,2)== j
                                jjj=jj;
                                break;
                            end
                        end
                        oz_map(jjj,i) = 1;
                    end

                end
            end
        end

        for i = 1:I
            for j = 1:2^(k-1)
                if oz_map(j,i+1) == 1
                    if mod(j,2) == 1
                        input(1,i) = 0;
                    else
                        input(1,i) = 1;
                    end
                end
            end
        end


        for i = 1:I-k+1
            input_result(1,i) = input(1,i);
        end

        for i = 1:I-k+1
            if start_i(1,i) ~= input_result(1,i)
                error_stack = error_stack + 1;
            end
        end

        %횟수 및 에러 설정
        run_count = run_count + 1;

        if error_stack >= 100 && run_count > 100
            break;
        end
        BER = error_stack/(200*run_count);
        disp([DB,run_count,error_stack]);
    end
    x(DB - 8) = DB; % DB 값을 x 축에 추가
    y(DB - 8) = error_stack / (200 *run_count); % 오류율 계산
    plot(x(1:DB-8), y(1:DB-8), 'b-o', 'LineWidth', 2);
    drawnow; % 즉시 플롯 업데이트
end














%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%set DB
%DB = 12;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%