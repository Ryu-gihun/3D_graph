figure(1);
hold on;

x=zeros(1,100);
y=zeros(1,100);
a = 0;

for DB=12:12
    errcount=0;
    number=0;
    while(errcount == 0)
        
        number=number+1;
        k = 9;
        switch k
            case 5
                n1 = [1,1,0,1];
                n2 = [0,0,1,1];
            case 6
                n1 = [0,1,0,0,1];
                n2 = [1,1,0,1,1];
            case 7
                n1 = [1,1,1,0,0,1];
                n2 = [0,1,1,0,1,1];
            case 8
                n1 = [1,1,1,1,0,0,1];
                n2 = [0,1,0,0,1,1,1];
            case 9
                n1 = [1,1,1,0,1,0,1,1];
                n2 = [0,1,1,1,0,0,0,1];
            otherwise
                error('k값 범위는 5~9 입니다.');
        end

        num = 200;
        inp = randi([0, 1], 1, num);
        state = zeros(1, k-1);

        outp1 = zeros(1, 2*num + 2*(k-1));

        for i = 1:num + k-1
            in_val = 0;
            if i <= num
                in_val = inp(i);
            end
            outp1(2*i-1) = mod(sum(state .* n1) + in_val, 2);
            outp1(2*i)   = mod(sum(state .* n2) + in_val, 2);

            state = [in_val, state(1:end-1)];
        end

        state=zeros(2^(k-1),5);

        for i=1:2^(k-1)
            state(i,1)=i-1;  %state 상태
            state(i,2)=floor((i-1)/2);  %0 입력
            state(i,4)=floor((i-1)/2)+2^(k-2);  %1 입력
        end

        ss=zeros(1,k-1);

        for i=1:2^(k-1)
            ss=bitget(state(i,1),k-1:-1:1);


            a1=mod(sum(ss.*n1,"all"),2); %0 입력
            a2=mod(sum(ss.*n2,"all"),2);

            state(i,3)=a1*2+a2;

            a1=mod(sum(ss.*n1,"all")+1,2); %1 입력
            a2=mod(sum(ss.*n2,"all")+1,2);
            state(i,5)=a1*2+a2;
        end

        %%state의 1열 = state 상태
        %%state의 2열 = 0 입력 후 state 상태
        %%state의 3열 = 0 입력 -> 인코더 값
        %%state의 4열 = 1 입력 후 state 상태
        %%state의 5열 = 1 입력 -> 인코더 값

        inp22=outp1;
        [inp_l,inp_c]=size(inp22);
        length1 = inp_c/2;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i=1:inp_c
            if inp22(1,i)==0
                inp_22(1,i)=-1;
            end
        end

        r=(length(inp22))/(length(inp22)*2+2*(k-1));
        %DB=input('DB: ');
        db=10^(DB/20);
        sigma=(1/sqrt(r))*(1/db);
        noise=normrnd(0,sigma,[1,length(inp22)]);


        inp22=inp22+2*noise;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        result_v=ones(2^(k-1),length1).*-10000;
        %result_v(:,1)=-10000;
        result_v(state(1,2)+1,1)=0;
        result_v(state(1,4)+1,1)=0;

        addv=ones(2^(k-1),length1*2).*-10000;
        compare=ones(2^(k-1),2,length1).*-10000;
        %compare(:,2,1)=-10000;
        find01=ones(2^(k-1),length1).*-1000;





        for i=1:length1
            for j=1:2^(k-1)
                if i==1
                    compare(1,1,i)=vv(0,inp22(1,i*2-1),inp22(1,i*2));
                    compare(129,1,i)=vv(3,inp22(1,i*2-1),inp22(1,i*2));
                elseif  mod(j,2)==0
                    compare(state(j-1,2)+1,1,i)=result_v(j-1,i-1)+vv(state(j-1,3),inp22(1,i*2-1),inp22(1,i*2));
                    compare(state(j,2)+1,2,i)=result_v(j,i-1)+vv(state(j,3),inp22(1,i*2-1),inp22(1,i*2));
                    compare(state(j-1,4)+1,1,i)=result_v(j-1,i-1)+vv(state(j-1,5),inp22(1,i*2-1),inp22(1,i*2));
                    compare(state(j,4)+1,2,i)=result_v(j,i-1)+vv(state(j,5),inp22(1,i*2-1),inp22(1,i*2));
                end
            end

            for j=1:2^(k-1)
                if compare(j,1,i)> compare(j,2,i)
                    result_v(j,i)=compare(j,1,i);
                    find01(j,i)=0;
                else
                    result_v(j,i)=compare(j,2,i);
                    find01(j,i)=1;
                end
            end
        end

        result_de=ones(1,length1).*-1000;
        result_de(1, length1) = 0;
        result_rute=zeros(2^(k-1),length1);


        result_rute(1,length1)=1;
        for i=length1:-1:2 %열 거꾸로
            for j=1:1:2^(k-1) %행

                if result_rute(j,i)==1  %i=208 j=1
                    if find01(j,i)==0
                        for jj=1:1:2^(k-1)
                            if state(jj,2)==j-1
                                jjj=jj;
                                break;
                            elseif state(jj,4)==j-1
                                jjj=jj;  %159
                                break;
                            end
                        end
                        result_rute(jjj,i-1)=1;

                    elseif find01(j,i)==1
                        for jj=1:1:2^(k-1)
                            if state(jj,2)==j-1
                                jjj=jj;
                                break;
                            elseif state(jj,4)==j-1
                                jjj=jj;
                                break;
                            end
                        end
                        result_rute(jjj+1,i-1)=1;

                    end
                else
                    continue;
                end
            end
        end


        for i=1:length1
            for j=1:1:2^(k-1)
                if result_rute(j,i)==1
                    if j>128
                        result_de(1,i)=1;
                    else
                        result_de(1,i)=0;
                    end
                else
                    continue;
                end

            end
        end



        errcount=errcount+sum(result_de(1:num)~=inp);
        if errcount>100 && number>100
            break;
        end

        arr = [DB, number, errcount];

        disp(arr)


    a = 1;
    end
    
    x(1,DB)=DB-9;
    y(1,DB)=errcount/(200*number);
    % drawnow;

    

end

hold off;


plot(x, y);
set(gca, 'YScale', 'log'); % X, Y축 로그 스케일 적용
xlabel('X (log scale)');
ylabel('Y (log scale)');
title('축 설정을 통한 로그 스케일 그래프');
grid on;

function output=vv(a,b1,b2)  %%에러 계산 (클 수록 좋음)
if a==3 %11
    output=b1+b2;
elseif a==2 %10
    output=b1-b2;
elseif a==1 %01
    output=-b1+b2;
elseif a==0
    output=-b1-b2;
end


end

