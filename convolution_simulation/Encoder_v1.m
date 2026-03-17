start_i = [1 0 0 1 0 1];
%start_i = randi([0 1], 1, 200);
error_stack = 0;

n = size(start_i,2);

k=9;

if k==5
    n1 = [1,1,1,0,1];
    n2 = [1,0,0,1,1];
elseif k ==6
    n1 = [1,0,1,0,0,1];
    n2 = [1,1,1,0,1,1];
elseif k ==7
    n1 = [1,1,1,1,0,0,1];
    n2 = [1,0,1,1,0,1,1];
elseif k ==8
    n1 = [1,1,1,1,1,0,0,1];
    n2 = [1,0,1,0,0,1,1,1];
elseif k ==9
    n1 = [1,1,1,1,0,1,0,1,1];
    n2 = [1,0,1,1,1,0,0,0,1];
end

state = zeros(1,k);
enc_result = zeros(1, 2*(n+k-1));

for a=1:(n+k-1)
    
    x=0;
    y=0;
    
    if a<= n
        state(1,1) = start_i(1,a);
    else
        state(1,1) = 0;
    end
    
    for b=1:k
        if n1(1,b)==1
            x = x + state(1,b);
        end
        if n2(1,b)==1
            y = y + state(1,b);
        end
    end
    result1 = mod(x,2);
    result2 = mod(y,2); 
    
    state = circshift(state,1);
    
    
    enc_result(1,2*a-1) = result1;
    enc_result(1,2*a) = result2;
end

disp('Encoded Result :');
disp(enc_result);
disp(start_i);