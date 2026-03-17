% aggregate_and_plot.m
clear; clc;

% --- 불러올 결과 파일 나열 ---
files = {'result_01.mat'};%,'result_02.mat','result_03.mat','result_04.mat','result_05.mat','result_06.mat','result_07.mat','result_08.mat','result_09.mat','result_10.mat','result_11.mat','result_12.mat','result_13.mat','result_14.mat'};
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

xlabel('Dimming'); ylabel('Code Rate'); zlabel('SNR (x @ BER = 10^{-3})');
xlim([0 0.6]);                     % x
ylim([0 0.5]);                     % y
zlim([10 18]);                     % z
title('Wireframe: connect same-x and same-y with value-based color');
grid on; box on; view(45,30);
colormap turbo; colorbar; caxis([10 18]);  % 색상 축을 z 범위에 맞춤(선 색 일관성)

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
    zs = result(idx(order),3);
    cs = zs;
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


% -------- 삼각형 범위(케이스 1~5)와 외곽 폴리곤을 바닥 평면에 표시 --------
% ==== 그래프 위에 폴리곤/삼각형 범위 덮어그리기 ====

% 1) (x,y)->z 보간자 (경계 밖은 nearest로 외삽)
F_nat  = scatteredInterpolant(result(:,1), result(:,2), result(:,3), 'natural','nearest');
F_near = scatteredInterpolant(result(:,1), result(:,2), result(:,3), 'nearest','nearest');

% 2) 꼭짓점 (이미 위에 있다면 생략 가능)
t_1 = [0.5, 0.4996];%[d,r]
t_2 = [0.5, 0.3331];
t_3 = [0.5, 0.2498];
t_4 = [0.25, 0.2498];
t_5 = [0.25, 0.1665];
t_6 = [0.25, 0.1249];
t_7 = [0.125, 0.1249];
t_8 = [0.375, 0.0999];
t_9 = [0.1827, 0.0769];
t_10 = [0.0625, 0.0625];

V = [t_1; t_2; t_3; t_4; t_5; t_6; t_7; t_8; t_9; t_10];

% 3) 삼각형 목록 (질문 속 case 1~5)
tris = {
    [t_1; t_2; t_4]
    [t_2; t_3; t_4]
    [t_3; t_4; t_8]
    [t_4; t_5; t_8]
    [t_4; t_5; t_7]
    [t_5; t_6; t_7]
    [t_5; t_6; t_8]
    [t_6; t_7; t_9]
    [t_6; t_9; t_8]
    [t_7; t_9; t_10]
    };

% 4) 외곽 경계 인덱스(굵은 빨간선)
outer_idx = [1 3 8 10 1];

% 5) 한 변을 표면 높이에 맞춰 그리는 유틸(함수 없이 반복문으로 작성)
nsamp = 200;           % 변을 따라 샘플 개수(조절 가능)
edge_eps = 0;          % 필요하면 3D 표면 위로 띄우기: 예) 1e-6

% 5-1) 외곽선
for k = 1:numel(outer_idx)-1
    p = V(outer_idx(k),:);
    q = V(outer_idx(k+1),:);
    xs = linspace(p(1), q(1), nsamp);
    ys = linspace(p(2), q(2), nsamp);
    zs = F_nat(xs, ys);
    bad = isnan(zs);
    if any(bad), zs(bad) = F_near(xs(bad), ys(bad)); end
    plot3(xs, ys, zs+edge_eps, 'r-', 'LineWidth', 2.2);
end

% 5-2) 내부 삼각형 경계(얇은 회색선)
%     (중복 edge 제거)
%     V의 행과 일치시키기 위해 좌표로 인덱스 매칭
toIdx = @(p) find(all(abs(V - p) < 1e-12, 2), 1);
E = [];
for i = 1:numel(tris)
    T = tris{i};
    idx3 = [toIdx(T(1,:)), toIdx(T(2,:)), toIdx(T(3,:))];
    E = [E; sort(idx3([1 2])); sort(idx3([2 3])); sort(idx3([3 1]))]; %#ok<AGROW>
