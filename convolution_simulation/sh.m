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
legend_entries = {};
% if k==5
%     n1 = [1,1,1,0,1];
%     n2 = [1,0,0,1,1];
% elseif k==6
%     n1 = [1,0,1,0,0,1];
%     n2 = [1,1,1,0,1,1];
% elseif k==7
%     n1 = [1,1,1,1,0,0,1];
%     n2 = [1,0,1,1,0,1,1];
% elseif k==8
%     n1 = [1,1,1,1,0,0,0,1];
%     n2 = [1,0,1,0,0,1,1,1];
% elseif k==9
%     n1 = [1,1,1,1,0,1,0,1,1];
%     n2 = [1,0,1,1,1,0,0,0,1];
% end
for k_index = 1:5
    k = 4+k_index;
    n= 200;
    error_count = 0;
    number = 0;
    for DB = 9:14
        error_count = 0;
        number = 0;
        while(1)
            number = number+1;
            % if k==5
            %     n1 = [1,1,1,0,1];
            %     n2 = [1,0,0,1,1];
            % elseif k==6
            %     n1 = [1,0,1,0,0,1];
            %     n2 = [1,1,1,0,1,1];
            % elseif k==7
            %     n1 = [1,1,1,1,0,0,1];
            %     n2 = [1,0,1,1,0,1,1];
            % elseif k==8
            %     n1 = [1,1,1,1,0,0,0,1];
            %     n2 = [1,0,1,0,0,1,1,1];
            % elseif k==9
            %     n1 = [1,1,1,1,0,1,0,1,1];
            %     n2 = [1,0,1,1,1,0,0,0,1];
            % elseif k==3
            %     n1 = [1,1,1];
            %     n2 = [1,0,1];
            % end
            r_m = randi([0,1],1,n);
            input_bits = r_m;
            encoded_bits = convolution_encoder(k,input_bits);
            encoded_bits(encoded_bits==0) = -1;
            inp = reshape(encoded_bits,2,[])';
            inp(inp==0) = -1;
            r = (length(encoded_bits))/(length(encoded_bits)*2+2*(k-1));
            db = 10^(DB/20);
            sigma = (1/sqrt(r))*(1/db);
            noise = normrnd(0,sigma,[1,length(encoded_bits)]);
            encoded_bits_n = encoded_bits + 2*noise;
            inp_n = reshape(encoded_bits_n,2,[])';
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            st = zeros(2^(k-1),k+1,2);
            for i = 1:2^(k-1)
                st(i,1,1) = i-1; % 입력을 0을 받았을 때
                if mod(st(i,1),2) == 0
                    st(i,2,1) = st(i,1)/2;  % 2로 나누었을 때 나머지가 0. 즉 마지막 비트 값이 0
                else
                    st(i,2,1) = (st(i,1)-1)/2; % 2로 나누었을 때 나머지가 1. 즉 마지막 비트 값이 1
                end
                bin_st = dec2bin(st(i,2,1),k-1) - '0';  % 십진수 2진수 변환 후 저장
                for j = 1:k-1
                    st(i,j+2,1) = bin_st(j);
                end
                st(i,1,2) = i-1; % 입력을 1을 받았을 때
                if mod(st(i,1),2) == 0
                    st(i,2,2) = 2^(k-2)+st(i,1)/2; % 2로 나누었을 때 나머지가 0. 즉 마지막 비트 값이 0
                else
                    st(i,2,2) = 2^(k-2)+(st(i,1)-1)/2; % 2로 나누었을 때 나머지가 1. 즉 마지막 비트 값이 1
                end
                bin_st = dec2bin(st(i,2,2),k-1) - '0';  % 십진수 2진수 변환 후 저장
                for j = 1:k-1
                    st(i,j+2,2) = bin_st(j);
                end
            end
            st1 = zeros(2^(k-1),4,2);
            for i = 1:2^(k-1)
                st1(i,1,1) = i-1;
                b_st = dec2bin(st1(i,1,1),k-1) - '0';
                if k==5
                    n1 = [1,1,1,0,1];
                    n2 = [1,0,0,1,1];
                elseif k==6
                    n1 = [1,0,1,0,0,1];
                    n2 = [1,1,1,0,1,1];
                elseif k==7
                    n1 = [1,1,1,1,0,0,1];
                    n2 = [1,0,1,1,0,1,1];
                elseif k==8
                    n1 = [1,1,1,1,0,0,0,1];
                    n2 = [1,0,1,0,0,1,1,1];
                elseif k==9
                    n1 = [1,1,1,1,0,1,0,1,1];
                    n2 = [1,0,1,1,1,0,0,0,1];
                end
                m1 = [0,b_st];
                op1 = m1 .* n1;
                op2 = m1 .* n2;
                r1 = mod(sum(op1(:)),2);
                r2 = mod(sum(op2(:)),2);
                st1(i,2,1) = r1*2 + r2*1;
                st1(i,3,1) = r1;
                st1(i,4,1) = r2;
                st1(i,1,2) = i-1;
                b_st = dec2bin(st1(i,1,2),k-1) - '0';
                m2 = [1,b_st];
                op3 = m2 .* n1;
                op4 = m2 .* n2;
                r3 = mod(sum(op3(:)),2);
                r4 = mod(sum(op4(:)),2);
                st1(i,2,2) = r3*2 + r4*1;
                st1(i,3,2) = r3;
                st1(i,4,2) = r4;
            end
            st2 = zeros(2^(k-1),4);
            for i = 1:2^(k-1)
                st2(i,1) = st1(i,3,1);
                st2(i,2) = st1(i,4,1);
                st2(i,3) = st1(i,3,2);
                st2(i,4) = st1(i,4,2);
            end
            st2(st2==0) = -1;
            first_half = st2(:,1:2);
            second_half = st2(:,3:4);
            st4 = [first_half; second_half];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            bb = zeros(2^(k-1),n+k);
            bb1 = zeros(2^(k-1),n+k);
            for i = 1:2^(k-1)
                bb(1,1) = 0;
                bb(i,1) = -1000;
            end
            for i = 1:2^(k-1)
                bb1(i,1) = i-1;
            end
            for i = 1:size(inp_n,1)   % 1부터 5 -> 행 세로축
                for j = 1:size(st4,1)/2 % 1부터 4 -> 열 가로축
                    if j <= size(st4,1)/4
                        bb(j,i+1) = max(bb(2*j-1,i)+mi(st4(2*j-1,:),inp_n(i,1),inp_n(i,2)),bb(2*j,i)+mi(st4(2*j,:),inp_n(i,1),inp_n(i,2)));
                        if bb(j,i+1) == bb(2*j-1,i)+mi(st4(2*j-1,:),inp_n(i,1),inp_n(i,2))
                            bb1(j,i+1) = 0;
                        else
                            bb1(j,i+1) = 1;
                        end
                    else
                        bb(j,i+1) = max(bb(2*(j-size(st4,1)/4)-1,i)+mi(st4(2*j-1,:),inp_n(i,1),inp_n(i,2)),bb(2*(j-size(st4,1)/4),i)+mi(st4(2*j,:),inp_n(i,1),inp_n(i,2)));
                        if bb(j,i+1) == bb(2*(j-size(st4,1)/4)-1,i)+mi(st4(2*j-1,:),inp_n(i,1),inp_n(i,2))
                            bb1(j,i+1) = 0;
                        else
                            bb1(j,i+1) = 1;
                        end
                    end
                end
            end
            bb2 = zeros(2^(k-1),n+k);
            bb2(1,n+k) = 1;
            for i = size(inp,1):-1:1 % i는 1부터 5까지
                for j = 1:size(st4,1)/2 % j는 1부터 4까지
                    row = find(bb2(:,i+1));
                    if bb1(row,i+1) == 0
                        if row <= size(st4,1)/4
                            bb2(2*row-1,i) = 1;
                        else
                            bb2(2*(row-size(st4,1)/4)-1,i) = 1;
                        end
                    elseif bb1(row,i+1) == 1
                        if row <= size(st4,1)/4
                            bb2(2*row,i) = 1;
                        else
                            bb2(2*(row-size(st4,1)/4),i) = 1;
                        end
                    end
                end
            end
            bb3 = [];
            for i = 2:size(inp,1)+1
                bb4 = [];
                row1 = find(bb2(:,i));
                if row1 <= size(st4,1)/4
                    bb4 = [bb4,0];
                else
                    bb4 = [bb4,1];
                end
                bb3 = [bb3,bb4];
            end
            bb5 = bb3(1:end-(k-1));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            error_count = error_count + sum(bb5(1:n)~=input_bits);
            if number > 100 && error_count > 100
                break;
            end
            arr = [DB, number, error_count];
            disp(arr)
        end
        x(k_index,DB) = DB-9;
        y(k_index,DB) = error_count/(200*number);
        plot(x(k_index,:),y(k_index,:),'o-','Color',colors(k_index),'LineWidth',1.5,'DisplayName',sprintf('k =%d',k));
        drawnow;
    end
    legend_entries{end+1} = sprintf('k = %d',k); 
