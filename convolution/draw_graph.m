% ===== 결과 시각화 =====
%--- 3D 점 그래프 (xyz_points는 [x, y, z] 좌표) ---
figure;

% ===== 점 산점도 + 컬러바 =====
scatter3(result(:,1), result(:,2), result(:,3), 40, result(:,3), 'filled');
hold on;
xlabel('Dimming'); ylabel('Code Ratio'); zlabel('SNR (x @ BER = 10^{-3})');
title('3D plot: SNR vs dimming/code ratio');
grid on;
colorbar;

% ===== 보간 surface 추가 =====
% 1. X, Y, Z 데이터 추출
x = result(:,1);
y = result(:,2);
z = result(:,3);

% 2. 보간용 격자 생성
[xq, yq] = meshgrid(linspace(min(x), max(x), 100), linspace(min(y), max(y), 100));

% 3. Z값 보간 (선형 또는 cubic 가능)
zq = griddata(x, y, z, xq, yq, 'linear');  % 또는 'cubic'

% 4. 보간된 surface 시각화
surf(xq, yq, zq, 'EdgeColor', 'none', 'FaceAlpha', 0.7);  % 면만, 투명도 적용
shading interp;  % 부드러운 색 보간

% ===== 기존 polygon 윤곽선 유지 =====
poly_x = [t_1(1) t_2(1) t_3(1) t_4(1) t_5(1) t_6(1) t_7(1) t_1(1)];
poly_y = [t_1(2) t_2(2) t_3(2) t_4(2) t_5(2) t_6(2) t_7(2) t_1(2)];
poly_z = zeros(size(poly_x)); % z = 0 평면

plot3(poly_x, poly_y, poly_z, 'r-', 'LineWidth', 2);  % 윤곽선 그대로 유지

plot3(poly_x, poly_y, poly_z, 'r-', 'LineWidth', 2);  % 윤곽선 그대로 유지

% === 삼각형 패치 표시 ===
triangles = {
    [t_1; t_2; t_7],
    [t_3; t_2; t_7],
    [t_3; t_4; t_7],
    [t_4; t_6; t_7],
    [t_6; t_5; t_4]
};
colors = lines(5);  % 색상 팔레트

for i = 1:length(triangles)
    tri = triangles{i};
    fill3(tri(:,1), tri(:,2), zeros(3,1), colors(i,:), 'FaceAlpha', 0.2, 'EdgeColor', 'k', 'LineWidth', 1.2);
end


legend('SNR Points', 'Polygon Boundary', 'Interpolated Surface');
view(45, 30);  % 보기 각도
colormap turbo;      % 색상
colorbar;
grid on;
