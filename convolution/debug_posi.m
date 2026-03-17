in_points = [];
result = [];

% ===== [ADD] 수동 분할 실행 설정 =====
% 실행할 구간과 해상도(간격)를 수동으로 지정
x_start = 0.0;  x_end = 0.5;   % 예: 0.000~0.600
y_start = 0.0;  y_end = 0.5;   % 예: 0.000~0.600
dx = 0.01;      dy = 0.01;     % 예: 더 촘촘하게

% 저장 파일명(실행마다 바꿔서 저장)
OUTFILE = 'result_123.mat';

% (아래는 계산용 리스트. 원본 for문에 사용)
x_list = x_start:dx:x_end;
y_list = y_start:dy:y_end;
% =====================================


for  x = x_list
    for y = y_list
        a = 0;
        keeprun = 0;
        position = 1;
        target = [x y];
        K = 9;
        t_1 = [0.5, 0.4808];%[d,r]
        t_2 = [0.5, 0.2404];
        t_3 = [0.375, 0.0962];
        t_4 = [0.1826, 0.074];
        t_5 = [0.0625, 0.0601];
        t_6 = [0.125, 0.1202];
        t_7 = [0.25, 0.2404];
        while a == 0

            switch position
                case 1
                    d_A = t_1; d_B = t_2; d_C = t_7;
                case 2
                    d_A = t_3; d_B = t_2; d_C = t_7;
                case 3
                    d_A = t_3; d_B = t_4; d_C = t_7;
                case 4
                    d_A = t_4; d_B = t_6;d_C = t_7;
                case 5
                    d_A = t_6; d_B = t_5; d_C = t_4;
            end
            posi_re = isPointInTriangle(target, d_A, d_B, d_C);
            if posi_re == 0 & position > 5
                disp('안에 없음');
                a = 0;
                keeprun = 0;
                break;

            elseif posi_re == 1
                a = 1;
                keeprun = 1;
                break;
            elseif posi_re == 0 && position <= 5
                a = 0;
                position = position + 1;
                keeprun = 0;
            end
        end

        if keeprun == 1
            %%%%%%%%%좌표 안의 값 구하기%%%%%%%%%
            in_points = [in_points; x, y];
            k1 = 200; k2 = 200; k3 = 200;
            n1 = k1/d_A(1,2); n2 = k2/d_B(1,2); n3 = k3/d_C(1,2);
            [m1, m2, m3, fval] = solve_m123(x, y, d_A, d_B, d_C);

            [graph1, graph2, graph3] = loadGraphsFromTriangle(d_A, d_B, d_C);

            graph1 = extend_graph(graph1, 5, 5);  % 좌우 3dB씩 확장
            graph2 = extend_graph(graph2, 5, 5);
            graph3 = extend_graph(graph3, 5, 5);

            % 그래프 데이터를 분리
            x1 = graph1(:,1); y1 = graph1(:,2);
            x2 = graph2(:,1); y2 = graph2(:,2);
            x3 = graph3(:,1); y3 = graph3(:,2);

            exitflag = 1;

            if exitflag > 0

                delta1 = 10 * log10(1 / d_A(1,2));
                delta2 = 10 * log10(1 / d_B(1,2));
                delta3 = 10 * log10(1 / d_C(1,2));

                graph1(:,1) = graph1(:,1) - delta1;
                graph2(:,1) = graph2(:,1) - delta2;
                graph3(:,1) = graph3(:,1) - delta3;



                R = (k1*m1 + k2*m2 + k3*m3)/(n1*m1 + n2*m2 + n3*m3);
                delta = 10 * log10(1/R);

                BER = [];
                interp_graph1 = [];
                interp_graph2 = [];
                interp_graph3 = [];

                for x_range = (7-delta): 1 : (16-delta)

                    % 🔧 로그 스케일 보간 사용
                    y1_val = 10.^interp1(graph1(:,1), log10(y1), x_range, 'linear', 'extrap');
                    y2_val = 10.^interp1(graph2(:,1), log10(y2), x_range, 'linear', 'extrap');
                    y3_val = 10.^interp1(graph3(:,1), log10(y3), x_range, 'linear', 'extrap');

                    y1_val = max(y1_val, 1e-30);
                    y2_val = max(y2_val, 1e-30);
                    y3_val = max(y3_val, 1e-30);

                    interp_graph1(end+1,:) = [x_range, y1_val];
                    interp_graph2(end+1,:) = [x_range, y2_val];
                    interp_graph3(end+1,:) = [x_range, y3_val];

                    % 로그 평균 → 벡터에도 적용 가능하게
                    w1 = k1*m1 / sum(k1*m1 + k2*m2 + k3*m3);
                    w2 = k2*m2 / sum(k1*m1 + k2*m2 + k3*m3);
                    w3 = k3*m3 / sum(k1*m1 + k2*m2 + k3*m3);
                    %ber_val = 10 ^ (w1*log10(y1) + w2*log10(y2) + w3*log10(y3));

                    numerator = k1*m1*y1_val + k2*m2*y2_val + k3*m3*y3_val;
                    denominator = k1*m1 + k2*m2 + k3*m3;
                    ber_val = numerator / denominator;
                    BER(end + 1, :) = [x_range, ber_val];

                end

                target_y = 1e-3;
                BER(:,1) = BER(:,1) + delta;

                % BER(:,2)가 X로 들어가므로 고유값만 유지
                [ber_vals_unique, idx_unique] = unique(BER(:,2), 'stable');  % stable: 원래 순서 유지
                snr_vals_unique = BER(idx_unique, 1);

                % 보간 수행
                log_ber = log10(ber_vals_unique);
                log_target_y = log10(target_y);

                [log_ber_unique, idx_unique] = unique(round(log_ber, 8), 'stable');
                snr_vals_unique = snr_vals_unique(idx_unique);

                z = interp1(log_ber_unique, snr_vals_unique, log_target_y, 'linear', 'extrap');
                fprintf('x=%.4f, y=%.4f, z=%.4f → m1=%.10f, m2=%.10f, m3=%.10f\n', x, y, z, m1, m2, m3);
                result(end+1, :) = [x, y, z];

            else
                error('최적화 실패: x=%.2f, y=%.2f에서 수렴하지 않았습니다 (exitflag=%d)', x, y, exitflag);
            end



        elseif keeprun == 0
            %%%%%%%%%삼각형 밖의 점 --> 다음 점으로 이동%%%%%%%%%
            continue;
        end
    end
end

% result: [x, y, z] (x = Aeff/σ, y = code rate, z = BER or SNR@BER)

% 1. 고유 x, y 좌표 추출
x_vals = unique(result(:,1));  % Aeff/σ
y_vals = unique(result(:,2));  % Code rate

% 2. 2D 그리드 구성
[X, Y] = meshgrid(x_vals, y_vals);

% 3. Z 매트릭스 (각 x,y 위치에 대응하는 z값 저장)
Z = nan(size(X));
for i = 1:size(result, 1)
    xi = find(abs(x_vals - result(i,1)) < 1e-6);
    yi = find(abs(y_vals - result(i,2)) < 1e-6);
    if ~isempty(xi) && ~isempty(yi)
        Z(yi, xi) = result(i,3);  % 행: y, 열: x
    end
end

% ===== [ADD] 이번 실행 결과 저장 =====
if exist('result','var') && ~isempty(result)
    save(OUTFILE, 'result', '-v7.3'); % 대용량 대비 -v7.3 권장
    fprintf('Saved: %s (rows: %d)\n', OUTFILE, size(result,1));
else
    warning('저장할 result가 비어 있습니다. OUTFILE=%s', OUTFILE);
end
% =====================================

