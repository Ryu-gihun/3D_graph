    % 입력 개수 2048
% db 7~14

input_0 = [0 0 0 0
    1 4 0 0
    2 5 0 1
    3 1 0 1
    4 2 0 1
    5 6 0 1
    6 7 0 0
    7 3 0 0];

input_1 = [0 4 1 1
    1 0 1 1
    2 1 1 0
    3 5 1 0
    4 6 1 0
    5 2 1 0
    6 3 1 1
    7 7 1 1];

a = 1;

dB_list = 7:14;                    % 테스트할 dB 구간
BER_final = nan(size(dB_list));    % 각 dB의 최종 BER 저장

figure('Name','Turbo BER Monitor','NumberTitle','off');
hold on; grid on; set(gca,'YScale','log');
xlim([min(dB_list) max(dB_list)]); ylim([1e-5 1]);
xlabel('E_b/N_0 (dB)'); ylabel('BER');
title('Final BER per dB');
ber_line = plot(dB_list, BER_final, 'o-','LineWidth',1.5);

for DB = 7:14
    error_stack = 0;
    run_count = 0;
    idx_db = find(dB_list==DB,1);

    while(1)
        num = 1024;
        input = randi([0 1], 1, num);
        cal_length = num+3;
        per_5 = log(0.5)*ones(1,cal_length);
        rule = Interleaver_3GPP(num);


        %%%%%%%%%%%%%%%%% encoder %%%%%%%%%%%%%%%%%
        [x,z] = turbo_encoder(input);
        x1z1 = [x(:),z(:)];
        [a_xz,sigma] = add_noise(x1z1, DB);
        bottom = 2*(sigma^2);
        x1 = a_xz(:,1);
        z1 = a_xz(:,2);

        %%%%%%%%%%%%%%%%% interleaver %%%%%%%%%%%%%%%%%
        inter_input = input(rule);
        [x2,z2] = turbo_encoder(inter_input);
        x2(1:num) = x1(rule);
        x2(num+1:num+3) = add_noise(x2(num+1:num+3),DB);
        z2 = add_noise(z2,DB);
        a_xz2 = [x2(:),z2(:)];
        x2 = a_xz2(:,1);
        z2 = a_xz2(:,2);

        %%%%%%%%%%%%%%%%% 1st decoder %%%%%%%%%%%%%%%%%
        map_long = length(x1);
        perc_map = zeros(8,map_long,2);
        perc_map(1,1,1) = 0.5;
        perc_map(5,1,2) = 0.5;

        for b = 1:map_long
            for a = 1:8
                if perc_map(a,b,1) ~= 0
                    perc_map(input_0(a,2)+1, b+1, 1) = 0.5;
                    perc_map(input_1(a,2)+1, b+1, 2) = 0.5;
                end
                if perc_map(a,b,2) ~= 0
                    perc_map(input_0(a,2)+1, b+1, 1) = 0.5;
                    perc_map(input_1(a,2)+1, b+1, 2) = 0.5;
                end
            end
        end
        
        gamma_map = cal_gamma(a_xz, perc_map, per_5, per_5, bottom, cal_length);
        alpha_map = cal_alpha(gamma_map);
        beta_map = cal_beta(gamma_map);
        lamda = cal_lamda(gamma_map, alpha_map, beta_map);

        %%%%%%%%%%%%%%%%% 2nd decoder %%%%%%%%%%%%%%%%%
        [per_0, per_1] = percenti(lamda,num);
        per_0(1:num) = per_0(rule);
        per_1(1:num) = per_1(rule);
        gamma_map2 = cal_gamma(a_xz2, perc_map ,per_0, per_1, bottom, cal_length);
        alpha_map2 = cal_alpha(gamma_map2);
        beta_map2 = cal_beta(gamma_map2);
        lamda2 = cal_lamda(gamma_map2, alpha_map2, beta_map2);

        result2 = zeros(1,length(lamda2));
        result2(rule) = lamda2(1:num);

        for t = 1:length(result2)
            if result2(1,t) >= 0
                result2(1,t) = 1;
            else
                result2(1,t) = 0;
            end
        end
        result_output = result2(1,1:num);
        
        % 에러 카운트
        error_stack = error_stack + sum(input ~= result_output);
        run_count = run_count + 1;
        disp([DB,run_count,error_stack]);

        if error_stack >= 100 && run_count > 100
            break;
        end
    end

    BER = error_stack/(num*run_count);
    BER_final(idx_db) = BER;
    mask = ~isnan(BER_final);
    set(ber_line, 'XData', dB_list(mask), 'YData', BER_final(mask));
    title('Final BER per dB');
    drawnow
end
