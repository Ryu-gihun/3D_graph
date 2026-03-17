function [m1, m2, m3] = solve_barycentric(d, R, d_A, d_B, d_C)
    % d, R: 목표 지점의 x, y 좌표
    % d_A, d_B, d_C: 각 꼭짓점의 [x, y] (예: SNR, BER)

    % 꼭짓점 좌표 분리
    A = d_A(:);
    B = d_B(:);
    C = d_C(:);
    P = [d; R];  % target point

    % 벡터 계산
    v0 = B - A;
    v1 = C - A;
    v2 = P - A;

    % 내적 계산
    d00 = dot(v0, v0);
    d01 = dot(v0, v1);
    d11 = dot(v1, v1);
    d20 = dot(v2, v0);
    d21 = dot(v2, v1);

    denom = d00 * d11 - d01 * d01;

    % 바리센트릭 좌표 계산
    v = (d11 * d20 - d01 * d21) / denom;
    w = (d00 * d21 - d01 * d20) / denom;
    u = 1.0 - v - w;

    % 결과 반환
    m1 = u;  % A에 대한 가중치
    m2 = v;  % B에 대한 가중치
    m3 = w;  % C에 대한 가중치
end