end
legend(legend_entries,'Location','southwest');
hold off;
function[encoded_bits] = convolution_encoder(k,input_bits)
if k==5
    n1 = [1,1,1,0,1];
    n2 = [1,0,0,1,1];
elseif k==6
    n1 = [1,0,1,0,0,1];
    n2 = [1,1,1,0,1,1];
elseif k==7
    n1 = [1,1,1,1,0,0,1];
    n2 = [1,0,1,1,0,1,1];
elseif k==8
    n1 = [1,1,1,1,0,0,0,1];
    n2 = [1,0,1,0,0,1,1,1];
elseif k==9
    n1 = [1,1,1,1,0,1,0,1,1];
    n2 = [1,0,1,1,1,0,0,0,1];
end
f_seed = zeros(1,k-1); % k=5이면 flip-flop은 4개 존재 초기값 각각 0으로
encoded_bits=[]; % 인코딩된 비트들 자리 할당
z = zeros(1,k-1); % k-1만큼 0을 가진 행렬 만들기
cal_bits = [input_bits,z]; % 실제 인코딩하는 비트는 입력 비트 + 0000 (초기화)
cal_bits_len = length(cal_bits);
for i = 1:cal_bits_len
    u = cal_bits(i);
    u1 = [u,f_seed];
    output1 = n1 .* u1;
    output2 = n2 .* u1;
    result1 = mod(sum(output1(:)),2);
    result2 = mod(sum(output2(:)),2);
    encoded_bits = [encoded_bits,result1,result2];
    f_seed = [u,f_seed(1:k-2)];
end
end
function output = mi(a,b1,b2)
if a == [-1,-1]
    output = -b1-b2;
elseif a == [-1,1]
    output = -b1+b2;
elseif a == [1,-1]
    output = b1-b2;
elseif a == [1,1]
    output = b1+b2;
end
end
