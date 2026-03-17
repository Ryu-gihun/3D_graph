% aggregate_and_plot.m
clear; clc;

% --- 불러올 결과 파일 나열 ---
files = 'result_123.mat';
%{'result_01.mat','result_02.mat','result_03.mat','result_04.mat','result_05.mat','result_06.mat','result_07.mat','result_08.mat','result_09.mat','result_10.mat','result_11.mat','result_12.mat','result_13.mat','result_14.mat'}; % 필요한 파일 나열
result = [];
for k = 1%k=1:numel(files)
    S = load(files, 'result');%{k}, 'result');
    if isfield(S,'result') && ~isempty(S.result)
        result = [result; S.result]; %#ok<AGROW>
    end
end

% --- 중복 제거 ---
[~, iu] = unique(round(result,6), 'rows', 'stable');
result = result(iu,:);

% --- 3D 산점도 ---
figure;
scatter3(result(:,1), result(:,2), result(:,3), 80, result(:,3), 'filled'); hold on;

xlabel('Dimming'); ylabel('Code Ratio'); zlabel('SNR (x @ BER = 10^{-3})');
xlim([0 0.6]);   % Dimming 범위
ylim([0 0.5]);
zlim([10 18]);% Code Ratio 범위
title('3D plot: SNR vs dimming/code ratio');
grid on; colorbar;

% --- 보간 Surface ---
x = result(:,1); y = result(:,2); z = result(:,3);
[xq, yq] = meshgrid(linspace(min(x),max(x),100), linspace(min(y),max(y),100));
zq = griddata(x, y, z, xq, yq, 'linear');
F = scatteredInterpolant(x, y, z, 'natural', 'nearest');  % (x,y)→z 보간자
surf(xq, yq, zq, 'EdgeColor','none','FaceAlpha',0.7);
shading interp; colormap turbo; colorbar;

% --- 꼭짓점 좌표 정의 ---
t_1 = [0.5,   0.4808];
t_2 = [0.5,   0.2404];
t_3 = [0.375, 0.0962];
t_4 = [0.1826,0.0740];
t_5 = [0.0625,0.0601];
t_6 = [0.1250,0.1202];
t_7 = [0.25,  0.2404];

% --- 윤곽선 표시 ---
poly_x = [t_1(1) t_2(1) t_3(1) t_4(1) t_5(1) t_6(1) t_7(1) t_1(1)];
poly_y = [t_1(2) t_2(2) t_3(2) t_4(2) t_5(2) t_6(2) t_7(2) t_1(2)];
poly_z = 10*ones(size(poly_x));
plot3(poly_x, poly_y, poly_z, 'r-', 'LineWidth', 2);

% --- 삼각형 패치 표시 ---
% --- 삼각형 패치(바닥, z=10) + 표면 높이에 맞춘 경계선 ---
triangles = {
    [t_1; t_2; t_7]
    [t_3; t_2; t_7]
    [t_3; t_4; t_7]
    [t_4; t_6; t_7]
    [t_6; t_5; t_4]
};
colors = lines(5);
z_floor = 10;  % 바닥 표시 높이(=zlim 하한)

%for i = 1:numel(triangles)
%    tri = triangles{i};

    % 2-1) 바닥 면(기존처럼)
    %fill3(tri(:,1), tri(:,2), z_floor*ones(3,1), ...
        %colors(i,:), 'FaceAlpha', 0.2, 'EdgeColor', 'k', 'LineWidth', 1.2);

    % 2-2) 표면 위 경계선(각 꼭짓점의 z를 보간해 연결)
 %   vz = F(tri(:,1), tri(:,2));   % [z1 z2 z3]
  %  plot3([tri(:,1); tri(1,1)], ...
   %       [tri(:,2); tri(1,2)], ...
    %      [vz; vz(1)], ...
     %     'r-', 'LineWidth', 2.2);

    % (옵션) 표면 위 얇은 반투명 패치로 범위도 채우고 싶으면 주석 해제
    % fill3(tri(:,1), tri(:,2), vz, 'r', 'FaceAlpha', 0.08, ...
    %       'EdgeColor', 'none');
%end