end
E = unique(E, 'rows');

% 외곽 edge 제외
outer_pairs = sort([outer_idx(1:end-1)', outer_idx(2:end)'],2);
is_outer = ismember(E, outer_pairs, 'rows');
E_in = E(~is_outer, :);

for k = 1:size(E_in,1)
    p = V(E_in(k,1),:);
    q = V(E_in(k,2),:);
    xs = linspace(p(1), q(1), nsamp);
    ys = linspace(p(2), q(2), nsamp);
    zs = F_nat(xs, ys);
    bad = isnan(zs);
    if any(bad), zs(bad) = F_near(xs(bad), ys(bad)); end
    plot3(xs, ys, zs+edge_eps, '-', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.8);
end

% (옵션) 꼭짓점 강조
vz = F_nat(V(:,1), V(:,2)); bad = isnan(vz);
if any(bad), vz(bad) = F_near(V(bad,1), V(bad,2)); end
plot3(V(:,1), V(:,2), vz+edge_eps, 'r.', 'MarkerSize', 25);

%% === 바닥(2D)에도 삼각형 범위 표시 + 꼭짓점 수직 연결선 ===
zl = zlim;
z_floor = zl(1);              % 현재 z축 하한(예: 10)에 바닥 투영
tri_cols = lines(numel(tris));

% 1) 바닥에 삼각형들 2D 투영 (채움 + 테두리)
%for i = 1:numel(tris)
    %T = tris{i};
    %fill3(T(:,1), T(:,2), z_floor*ones(3,1), ...
%          'w', 'FaceAlpha', 0, ...
%          'EdgeColor','k', 'LineWidth', 1.2);
%end

% 2) 바닥 외곽 폴리곤(전체 영역 경계)
%poly = [V; V(1,:)];
%plot3(poly(:,1), poly(:,2), z_floor*ones(size(poly,1),1), ...
%      'r-', 'LineWidth', 2);

% === 꼭짓점 바닥↔표면 연결선 + 라벨(수정 버전) ===
% === 바닥 라벨: 바깥쪽 오프셋 + 리더 라인 (기존 text 루프 교체) ===
xl = xlim; yl = ylim;
xr = diff(xl); yr = diff(yl);

C  = mean(V,1);   % 폴리곤 중심
k  = 0.03;        % 오프셋 크기(축 범위의 비율) ↑/↓로 조절
pad = 0.01;       % 축 경계 여유

for i = 1:size(V,1)
    x = V(i,1);  y = V(i,2);

    % 바깥쪽 방향(중심→꼭짓점)
    d = [x y] - C;
    if norm(d)==0, d = [1 0]; end
    d = d / norm(d);

    % 오프셋된 라벨 위치
    x_off = x + k * xr * d(1);
    y_off = y + k * yr * d(2);

    % 축 범위 밖으로 튀지 않도록 클램프
    x_off = min(max(x_off, xl(1)+pad*xr), xl(2)-pad*xr);
    y_off = min(max(y_off, yl(1)+pad*yr), yl(2)-pad*yr);

    % 리더 라인(점 → 라벨)
    plot3([x x_off], [y y_off], [z_floor z_floor], ...
          '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.8);

    % 라벨 문자열: t3만 이름 없이 좌표만
    %if i == 3
    %    lbl = sprintf('(%.3f, %.3f)', x, y);
    %else
    %    lbl = sprintf('t_%d (%.3f, %.3f)', i, x, y);
    %end

    % 방향에 따라 정렬(겹침 최소화)
    if d(1) >= 0, ha = 'left';  else, ha = 'right'; end
    if d(2) >= 0, va = 'bottom'; else, va = 'top';   end

    % 투명 배경 라벨
    
    %text(x_off, y_off, z_floor, lbl, ...
    %    'HorizontalAlignment', ha, 'VerticalAlignment', va, ...
    %    'FontSize', 9, 'BackgroundColor', 'w', 'Margin', 1);
end





