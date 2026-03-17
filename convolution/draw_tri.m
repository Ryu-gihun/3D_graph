% plot_base_triangles.m
clear; clc; close all;

% ----- 표시 설정 -----
z_floor  = 10;      % 밑면 높이 (원하는 높이로)
top_down = true;    % true: 2D 평면 보기, false: 3D 사선 보기

% ----- 꼭짓점 정의 [Dimming, CodeRate] -----
t_1 = [0.5,   0.4808];
t_2 = [0.5,   0.2404];
t_3 = [0.375, 0.0962];
t_4 = [0.1826,0.0740];
t_5 = [0.0625,0.0601];
t_6 = [0.1250,0.1202];
t_7 = [0.25,  0.2404];

V = [t_1; t_2; t_3; t_4; t_5; t_6; t_7];

% ----- 삼각형 목록 (case 1~5) -----
triangles = {
    [t_1; t_2; t_7]
    [t_3; t_2; t_7]
    [t_3; t_4; t_7]
    [t_4; t_6; t_7]
    [t_6; t_5; t_4]
};

% ----- 그림/축 -----
figure('Color','w'); hold on; box on; grid on;
xlabel('Dimming'); ylabel('Code Rate'); zlabel('z');
xlim([0 0.6]); ylim([0 0.5]);
if top_down
    % 2D처럼 보이도록
    zlim([z_floor z_floor+1e-6]);
    view(2); % top-down
else
    zlim([z_floor z_floor+0.1]);
    view(45,25);
end

% ----- 외곽 폴리곤 (굵은 빨간선) -----
outer = [t_1; t_2; t_3; t_4; t_5; t_6; t_7; t_1];
plot3(outer(:,1), outer(:,2), z_floor*ones(size(outer,1),1), ...
      'r-', 'LineWidth', 2.2);

% ----- 내부 삼각형 (검은선, 채움 없음) -----
for i = 1:numel(triangles)
    T = triangles{i};
    plot3([T(:,1); T(1,1)], [T(:,2); T(1,2)], ...
          z_floor*ones(4,1), 'k-', 'LineWidth', 1.5);
end

% === 라벨을 바깥쪽으로 자동 오프셋 + 리더 라인 ===
xl = xlim; yl = ylim;
xr = diff(xl); yr = diff(yl);

C  = mean(V,1);         % 폴리곤 중심
k  = 0.02;              % 오프셋 크기 (축 스팬의 5%)
pad = 0.01;             % 축 경계로부터 여유(1%)

for i = 1:size(V,1)
    v = V(i,:);                     % [x,y]
    d = v - C; if norm(d)==0, d=[1 0]; end
    d = d / norm(d);                % 바깥쪽 단위 방향

    % 바깥쪽으로 밀어낸 라벨 위치
    x_off = v(1) + k*xr*d(1);
    y_off = v(2) + k*yr*d(2);

    % 축 범위 밖으로 튀지 않도록 클램프
    x_off = min(max(x_off, xl(1)+pad*xr), xl(2)-pad*xr);
    y_off = min(max(y_off, yl(1)+pad*yr), yl(2)-pad*yr);

    % 리더 라인(점 → 라벨)
    plot3([v(1) x_off], [v(2) y_off], [z_floor z_floor], ...
          '--', 'Color', [0.2 0.2 0.2], 'LineWidth', 0.5);

    % 라벨 문자열: t3만 이름 없이 좌표만
    if i == 3
        lbl = sprintf('(%.3f, %.3f)', v(1), v(2));
    else
        lbl = sprintf('t_%d (%.3f, %.3f)', i, v(1), v(2));
    end

    % 방향에 따라 정렬 바꿔 겹침 최소화
    ha = ternary(d(1)>=0,'left','right');
    va = ternary(d(2)>=0,'bottom','top');

    text(x_off, y_off, z_floor, lbl, ...
        'HorizontalAlignment', ha, 'VerticalAlignment', va, ...
        'FontSize', 12, 'BackgroundColor', 'none');
end

% --- 작은 유틸 (스크립트 맨 아래에 둘 수 있음) ---
function out = ternary(cond,a,b), if cond, out=a; else, out=b; end
end

