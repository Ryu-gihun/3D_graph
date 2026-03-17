for x = 0:0.01:0.5
    for y = 0:0.01:0.5
        
        position = 1;

        target = [x y];

        k = 200;
        K = 9;
        t_1 = [0.5, 0.4808];
        t_2 = [0.5, 0.2404];
        t_3 = [0.375, 0.0962];
        t_4 = [0.1826, 0.074];
        t_5 = [0.0625, 0.0601];
        t_6 = [0.125, 0.1202];
        t_7 = [0.25, 0.2404];




        while a == 0
            
            switch position
                case 1
                    d_A = t_1;
                    d_B = t_2;
                    d_C = t_7;

                case 2
                    d_A = t_3;
                    d_B = t_2;
                    d_C = t_7;

                case 3
                    d_A = t_3;
                    d_B = t_4;
                    d_C = t_7;

                case 4
                    d_A = t_4;
                    d_B = t_6;
                    d_C = t_7;

                case 5
                    d_A = t_6;
                    d_B = t_5;
                    d_C = t_4;
            end

            posi_re = isPointInTriangle(target, d_A, d_B, d_C);

            if posi_re == 0 & position > 5
                disp('안에 없음');
                a = 0;
                keeprun = 0;
                break;
                
            elseif posi_re ==1
                a = 1;
                keeprun = 1;
                break;
            elseif posi_re == 0 && position <= 5
                a = 0;
                position = position + 1;
            end
        end

        if keeprun == 1
        %%%%%%%%%좌표 안의 값 구하기%%%%%%%%%
            
        elseif keeprun == 0
        %%%%%%%%%삼각형 밖의 점 --> 다음 점으로 이동%%%%%%%%%
            break;
        end



    end
end



