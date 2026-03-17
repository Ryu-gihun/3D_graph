o = [1 1 1 0 1 0 1 0 0 1 0 1 1 1 0 1 0 1 1 1];
n = size(o, 2);
e = 0;
k = 5;
i = zeros(1, n / 2);
ip = zeros(1, n / 2 - k + 1);
I = size(i, 2);
map = zeros(2^(I - 1), I); % map 배열 크기 조정
error = zeros(2^(I - 1), 1);

% decide status length k
if k == 5
    n1 = [1, 1, 1, 0, 1];
    n2 = [1, 0, 0, 1, 1];
elseif k == 6
    n1 = [1, 0, 1, 0, 0, 1];
    n2 = [1, 1, 1, 0, 1, 1];
elseif k == 7
    n1 = [1, 1, 1, 1, 0, 0, 1];
    n2 = [1, 0, 1, 1, 0, 1, 1];
elseif k == 8
    n1 = [1, 1, 1, 1, 1, 0, 0, 1];
    n2 = [1, 0, 1, 0, 0, 1, 1, 1];
elseif k == 9
    n1 = [1, 1, 1, 1, 0, 1, 0, 1, 1];
    n2 = [1, 0, 1, 1, 1, 0, 0, 0, 1];
end

state = zeros(1, k);
result = zeros(1, 2);
a = 0;

% Map 배열 생성
for n = 1:I-1
    state = map(2^(n-1) + a, :);
    state = circshift(state, 1);
    state(1, 1) = 1;
    if 2^(n) + 2 * a <= size(map, 1)
        map(2^(n) + 2 * a, :) = state;
    end
    state(1, 1) = 0;
    if 2^(n) + 2 * a + 1 <= size(map, 1)
        map(2^(n) + 2 * a + 1, :) = state;
    end
    a = a + 1;
    if a > 2^(n-1)
        a = 0;
    end
end

% Error 계산
for z = 1:I-1
    f = o(1, 2 * z - 1);
    s = o(1, 2 * z);
    x = 0;
    y = 0;
    for w = 2^z:min(2^z + 2^z - 1, size(map, 1)) % 경계 초과 방지
        for b = 1:k
            if n1(1, b) == 1
                x = x + map(w, b);
            end
            if n2(1, b) == 1
                y = y + map(w, b);
            end
        end
        result1 = mod(x, 2);
        result2 = mod(y, 2);
        if result1 ~= f
            odd = mod(w, 2);
            v = w;
            if odd == 1
                v = w - 1;
            end
            if v / 2 <= size(error, 1)
                error(w, 1) = error(v / 2, 1) + 1;
            end
        end
    end
end

disp(map);