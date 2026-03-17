% aggregate_and_plot.m
clear; clc;

% --- 불러올 결과 파일 나열 ---
files = {'result_01.mat','result_02.mat','result_03.mat','result_04.mat','result_05.mat','result_06.mat','result_07.mat','result_08.mat','result_09.mat','result_10.mat','result_11.mat','result_12.mat','result_13.mat','result_14.mat'}; % 필요한 파일 나열
result = [];
for k=1:numel(files)
    S = load(files{k}, 'result');
    if isfield(S,'result') && ~isempty(S.result)
        result = [result; S.result]; %#ok<AGROW>
    end
end

% --- 중복 제거 ---
[~, iu] = unique(round(result,6), 'rows', 'stable');
result = result(iu,:);

%% === Mesh-style wireframe plot (connect same-x and same-y) ===
figure('Name','Mesh-style wireframe','NumberTitle','off'); hold on;

xlabel('Dimming'); ylabel('Code Ratio'); zlabel('SNR (x @ BER = 10^{-3})');

xlim([0 0.6]);   % Dimming 범위
ylim([0 0.5]);
zlim([10 18]);% Code Ratio 범위

title('Wireframe: connect same-x and same-y with BER-based color');

grid on; box on;
colormap turbo; colorbar;

% ---- 그물망을 위한 그룹핑(같은 x, 같은 y) ----
xr = round(result(:,1), 6);
yr = round(result(:,2), 6);

[ux, ~, ix] = unique(xr, 'stable');   % 같은 x 그룹
[uy, ~, iy] = unique(yr, 'stable');   % 같은 y 그룹

lineW = 1.2;

% === 같은 x (세로선) ===
for k = 1:numel(ux)
    idx = find(ix == k);
    if numel(idx) < 2, continue; end
    [ys, order] = sort(result(idx,2));
    xs = result(idx(order),1);
    zs = result(idx(order),3); % 여기 z값이 BER 또는 SNR
    cs = zs;                   % 색상값: BER이면 BER, SNR이면 SNR

    % surface로 컬러 적용 선 그리기
    surface([xs xs], [ys ys], [zs zs], [cs cs], ...
        'FaceColor','none', 'EdgeColor','interp', 'LineWidth', lineW);
end

% === 같은 y (가로선) ===
for k = 1:numel(uy)
    idx = find(iy == k);
    if numel(idx) < 2, continue; end
    [xs, order] = sort(result(idx,1));
    ys = result(idx(order),2);
    zs = result(idx(order),3);
    cs = zs;

    surface([xs xs], [ys ys], [zs zs], [cs cs], ...
        'FaceColor','none', 'EdgeColor','interp', 'LineWidth', lineW);
end

% --- 영역 윤곽선 ---
t_1 = [0.5,   0.4808];
t_2 = [0.5,   0.2404];
t_3 = [0.375, 0.0962];
t_4 = [0.1826,0.0740];
t_5 = [0.0625,0.0601];
t_6 = [0.1250,0.1202];
t_7 = [0.25,  0.2404];

poly_x = [t_1(1) t_2(1) t_3(1) t_4(1) t_5(1) t_6(1) t_7(1) t_1(1)];
poly_y = [t_1(2) t_2(2) t_3(2) t_4(2) t_5(2) t_6(2) t_7(2) t_1(2)];
poly_z = 10*ones(size(poly_x));
plot3(poly_x, poly_y, poly_z, 'r-', 'LineWidth', 2);

triangles = {
    [t_1; t_2; t_7]
    [t_3; t_2; t_7]
    [t_3; t_4; t_7]
    [t_4; t_6; t_7]
    [t_6; t_5; t_4]
};
colors = lines(5);
for i = 1:numel(triangles)
    tri = triangles{i};
    fill3(tri(:,1), tri(:,2), 1*ones(3,1), ...
        colors(i,:), 'FaceAlpha', 0.12, 'EdgeColor', 'k', 'LineWidth', 1.0);
end

view(45,30);
