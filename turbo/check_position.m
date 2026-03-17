in_points = [];
result = [];

for x = 0.0:0.01:0.6
    for y = 0.0:0.01:0.6
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

                for x_range = (7-delta): 0.5 : (16-delta)

                    y1_val = interp1(graph1(:,1), log10(y1), x_range, 'linear', 'extrap');
                    y2_val = interp1(graph2(:,1), log10(y2), x_range, 'linear', 'extrap');
                    y3_val = interp1(graph3(:,1), log10(y3), x_range, 'linear', 'extrap');

                    y1_val = max(y1_val, 1e-30);
                    y2_val = max(y2_val, 1e-30);
                    y3_val = max(y3_val, 1e-30);

                    w1 = k1*m1 / sum(k1*m1 + k2*m2 + k3*m3);
                    w2 = k2*m2 / sum(k1*m1 + k2*m2 + k3*m3);
                    w3 = k3*m3 / sum(k1*m1 + k2*m2 + k3*m3);
                    %ber_val = 10^(w1*log10(y1) + w2*log10(y2) + w3*log10(y3));

                    numerator = k1*m1*log10(y1_val) + k2*m2*log10(y2_val) + k3*m3*log10(y3_val);
                    denominator = k1*m1 + k2*m2 + k3*m3;
                    ber_val = 10.^(numerator ./ denominator);
                    BER(end + 1, :) = [x_range, ber_val];

                end

                target_y = 1e-3;
                BER(:,1) = BER(:,1) + delta;


                [ber_vals_unique, idx_unique] = unique(BER(:,2), 'stable');  % stable: 원래 순서 유지
                snr_vals_unique = BER(idx_unique, 1);


                z = interp1(ber_vals_unique, snr_vals_unique, target_y, 'linear', 'extrap');
                fprintf('x=%.4f, y=%.4f, z=%.4f → m1=%.4f, m2=%.4f, m3=%.4f\n', x, y, z, m1, m2, m3);

                result(end+1, :) = [x, y, z];

            else
                error('최적화 실패: x=%.2f, y=%.2f에서 수렴하지 않았습니다 (exitflag=%d)', x, y, exitflag);
            end



        elseif keeprun == 0
            %%%%%%%%%삼각형 밖의 점 --> 다음 점으로 이동%%%%%%%%%
            continue;
        end
    end
    % 그래프를 하나의 figure에 함께 출력
    %figure;

    % 1. BER 그래프
    %semilogy(BER(:,1), BER(:,2), 'b-', 'LineWidth', 2);
    %hold on;



    % 그래프의 레이블과 제목
    %xlabel('x Range');
    %ylabel('y Value / BER');
    %title('BER and Graphs 1, 2, 3');
    %legend('BER', 'Graph 1', 'Graph 2', 'Graph 3');
    %grid on;
    %hold off;
end


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

% 1. X, Y, Z 데이터 추출
x = result(:,1);
y = result(:,2);
z = result(:,3);

[xq, yq] = meshgrid(linspace(min(x), max(x), 100), linspace(min(y), max(y), 100));


zq = griddata(x, y, z, xq, yq, 'linear');


surf(xq, yq, zq, 'EdgeColor', 'none', 'FaceAlpha', 0.7);
shading interp;


poly_x = [t_1(1) t_2(1) t_3(1) t_4(1) t_5(1) t_6(1) t_7(1) t_1(1)];
poly_y = [t_1(2) t_2(2) t_3(2) t_4(2) t_5(2) t_6(2) t_7(2) t_1(2)];
poly_z = zeros(size(poly_x)); % z = 0 평면

%plot3(poly_x, poly_y, poly_z, 'r-', 'LineWidth', 2);

legend('SNR Points', 'Polygon Boundary', 'Interpolated Surface');
colormap turbo;
colorbar;
grid on;