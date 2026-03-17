function [figA, figB, figC] = loadGraphsFromTriangle(d_A, d_B, d_C)
    % 기준점 리스트
    t_list = {
        [0.5, 0.4808];   % t_1
        [0.5, 0.2404];   % t_2
        [0.375, 0.0962]; % t_3
        [0.1826, 0.074]; % t_4
        [0.0625, 0.0601];% t_5
        [0.125, 0.1202]; % t_6
        [0.25, 0.2404];  % t_7
    };

    % 각 점에 대해 대응되는 인덱스 찾기
    idx_A = findPointIndex(d_A, t_list);
    idx_B = findPointIndex(d_B, t_list);
    idx_C = findPointIndex(d_C, t_list);

    % 그래프 파일 열기
    figA = extractDataFromFig(sprintf('ber_t%d.fig', idx_A));
    figB = extractDataFromFig(sprintf('ber_t%d.fig', idx_B));
    figC = extractDataFromFig(sprintf('ber_t%d.fig', idx_C));
end

function idx = findPointIndex(point, t_list)
    tol = 1e-4; % 오차 허용
    for i = 1:length(t_list)
        if norm(point - t_list{i}) < tol
            idx = i;
            return;
        end
    end
    error('해당하는 기준점을 찾을 수 없습니다.');
end

function dataMatrix = extractDataFromFig(figFile)
    % .fig 파일에서 그래프 데이터를 추출
    fig = openfig(figFile, 'invisible');
    ax = findall(fig, 'Type', 'axes');
    lineObj = findall(ax, 'Type', 'line');
    
    % 첫 번째 선형 그래프 데이터 가져오기
    x = get(lineObj(1), 'XData');
    y = get(lineObj(1), 'YData');
    
    dataMatrix = [x(:), y(:)];
end
