function output = Gilbert_Elliott(input,GtoB,BtoG,GE,BE)
output=input;
P_GB = GtoB;  % Good -> Bad 전이 확률
P_BG = BtoG;  % Bad -> Good 전이 확률
p_G = GE; % Good 상태의 오류 확률
p_B = BE;   % Bad 상태의 오류 확률
state_GE = 'G'; % 초기 상태

% 길버트-엘리엇 채널 적용
for i = 1:length(input)
    % 현재 채널 상태에 따라 오류 확률 결정
    if state_GE == 'G'
        error_prob = p_G;
        if rand < P_GB
            state_GE = 'B'; % Bad 상태로 전이
        end
    else
        error_prob = p_B;
        if rand < P_BG
            state_GE = 'G'; % Good 상태로 전이
        end
    end

    % 오류 발생 여부 결정 후 비트 반전
    if rand < error_prob
        output(i) = 1 - input(i); % 오류 삽입 (비트 반전)
    end
end
end