function [m1, m2, m3, fval] = solve_m123(d_target, R_target, d_A, d_B, d_C)
    % 꼭짓점 데이터
    d1 = d_A(1); R1 = d_A(2);
    d2 = d_B(1); R2 = d_B(2);
    d3 = d_C(1); R3 = d_C(2);

    % 고정된 k 값
    k1 = 200; k2 = 200; k3 = 200;

    % n 값 계산
    n1 = k1 / R1;
    n2 = k2 / R2;
    n3 = k3 / R3;

    % 초기 추정
    x0 = [1/3; 1/3; 1/3];

    % 선형 제약: m1 + m2 + m3 = 1
    Aeq = [1 1 1];
    beq = 1;

    % 범위 제약
    lb = [0; 0; 0];
    ub = [1; 1; 1];

    % 최적화 옵션
    opts = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp');

    % 목적 함수 정의
    objfun = @(m) objective_error(m, d_target, R_target, d1, d2, d3, k1, n1, n2, n3);

    % 최적화 실행
    [m_opt, fval] = fmincon(objfun, x0, [], [], Aeq, beq, lb, ub, [], opts);

    % 결과 반환
    m1 = m_opt(1);
    m2 = m_opt(2);
    m3 = m_opt(3);
end

function cost = objective_error(m, d_target, R_target, d1, d2, d3, k, n1, n2, n3)
    m1 = m(1); m2 = m(2); m3 = m(3);

    denom = n1*m1 + n2*m2 + n3*m3;

    d_hat = (d1*n1*m1 + d2*n2*m2 + d3*n3*m3) / denom;
    R_hat = (k*(m1 + m2 + m3)) / denom;  % k1 = k2 = k3 = k, m1+m2+m3=1 → k/denom

    cost = (d_hat - d_target)^2 + (R_hat - R_target)^2;
end
