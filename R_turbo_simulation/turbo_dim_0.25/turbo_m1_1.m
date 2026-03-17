% 입력 개수 2048
% db 7~14

input_0 = [0 0 -1 -1 -1 1
    1 4 -1 -1 -1 1
    2 5 -1 -1  1 -1
    3 1 -1 -1  1 -1
    4 2 -1 -1  1 -1
    5 6 -1 -1  1 -1
    6 7 -1 -1 -1 1
    7 3 -1 -1 -1 1];

input_1 = [0 4 1 -1 -1 -1
    1 0 1 -1 -1 -1
    2 1 -1  1 -1 -1
    3 5 -1  1 -1 -1
    4 6 -1  1 -1 -1
    5 2 -1  1 -1 -1
    6 3 1 -1 -1 -1
    7 7 1 -1 -1 -1];

db_list = [];    % dB 값 저장
ber_list1 = [];  % BER 값 저장
ber_list2 = [];
ber_list3 = [];
ber_list4 = [];
ber_list5 = [];
ber_list6 = [];
ber_list7 = [];
ber_list8 = [];

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
    run_count = 0;
    idx_db = find(dB_list==DB,1);

    error_stack1 = 0;
    error_stack2 = 0;
    error_stack3 = 0;
    error_stack4 = 0;
    error_stack5 = 0;
    error_stack6 = 0;
    error_stack7 = 0;
    error_stack8 = 0;

    while(1)
        num = 1024;
        input = randi([0 1], 1, num);
        cal_length = num+3;
        per_5 = log(0.5)*ones(1,cal_length);
        rule = Interleaver_3GPP(num);


        %%%%%%%%%%%%%%%%% encoder %%%%%%%%%%%%%%%%%
        [x,z] = turbo_encoder(input);
        x1z1 = [x(:),z(:)];
        x1z1(x1z1 == 0) = -1;
        [a_xz,sigma] = add_noise_m1(x1z1, DB);
        bottom = 2*(sigma^2);
        x1 = a_xz(:,1);
        z1 = a_xz(:,2);

        map_long = num+3;
        perc_map = zeros(8,map_long,2);
        perc_map(1,1,1) = 0.5;
        perc_map(5,1,2) = 0.5;
        cal_length = num+3;

        %%%%%%%%%%%%%%%%%%    perc_map    %%%%%%%%%%%%%%%%%%

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

        %%%%%%%%%%%%%%%%% interleaver %%%%%%%%%%%%%%%%%
        inter_input = input(rule);
        [x2,z2] = turbo_encoder(inter_input);
        
        x2(x2 == 0) = -1;
        z2(z2 == 0) = -1;

        x2(1:num) = x1(rule);

        x2(num+1:num+3) = add_noise_m1(x2(num+1:num+3),DB);

        z2 = add_noise_m1(z2,DB);
        a_xz2 = [x2(:),z2(:)];
        x2 = a_xz2(:,1);
        z2 = a_xz2(:,2);

        inv_rule = zeros(1,num);
        inv_rule(rule) = 1:num;


        %%%%%%%%%%%%%%%%%% 1st loop %%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% 1st decoder %%%%%%%%%%%%%%%%%

        gamma_map = cal_gamma_m1(a_xz, perc_map, per_5, per_5, bottom, cal_length);
        alpha_map = cal_alpha(gamma_map);
        beta_map = cal_beta(gamma_map);
        lamda = cal_lamda(gamma_map, alpha_map, beta_map);

        %%%%%%%%%%%%%%%%% 2nd decoder %%%%%%%%%%%%%%%%%

        [per_0, per_1] = percenti(lamda,num);
        per_0(1:num) = per_0(rule);
        per_1(1:num) = per_1(rule);


        gamma_map2 = cal_gamma_m1(a_xz2, perc_map ,per_0, per_1, bottom, cal_length);
        alpha_map2 = cal_alpha(gamma_map2);
        beta_map2 = cal_beta(gamma_map2);
        lamda2 = cal_lamda(gamma_map2, alpha_map2, beta_map2);

        L_lamda_1(1:num) = lamda2(inv_rule);


        %%%%%%%%%%%%%%%%%% 2nd loop %%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% 3rd decoder %%%%%%%%%%%%%%%%%
        input_lamda = L_lamda_1 - lamda(1:num);
        [per_0, per_1] = percenti(input_lamda,num);
        gamma_map3 = cal_gamma_m1(a_xz, perc_map, per_0, per_1, bottom, cal_length);
        alpha_map3 = cal_alpha(gamma_map3);
        beta_map3 = cal_beta(gamma_map3);
        lamda3 = cal_lamda(gamma_map3, alpha_map3, beta_map3);

        %%%%%%%%%%%%%%%%% 4th decoder %%%%%%%%%%%%%%%%%

        input_lamda = lamda3(1:num)-input_lamda;
        [per_0, per_1] = percenti(input_lamda,num);
        per_0(1:num) = per_0(rule);
        per_1(1:num) = per_1(rule);
        gamma_map4 = cal_gamma_m1(a_xz2, perc_map ,per_0, per_1, bottom, cal_length);
        alpha_map4 = cal_alpha(gamma_map4);
        beta_map4 = cal_beta(gamma_map4);
        lamda4 = cal_lamda(gamma_map4, alpha_map4, beta_map4);
        L_lamda_2(1:num) = lamda4(inv_rule);



        %%%%%%%%%%%%%%%%%% 3rd loop %%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% 5th decoder %%%%%%%%%%%%%%%%%
        input_lamda = L_lamda_2 - input_lamda(1:num);
        [per_0, per_1] = percenti(input_lamda,num);
        gamma_map5 = cal_gamma_m1(a_xz, perc_map, per_0, per_1, bottom, cal_length);
        alpha_map5 = cal_alpha(gamma_map5);
        beta_map5 = cal_beta(gamma_map5);
        lamda5 = cal_lamda(gamma_map5, alpha_map5, beta_map5);

        %%%%%%%%%%%%%%%%% 6th decoder %%%%%%%%%%%%%%%%%

        input_lamda = lamda5(1:num)-input_lamda;
        [per_0, per_1] = percenti(input_lamda,num);
        per_0(1:num) = per_0(rule);
        per_1(1:num) = per_1(rule);
        gamma_map6 = cal_gamma_m1(a_xz2, perc_map ,per_0, per_1, bottom, cal_length);
        alpha_map6 = cal_alpha(gamma_map6);
        beta_map6 = cal_beta(gamma_map6);
        lamda6 = cal_lamda(gamma_map6, alpha_map6, beta_map6);
        L_lamda_3(1:num) = lamda6(inv_rule);


        %%%%%%%%%%%%%%%%%% 4th loop %%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% 7th decoder %%%%%%%%%%%%%%%%%
        input_lamda = L_lamda_3 - input_lamda(1:num);
        [per_0, per_1] = percenti(input_lamda,num);
        gamma_map7 = cal_gamma_m1(a_xz, perc_map, per_0, per_1, bottom, cal_length);
        alpha_map7 = cal_alpha(gamma_map7);
        beta_map7 = cal_beta(gamma_map7);
        lamda7 = cal_lamda(gamma_map7, alpha_map7, beta_map7);

        %%%%%%%%%%%%%%%%% 8th decoder %%%%%%%%%%%%%%%%%

        input_lamda = lamda7(1:num)-input_lamda;
        [per_0, per_1] = percenti(input_lamda,num);
        per_0(1:num) = per_0(rule);
        per_1(1:num) = per_1(rule);
        gamma_map8 = cal_gamma_m1(a_xz2, perc_map ,per_0, per_1, bottom, cal_length);
        alpha_map8 = cal_alpha(gamma_map8);
        beta_map8 = cal_beta(gamma_map8);
        lamda8 = cal_lamda(gamma_map8, alpha_map8, beta_map8);
        L_lamda_4(1:num) = lamda8(inv_rule);


        %%%%%%%%%%%%%%%%%% 5th loop %%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% 9th decoder %%%%%%%%%%%%%%%%%
        input_lamda = L_lamda_4 - input_lamda(1:num);
        [per_0, per_1] = percenti(input_lamda,num);
        gamma_map9 = cal_gamma_m1(a_xz, perc_map, per_0, per_1, bottom, cal_length);
        alpha_map9 = cal_alpha(gamma_map9);
        beta_map9 = cal_beta(gamma_map9);
        lamda9 = cal_lamda(gamma_map9, alpha_map9, beta_map9);

        %%%%%%%%%%%%%%%%% 10th decoder %%%%%%%%%%%%%%%%%

        input_lamda = lamda9(1:num)-input_lamda;
        [per_0, per_1] = percenti(input_lamda,num);
        per_0(1:num) = per_0(rule);
        per_1(1:num) = per_1(rule);
        gamma_map10 = cal_gamma_m1(a_xz2, perc_map ,per_0, per_1, bottom, cal_length);
        alpha_map10 = cal_alpha(gamma_map10);
        beta_map10 = cal_beta(gamma_map10);
        lamda10 = cal_lamda(gamma_map10, alpha_map10, beta_map10);
        L_lamda_5(1:num) = lamda10(inv_rule);

        %%%%%%%%%%%%%%%%%% 6th loop %%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% 11th decoder %%%%%%%%%%%%%%%%%
        input_lamda = L_lamda_5 - input_lamda(1:num);
        [per_0, per_1] = percenti(input_lamda,num);
        gamma_map11 = cal_gamma_m1(a_xz, perc_map, per_0, per_1, bottom, cal_length);
        alpha_map11 = cal_alpha(gamma_map11);
        beta_map11 = cal_beta(gamma_map11);
        lamda11 = cal_lamda(gamma_map11, alpha_map11, beta_map11);

        %%%%%%%%%%%%%%%%% 12th decoder %%%%%%%%%%%%%%%%%

        input_lamda = lamda11(1:num)-input_lamda;
        [per_0, per_1] = percenti(input_lamda,num);
        per_0(1:num) = per_0(rule);
        per_1(1:num) = per_1(rule);
        gamma_map12 = cal_gamma_m1(a_xz2, perc_map ,per_0, per_1, bottom, cal_length);
        alpha_map12 = cal_alpha(gamma_map12);
        beta_map12 = cal_beta(gamma_map12);
        lamda12 = cal_lamda(gamma_map12, alpha_map12, beta_map12);
        L_lamda_6(1:num) = lamda12(inv_rule);

        %%%%%%%%%%%%%%%%%% 7th loop %%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% 13th decoder %%%%%%%%%%%%%%%%%
        input_lamda = L_lamda_6 - input_lamda(1:num);
        [per_0, per_1] = percenti(input_lamda,num);
        gamma_map13 = cal_gamma_m1(a_xz, perc_map, per_0, per_1, bottom, cal_length);
        alpha_map13 = cal_alpha(gamma_map13);
        beta_map13 = cal_beta(gamma_map13);
        lamda13 = cal_lamda(gamma_map13, alpha_map13, beta_map13);

        %%%%%%%%%%%%%%%%% 14th decoder %%%%%%%%%%%%%%%%%

        input_lamda = lamda13(1:num)-input_lamda;
        [per_0, per_1] = percenti(input_lamda,num);
        per_0(1:num) = per_0(rule);
        per_1(1:num) = per_1(rule);
        gamma_map14 = cal_gamma_m1(a_xz2, perc_map ,per_0, per_1, bottom, cal_length);
        alpha_map14 = cal_alpha(gamma_map14);
        beta_map14 = cal_beta(gamma_map14);
        lamda14 = cal_lamda(gamma_map14, alpha_map14, beta_map14);
        L_lamda_7(1:num) = lamda14(inv_rule);



        %%%%%%%%%%%%%%%%%% 8th loop %%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% 15th decoder %%%%%%%%%%%%%%%%%
        input_lamda = L_lamda_7 - input_lamda(1:num);
        [per_0, per_1] = percenti(input_lamda,num);
        gamma_map15 = cal_gamma_m1(a_xz, perc_map, per_0, per_1, bottom, cal_length);
        alpha_map15 = cal_alpha(gamma_map15);
        beta_map15 = cal_beta(gamma_map15);
        lamda15 = cal_lamda(gamma_map15, alpha_map15, beta_map15);

        %%%%%%%%%%%%%%%%% 16th decoder %%%%%%%%%%%%%%%%%

        input_lamda = lamda15(1:num)-input_lamda;
        [per_0, per_1] = percenti(input_lamda,num);
        per_0(1:num) = per_0(rule);
        per_1(1:num) = per_1(rule);
        gamma_map16 = cal_gamma_m1(a_xz2, perc_map ,per_0, per_1, bottom, cal_length);
        alpha_map16 = cal_alpha(gamma_map16);
        beta_map16 = cal_beta(gamma_map16);
        lamda16 = cal_lamda(gamma_map16, alpha_map16, beta_map16);
        L_lamda_8(1:num) = lamda16(inv_rule);


        result1 = L_lamda_1(1:num);
        result2 = L_lamda_2(1:num);
        result3 = L_lamda_3(1:num);
        result4 = L_lamda_4(1:num);
        result5 = L_lamda_5(1:num);
        result6 = L_lamda_6(1:num);
        result7 = L_lamda_7(1:num);
        result8 = L_lamda_8(1:num);


        for t = 1:length(result1)
            if result1(1,t) >= 0
                result1(1,t) = 1;
            else
                result1(1,t) = 0;
            end

            if result2(1,t) >= 0
                result2(1,t) = 1;
            else
                result2(1,t) = 0;
            end

            if result3(1,t) >= 0
                result3(1,t) = 1;
            else
                result3(1,t) = 0;
            end

            if result4(1,t) >= 0
                result4(1,t) = 1;
            else
                result4(1,t) = 0;
            end
            
            if result5(1,t) >= 0
                result5(1,t) = 1;
            else
                result5(1,t) = 0;
            end

            if result6(1,t) >= 0
                result6(1,t) = 1;
            else
                result6(1,t) = 0;
            end

            if result7(1,t) >= 0
                result7(1,t) = 1;
            else
                result7(1,t) = 0;
            end

            if result8(1,t) >= 0
                result8(1,t) = 1;
            else
                result8(1,t) = 0;
            end

        end
        result_output1 = result1(1,1:num);
        result_output2 = result2(1,1:num);
        result_output3 = result3(1,1:num);
        result_output4 = result4(1,1:num);
        result_output5 = result5(1,1:num);
        result_output6 = result6(1,1:num);
        result_output7 = result7(1,1:num);
        result_output8 = result8(1,1:num);

        % 에러 카운트
        error_stack1 = error_stack1 + sum(input ~= result_output1);
        error_stack2 = error_stack2 + sum(input ~= result_output2);
        error_stack3 = error_stack3 + sum(input ~= result_output3);
        error_stack4 = error_stack4 + sum(input ~= result_output4);
        error_stack5 = error_stack5 + sum(input ~= result_output5);
        error_stack6 = error_stack6 + sum(input ~= result_output6);
        error_stack7 = error_stack7 + sum(input ~= result_output7);
        error_stack8 = error_stack8 + sum(input ~= result_output8);

        run_count = run_count + 1;
        disp([DB,run_count, error_stack1, error_stack2, error_stack3, error_stack4, error_stack5, error_stack6, error_stack7, error_stack8]);

        if error_stack4 >= 100 && run_count > 100
            break;
        end
    end
    ber1 = error_stack1/ (num * run_count);
    ber2 = error_stack2 / (num * run_count);
    ber3 = error_stack3 / (num * run_count);
    ber4 = error_stack4 / (num * run_count);
    ber5 = error_stack5 / (num * run_count);
    ber6 = error_stack6 / (num * run_count);
    ber7 = error_stack7 / (num * run_count);
    ber8 = error_stack8 / (num * run_count);
    db_list(end+1) = DB;
    ber_list1(end+1) = ber1;
    ber_list2(end+1) = ber2;
    ber_list3(end+1) = ber3;
    ber_list4(end+1) = ber4;
    ber_list5(end+1) = ber5;
    ber_list6(end+1) = ber6;
    ber_list7(end+1) = ber7;
    ber_list8(end+1) = ber8;


    semilogy(db_list, ber_list1); hold on; % 로그 스케일
    semilogy(db_list, ber_list2);
    semilogy(db_list, ber_list3);
    semilogy(db_list, ber_list4);
    semilogy(db_list, ber_list5);
    semilogy(db_list, ber_list6);
    semilogy(db_list, ber_list7);
    semilogy(db_list, ber_list8);
    grid on;
    xlabel('SNR (dB)');
    ylabel('BER (Bit Error Rate)');
    title('BER (dB)  d=1/16 r=1/16');
    xlim([7 14]);  % x축 고정 (선택)
    ylim([1e-10 1]); % y축 고정 (선택)
    drawnow;  % 즉시 갱신
end
