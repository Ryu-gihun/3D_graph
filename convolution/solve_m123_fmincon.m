function [m1, m2, m3, exitflag, fval] = solve_m123_fmincon(x, y, A, B, C)
    % A, B, C: 삼각형 꼭짓점 (각각 [d, R] 형태의 2D 좌표)
    % (x, y): 타겟 위치
    
    % 꼭짓점 좌표 추출
    x1 = A(1); y1 = A(2);
    x2 = B(1); y2 = B(2);
    x3 = C(1); y3 = C(2);
    
    % 행렬 T: 꼭짓점들을 열벡터로 나열 (homogeneous coordinates)
    T = [x1, x2, x3;
         y1, y2, y3;
         1 ,  1,  1];
    
    % P: 타겟 좌표 (homogeneous)
    P = [x; y; 1];
    
    % 선형 시스템 풀기
    weights = T \ P;
    m1 = weights(1);
    m2 = weights(2);
    m3 = weights(3);
    
    % 유효성 검사
    if all([m1, m2, m3] >= -1e-6) && abs(m1 + m2 + m3 - 1) < 1e-6
        exitflag = 1;
        fval = 0;
    else
        exitflag = -1;
        fval = NaN;
        m1 = NaN; m2 = NaN; m3 = NaN;
    end
end
