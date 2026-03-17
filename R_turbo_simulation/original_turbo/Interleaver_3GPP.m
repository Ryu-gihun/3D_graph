function result = Interleaver_3GPP(K)
    
    %%% 행 개수(R) 정의 %%%
    if K>=40 && K<=159
        R = 5;
    elseif K>=160 && K<=200 || K>=481 && K<=530
        R = 10;
    else
        R = 20;
    end
    
    
    %%% p-v table 정의 %%%
    prime_numbers = primes(257);  % 257 이하의 모든 소수를 반환
    p_array = prime_numbers(prime_numbers >= 7);  % 7 이상만 필터링
    v_array = [3 2 2 3 2 5 2 3 2 6 3, 5 2 2 2 2 7 5 3 2 3 5, 2 5 2 6 3 3 2 3 2 2 6, 5 2 5 2 2 2 19 5 2 3 2, 3 2 6 3 7 7 6 3];
    p_v_table = [p_array; v_array];
    
    
    %%% p, v값과 열 개수(C) 정의 %%%
    if K>=481 && K<=530
        p = 53;
        C = p;
        v = 2;
    else
        value = K/R - 1;
        p = p_array(find(p_array >= value, 1, 'first'));
        v = v_array(find(p_array >= value, 1, 'first'));
    
        if K <= R*(p-1)
            C = p-1;
        elseif K<=R*p
            if K>R*(p-1)
                C = p;
            end
        else
            C = p+1;
        end
    end
    
    
    %%% s(j) 결정 %%%
    s = ones(1,p-1);
    for j = 2:p-1
        s(j) = mod(v * s(j-1), p);
    end
    
    
    %%% q 결정 %%%
    q = ones(1,R);
    count = 0;
    for i = 2:R
        q(i) = p_array(i-1+count);
    
        if mod(p-1, q(i)) == 0
            count = count + 1;
            q(i) = p_array(i-1+count);
        end
    end
    
    
    %%% r 결정 %%%
    temp = zeros(1,R);
    
    if R == 5
        T = 5:-1:1;
        temp = fliplr(q);
        r = temp;
    elseif R == 10
        T = 10:-1:1;
        temp = fliplr(q);
        r = temp;
    else
        if ((K>=2281 && K<=2480) || (K>=3161 && K<=3210))
            T = [20 10 15 5 1 3 6 8 13 19 17 14 18 16 4 2 7 12 9 11];
            for i = 1:R
                temp(i) = q(T(i));
            end
        else
            T = [20 10 15 5 1 3 6 8 13 19 11 9 14 18 4 2 17 7 16 12];
            for i = 1:R
                temp(i) = q(T(i));
            end
        end
        r = temp;
    end
    
    
    %%% U(i,j) 결정 %%%
    U = zeros(i,j);
    
    for i = 1:R
        for j = 1:p-1
            U(i,j) = s(mod(j*r(i), p-1) + 1);
            if C == p-1
                U(i,j) = s(mod(j*r(i), p-1) + 1) - 1;
            end
        end
    
        if C == p
            U(i,p) = 0;
        elseif C == p+1
            U(i,p) = 0;
            U(i,p+1) = p;
        end
    end
    
    
    %%%%%%%%%%%%%% 최종 Matrix 출력 %%%%%%%%%%%%%%
    
    
    %%% intra-row permutation %%%
    if R*C == K
        matrix = reshape(1:K, C, R)';
    else
        matrix = reshape([1:K, zeros(1,R*C-K)], C, R)';
    end
    intra_matrix = zeros(R,C);
    for i = 1:R
        for j = 1:C 
            intra_matrix(i,j) = matrix(i,U(i,j)+1);
        end
    end
    %%%
    
    
    %%% inter-row permutation %%%
    inter_matrix = zeros(R,C);
    
    for i = 1:R
        inter_matrix(i,:) = intra_matrix(T(i),:);
    end
    %%%
    
    
    %%% 0을 뺀 최종 결과 %%%
    result = nonzeros(inter_matrix)';


end