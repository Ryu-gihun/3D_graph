% 원본 figure 파일 열기 (숨김 모드)
fig = openfig('ber_t3.fig', 'invisible');
axesHandles = findall(fig, 'type', 'axes');  % 모든 axes 검색

% 새 figure 생성
figure;
hold on;
title('Extracted Red Line from ber_t5.fig');
xlabel('SNR (dB)');
ylabel('BER');
set(gca, 'YScale', 'log');
grid on;

% 모든 axes에 대해 빨간색 선 추출
for ax = axesHandles'
    lineObjs = findall(ax, 'type', 'line');

    for i = 1:length(lineObjs)
        colorVal = get(lineObjs(i), 'Color');

        if isequal(colorVal, [1 0 0])  % RGB 빨간색 확인
            x = get(lineObjs(i), 'XData');
            y = get(lineObjs(i), 'YData');
            plot(x, y, 'r', 'LineWidth', 2);  % 새 figure에 그리기
        end
    end
end

hold off;
