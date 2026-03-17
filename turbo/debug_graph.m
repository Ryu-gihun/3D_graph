in_points = [];
result = [];

% 저장 파일명(실행마다 바꿔서 저장)
%OUTFILE = 'result_01.mat';

% (아래는 계산용 리스트. 원본 for문에 사용)
%x_list = x_start:dx:x_end;
%y_list = y_start:dy:y_end;
% =====================================

% ===== [ADD] 그래프 출력 옵션 (저장 없이 화면 표시만) =====
SHOW_PLOTS   = true;   % 그래프 보기 on/off
PLOT_VISIBLE = true;   % figure 창 보이기 여부
PLOT_EVERY_N = 1;      % N번째 점마다 그림(많으면 10~50으로)
plot_count   = 0;      % 내부 카운터


for  x = 0.40%x_list
    for y = 0.16%y_list
        a = 0;
        keeprun = 0;
        position = 1;
        target = [x y];
        %K = 9;
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

        while a == 0

            switch position
                case 1
                    d_A = t_1; d_B = t_2; d_C = t_4;
                case 2
                    d_A = t_2; d_B = t_4; d_C = t_3;
                case 3
                    d_A = t_3; d_B = t_4; d_C = t_8;
                case 4
                    d_A = t_4; d_B = t_5;d_C = t_8;
                case 5
                    d_A = t_5; d_B = t_6; d_C = t_8;
                case 6
                    d_A = t_6; d_B = t_8; d_C = t_9;
                case 7
                    d_A = t_4; d_B = t_5; d_C = t_7;
                case 8
                    d_A = t_5; d_B = t_6; d_C = t_7;
                case 9
                    d_A = t_6; d_B = t_7; d_C = t_9;
                case 10
                    d_A = t_7; d_B = t_9; d_C = t_10;
            end
            posi_re = isPointInTriangle(target, d_A, d_B, d_C);

            if posi_re == 0 & position > 10
                disp('안에 없음');
                a = 0;
                keeprun = 0;
                break;

            elseif posi_re == 1
                a = 1;
                keeprun = 1;
                break;

            elseif posi_re == 0 && position <= 10
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

                for x_range = (7-delta): 0.1 : (16-delta)

                    % 🔧 로그 스케일 보간 사용
                    y1_val = 10.^interp1(graph1(:,1), log10(y1), x_range, 'linear', 'extrap');
                    y2_val = 10.^interp1(graph2(:,1), log10(y2), x_range, 'linear', 'extrap');
                    y3_val = 10.^interp1(graph3(:,1), log10(y3), x_range, 'linear', 'extrap');

                    y1_val = max(y1_val, 1e-50);
                    y2_val = max(y2_val, 1e-50);
                    y3_val = max(y3_val, 1e-50);

                    interp_graph1(end+1,:) = [x_range, y1_val];
                    interp_graph2(end+1,:) = [x_range, y2_val];
                    interp_graph3(end+1,:) = [x_range, y3_val];

                    % 로그 평균 → 벡터에도 적용 가능하게
                    w1 = k1*m1 / sum(k1*m1 + k2*m2 + k3*m3);
                    w2 = k2*m2 / sum(k1*m1 + k2*m2 + k3*m3);
                    w3 = k3*m3 / sum(k1*m1 + k2*m2 + k3*m3);
                    %ber_val = w1*y1_val + w2*y2_val + w3*y3_val;

                    %numerator = k1*m1*log10(y1_val) + k2*m2*log10(y2_val) + k3*m3*log10(y3_val);
                    %denominator = k1*m1 + k2*m2 + k3*m3;
                    %ber_val = 10.^(numerator ./ denominator);
                    %BER(end + 1, :) = [x_range, ber_val];
                    ber_val = w1*y1_val + w2*y2_val + w3*y3_val;
                    
                    BER(end + 1, :) = [x_range, ber_val];

                end

                target_y = 1e-3;
                BER_preDelta = BER;          % delta 적용 전 (그림용)
                BER(:,1) = BER(:,1) + delta; % 최종 SNR 축

                % -------------------------


                % -------------------------
                % [B] 기울기 연장 방식: 10^-12 기준으로 10^-3 SNR 찾기
                % -------------------------
                target_ber12 = 1e-12;
                log_ber_all  = log10(BER(:,2));    % 전체 log10(BER)
                snr_all      = BER(:,1);           % 전체 SNR(dB)

                % 1) BER=1e-12에 가장 가까운 점 찾기
                [~, idx0] = min(abs(log_ber_all - log10(target_ber12)));
                x0 = snr_all(idx0);                % 10^-12 근처 SNR
                y0 = log_ber_all(idx0);            % 이론상 -12 근처

                % 2) x0 ± 0.1 dB 에서의 log10(BER) 구하기
                x_minus = x0 - 0.1;
                x_plus  = x0 + 0.1;

                y_minus = interp1(snr_all, log_ber_all, x_minus, 'linear', 'extrap');
                y_plus  = interp1(snr_all, log_ber_all, x_plus,  'linear', 'extrap');

                % 3) 기울기 m (log10(BER) vs SNR)
                m = (y_plus - y_minus) / (x_plus - x_minus);   % /0.2

                % 4) BER=1e-3 (log10 = -3)에서의 SNR
                y_target = log10(1e-3);    % -3
                z_slope = x0 + (y_target - y0) / m;

                fprintf('   [slope-based] x=%.3f dB (BER≈1e-12), y=%.3f,  z(dB)=%.3f dB\n', ...
                    x, y, z_slope);

                result(end+1, :) = [x, y, z_slope];


                % ===== [PLOT] A/B/C 그래프 & 보간 점 & 결과 z 시각화 (Y축 로그 확실히 적용) =====
                plot_count = plot_count + 1;
                if SHOW_PLOTS && mod(plot_count, PLOT_EVERY_N) == 0
                    g1 = sortrows(graph1,1); [xg1, iu1] = unique(g1(:,1),'stable'); yg1 = max(g1(iu1,2), 1e-30);
                    g2 = sortrows(graph2,1); [xg2, iu2] = unique(g2(:,1),'stable'); yg2 = max(g2(iu2,2), 1e-30);
                    g3 = sortrows(graph3,1); [xg3, iu3] = unique(g3(:,1),'stable'); yg3 = max(g3(iu3,2), 1e-30);

                    have_interp = ~isempty(interp_graph1) && ~isempty(BER);

                    if PLOT_VISIBLE
                        f = figure('Color','w','Name',sprintf('BER Curves @ x=%.3f, y=%.3f',x,y));
                    else
                        f = figure('Color','w','Visible','off','Name',sprintf('BER Curves @ x=%.3f, y=%.3f',x,y));
                    end
                    hold on; grid on; box on;

                    % --- 원 데이터 ---
                    semilogy(xg1, yg1, '-', 'LineWidth', 1.6, 'DisplayName','Graph A');
                    semilogy(xg2, yg2, '-', 'LineWidth', 1.6, 'DisplayName','Graph B');
                    semilogy(xg3, yg3, '-', 'LineWidth', 1.6, 'DisplayName','Graph C');

                    % --- 보간 및 가중 BER ---
                    if have_interp
                        semilogy(interp_graph1(:,1), max(interp_graph1(:,2),1e-30), '.', 'MarkerSize',12, 'DisplayName','A (interp pts)');
                        semilogy(interp_graph2(:,1), max(interp_graph2(:,2),1e-30), '.', 'MarkerSize',12, 'DisplayName','B (interp pts)');
                        semilogy(interp_graph3(:,1), max(interp_graph3(:,2),1e-30), '.', 'MarkerSize',12, 'DisplayName','C (interp pts)');
                        semilogy(BER_preDelta(:,1), max(BER_preDelta(:,2),1e-30), '--', ...
                            'LineWidth', 1.6, 'DisplayName','Weighted BER (pre-Δ)');
                    end

                    % --- 목표 BER & 결과 SNR 표시 ---
                    target_y = 1e-3;

                    yline(target_y, ':', sprintf('Target BER=%.0e',target_y), ...
                        'LabelVerticalAlignment','bottom');

                    % 🔹 z (interp 기반) 표시
                    if exist('z','var') && isfinite(z)
                        % x축은 현재 pre-Δ (graph1, BER_preDelta 기준)이므로 z도 -delta 해서 맞춰주는 편이 일관됨
                        xline(z-delta, ':', sprintf('SNR@BER=%.2f dB (interp)', z), ...
                            'LabelVerticalAlignment','middle');
                        plot(z-delta, target_y, 'o', 'MarkerSize',8, 'LineWidth',1.6, ...
                            'DisplayName','Estimate (interp)');
                    end

                    % 🔹 z_slope (기울기 기반) 추가 표시
                    if exist('z_slope','var') && isfinite(z_slope)
                        xline(z_slope-delta, '--', sprintf('SNR@BER=%.2f dB (slope)', z_slope), ...
                            'LabelVerticalAlignment','middle');
                        plot(z_slope-delta, target_y, 's', 'MarkerSize',8, 'LineWidth',1.6, ...
                            'DisplayName','Estimate (slope)');
                    end

                    % --- 축, 제목, 범례 ---
                    set(gca, 'YScale', 'log');
                    ylim([1e-5 1]);                      % 적당한 범위 (필요시
                    % 조정)
                    xlabel('SNR (dB)');
                    ylabel('BER (log scale)');
                    title(sprintf('A/B/C BER curves @ x=%.3f, y=%.3f (pos=%d)', x, y, position));
                    legend('Location','southwest');
                    grid on; grid minor;

                    drawnow;

                    fprintf('y=%.3f  R=%.3e  delta=%.3f dB\n   case : %d', y, R, delta, position);
                    if ~PLOT_VISIBLE
                        close(f);
                    end
                end
                % ===== [PLOT END] =====

            else
                error('최적화 실패: x=%.2f, y=%.2f에서 수렴하지 않았습니다 (exitflag=%d)', x, y, exitflag);
            end



        elseif keeprun == 0
            %%%%%%%%%삼각형 밖의 점 --> 다음 점으로 이동%%%%%%%%%
            continue;
        end
    end
end
