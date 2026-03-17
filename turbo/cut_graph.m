%% ===== trim_fig_by_snr.m =====
%  기존 .fig 파일을 불러와서 SNR(dB) 7~12 구간만 잘라 새 .fig로 저장

clc; clear; close all;

%% [1] 사용자 설정
inFig = 'ber_t6.fig';     % 기존 그래프 파일 이름
outFig = 'ber_t6_c.fig'; % 새로 저장할 이름
snr_min = 7;                % 잘라낼 최소 SNR(dB)
snr_max = 11;               % 잘라낼 최대 SNR(dB)

%% [2] 원본 .fig 열기
fig = openfig(inFig, 'invisible');
ax  = findobj(fig, 'Type', 'axes');
if isempty(ax)
    error('축(axes)을 찾지 못했습니다. figure 내부 구조를 확인하세요.');
end

% 첫 번째 축 사용 (그래프 여러 개면 필요시 수정)
ax = ax(1);
lines = findobj(ax, 'Type', 'line');

%% [3] 새 figure 생성
newFig = figure('Color', 'w');
hold on; grid on; box on;
xlabel('SNR (dB)'); ylabel('BER (log scale)');
set(gca, 'YScale', 'log');

%% [4] 각 라인에서 7~12 dB 구간만 잘라서 그리기
for i = 1:length(lines)
    x = lines(i).XData;
    y = lines(i).YData;

    idx = (x >= snr_min) & (x <= snr_max);
    if ~any(idx)
        continue;
    end

    % 0 또는 음수 방지 (로그 스케일용)
    y(y <= 0) = 1e-12;

    % 잘린 부분만 새 그래프에 복사
    plot(x(idx), y(idx), ...
        'Color', lines(i).Color, ...
        'LineStyle', lines(i).LineStyle, ...
        'LineWidth', lines(i).LineWidth, ...
        'Marker', lines(i).Marker, ...
        'DisplayName', lines(i).DisplayName);
end

legend('show','Location','southwest');
title(sprintf('Trimmed BER curve (%.1f~%.1f dB)', snr_min, snr_max));

%% [5] 새 .fig로 저장
savefig(newFig, outFig);
fprintf('새 그래프가 저장되었습니다: %s\n', outFig);

close(fig);
