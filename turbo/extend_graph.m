function extended_graph = extend_graph(graph, left_extend_dB, right_extend_dB)

    x = graph(:,1); y = graph(:,2);

    % 로그 스케일로 변환 (log10)
    logy = log10(y);

    % --- 왼쪽 기울기 계산 및 확장 ---
    dx1 = x(2) - x(1);
    dy1 = logy(2) - logy(1);
    slope_left = dy1 / dx1;

    new_x_left = (x(1) - left_extend_dB) : dx1 : (x(1) - dx1);
    new_logy_left = logy(1) + slope_left * (new_x_left - x(1));
    new_y_left = 10.^new_logy_left;  % 다시 선형 복원

    % --- 오른쪽 기울기 계산 및 확장 ---
    dx2 = x(end) - x(end-1);
    dy2 = logy(end) - logy(end-1);
    slope_right = dy2 / dx2;

    new_x_right = (x(end) + dx2) : dx2 : (x(end) + right_extend_dB);
    new_logy_right = logy(end) + slope_right * (new_x_right - x(end));
    new_y_right = 10.^new_logy_right;

    % --- 최종 결합 ---
    x_ext = [new_x_left'; x; new_x_right'];
    y_ext = [new_y_left'; y; new_y_right'];

    extended_graph = [x_ext, y_ext];
end
