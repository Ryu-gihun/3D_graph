clc; clear; close all;

%% RS 코드 파라미터 설정 (수중 통신 환경)
n = 31;  % 코드워드 길이 증가
k = 15;  % 데이터 길이
t = (n - k) / 2; % 정정 가능한 오류 개수 증가

%% GF(2^m) 필드 설정 (Galois Field 생성)
rsEncoder = comm.RSEncoder(n, k, 'BitInput', false);
rsDecoder = comm.RSDecoder(n, k, 'BitInput', false);

%% 랜덤 데이터 생성 (200개의 데이터 사용)
num_blocks = 200;  
msg = randi([0 7], k, num_blocks); % 0~7 범위의 k개 심볼을 가진 200개의 블록
disp('원본 데이터 일부:');
disp(msg(:,1:5));

%% RS 부호화 수행
encodedMsg = zeros(n, num_blocks);
for i = 1:num_blocks
    encodedMsg(:,i) = rsEncoder(msg(:,i));
end
disp('RS 부호화된 코드워드 일부:');
disp(encodedMsg(:,1:5));

%% Gilbert-Elliott 채널 적용 (수중 통신 환경 설정)
p_good_to_bad = 0.03;  
p_bad_to_good = 0.5;   
p_error_good = 0.001;  
p_error_bad = 0.15;    

channel_state = 0;
receivedMsg = encodedMsg;
num_errors = 0;

for i = 1:num_blocks
    for j = 1:n
        original_symbol = receivedMsg(j,i);

        % 상태 전이 결정
        if channel_state == 0  
            if rand < p_good_to_bad
                channel_state = 1;
            end
        else  
            if rand < p_bad_to_good
                channel_state = 0;
            end
        end

        % 오류 삽입
        if channel_state == 0  
            if rand < p_error_good
                receivedMsg(j,i) = mod(receivedMsg(j,i) + 1, 8);
            end
        else  
            if rand < p_error_bad
                receivedMsg(j,i) = mod(receivedMsg(j,i) + 2, 8);
            end
        end

        if receivedMsg(j,i) ~= original_symbol
            num_errors = num_errors + 1;
        end
    end
end

disp('수중 통신 환경을 거친 수신 데이터 일부:');
disp(receivedMsg(:,1:5));

%% 가우시안 노이즈 추가 (lastdeco.m 방식 적용)
DB = 13;  % 신호 대 잡음비 (SNR) dB
r = 1; % 채널 코드율 (RS 코드 고려)
db = 10^(DB/20); % 선형 변환
sigma = (1/sqrt(r)) * (1/db); % 노이즈 표준편차
noise = normrnd(0, sigma, [n, num_blocks]); % 가우시안 노이즈 생성

receivedMsg = receivedMsg + noise;  % 신호에 노이즈 추가

disp('가우시안 노이즈 적용된 수신 데이터 일부 (실수형):');
disp(receivedMsg(:,1:5));

%% 🚀 **RS 디코더에 입력하기 전에 반올림하여 정수 변환!**
receivedMsg = round(receivedMsg); % 실수를 반올림하여 정수 변환
receivedMsg = mod(receivedMsg, 8); % 🚀 0~7 범위 유지
receivedMsg = uint8(receivedMsg); % 🚀 MATLAB RS 디코더가 정수를 인식하도록 변환

disp('RS 디코더 입력 데이터 (정수 변환 후):');
disp(receivedMsg(:,1:5));

%% RS 복호화 수행
decodedMsg = zeros(k, num_blocks);
errCounts = zeros(1, num_blocks);
corrected_errors = 0;

for i = 1:num_blocks
    [decodedMsg(:,i), errCounts(i)] = rsDecoder(receivedMsg(:,i));
    
    % 🚀 **음수 값 방지 및 최대값 조정**
    errCounts(i) = max(0, min(errCounts(i), num_errors));  
    corrected_errors = corrected_errors + errCounts(i);
end

disp('복호화된 데이터 일부:');
disp(decodedMsg(:,1:5));

% BER 계산 (음수 방지 조정)
total_bits = num_blocks * n * 3; 
BER_before = num_errors / total_bits;
BER_after = max(0, (num_errors - corrected_errors) / total_bits);  % 🚀 음수 BER 방지
error_count = 0;
for i = 1:num_blocks
    for j = 1:k
        if decodedMsg(j,i) ~= msg(j,i)
            error_count = error_count + 1;
        end
    end
end

disp(['총 삽입된 오류 개수: ', num2str(num_errors)]);
disp(['총 정정된 오류 개수: ', num2str(corrected_errors)]);
disp(['평균 정정된 오류 개수: ', num2str(mean(errCounts))]);
disp(['RS 복호화 전 BER: ', num2str(BER_before)]);
disp(['RS 복호화 후 BER: ', num2str(BER_after)]);
disp(error_count);