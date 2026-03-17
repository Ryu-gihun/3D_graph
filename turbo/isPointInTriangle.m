function isInside = isPointInTriangle(P, A, B, C)
    % 입력:
    % P: 검사할 점 (1x2 벡터)
    % A, B, C: 삼각형의 세 꼭짓점 (각각 1x2 벡터)
    epsilon = 1e-10;
    % 벡터 계산
    v0 = C - A;
    v1 = B - A;
    v2 = P - A;

    % 내적 계산
    dot00 = dot(v0, v0);
    dot01 = dot(v0, v1);
    dot02 = dot(v0, v2);
    dot11 = dot(v1, v1);
    dot12 = dot(v1, v2);

    % Barycentric 좌표 계산
    invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
    u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    % 삼각형 내부에 있는지 확인
    isInside = (u >= -epsilon) && (v >= -epsilon) && (u + v <= 1 + epsilon);
end
