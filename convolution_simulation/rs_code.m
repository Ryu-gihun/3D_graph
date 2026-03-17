clc; clear; close all;
%% RS 코드 파라미터 설정 (GF(2) 기반 심볼 연산)
n = 31;  % 코드워드 길이 (부호화 후 길이)
k = 15;  % 원래 데이터 길이 (부호화 전 길이)
t = (n - k) / 2; % 정정 가능한 오류 개수
%% GF(2)에서 동작하도록 설정 (BitInput=false → 심볼 단위 연산)
rsEncoder = comm.RSEncoder(n, k, 'BitInput', false);  % 🚀 BitInput=false
rsDecoder = comm.RSDecoder(n, k, 'BitInput', false);  % 🚀 BitInput=false

num_blocks = 2000;

figure;
h = plot(NaN, NaN, '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Burst 오류 길이');
ylabel('BER (비트 오류율)');
title('Burst 오류 길이에 따른 실시간 BER 변화');
grid on;
hold on;

x_data = [];  % X축 (오류 길이) 데이터 저장
y_data = [];  % Y축 (BER) 데이터 저장

for error_length = 20:-1:6

    run_count = 0;
    error_stack = 0;
    while(1)
        %% 랜덤 데이터 생성 (0과 1로만 구성된 원본 데이터)

        msg = randi([0 7], k, num_blocks);  % 🚀 **0과 1로만 구성된 데이터**

        %% RS 부호화 수행 (심볼 단위 변환)
        encodedMsg = zeros(n, num_blocks);
        for i = 1:num_blocks
            encodedMsg(:,i) = rsEncoder(msg(:,i));  % 🚀 심볼 단위 입력
        end

        %%가우시안 노이즈
        DB = 20;  % 신호 대 잡음비 (SNR) dB
        r = 15/31; % 채널 코드율 (RS 코드 고려)
        db = 10^(DB/20); % 선형 변환
        sigma = (1/sqrt(r)) * (1/db); % 노이즈 표준편차
        noise = normrnd(0, sigma, [n, num_blocks]); % 가우시안 노이즈 생성


        %% Burst 오류 (수중 통신 환경 설정)
        channel_state = 0;
        receivedMsg = encodedMsg;
        num_errors = 0;
        error_num = 10;
        receivedMsg = apply_burst_errors(receivedMsg, error_num, error_length);


        %% 🚀 **RS 디코더에 입력하기 전에 반올림하여 정수 변환!**
        receivedMsg = round(receivedMsg);  % 실수를 반올림하여 정수 변환
        receivedMsg = mod(receivedMsg, 2);  % 🚀 **GF(2) 범위 유지 (0 또는 1)**
        receivedMsg = uint8(receivedMsg);  % 🚀 **MATLAB RS 디코더가 정수를 인식하도록 변환**

        %% RS 복호화 수행
        % RS 복호화 수행
        decodedMsg = zeros(k, num_blocks);  % 디코딩된 메시지 저장 공간
        errCounts = zeros(1, num_blocks);  % 정정된 오류 개수 저장
        corrected_errors = 0;  % 총 정정된 오류 개수

        for i = 1:num_blocks
            [decodedMsg(:,i), errCounts(i)] = rsDecoder(receivedMsg(:,i));  % RS 디코딩 수행

            % 오류 정정 개수 조정
            errCounts(i) = max(0, min(errCounts(i), num_errors));
            corrected_errors = corrected_errors + errCounts(i);
        end

        for i = 1:num_blocks
            for j = 1:k
                if decodedMsg(j,i) ~= msg(j,i)
                    error_stack = error_stack + 1;
                end
            end
        end
        % BER 계산 (음수 방지 조정)
        total_bits = num_blocks * n;  % 🚀 **GF(2)에서는 심볼당 1비트**
        BER = error_stack/(total_bits*run_count);
        disp([error_length, error_stack, run_count]);
        run_count = run_count + 1;

        if run_count > 100 && error_stack >= 100
            break;
        end
    end
    %% 실시간 그래프 업데이트
    x_data = [x_data, error_length ];
    y_data = [y_data, BER];

    set(h, 'XData', x_data, 'YData', y_data);
    drawnow;
end

set(gca, 'XDir', 'reverse'); % X축 방향 반전






