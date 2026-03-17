function bits = apply_burst_errors(bits, numBursts, burstLength)
    
    len = size(bits,2);
    for i = 1:numBursts
        startIdx = randi([1, len - burstLength + 1]); % 랜덤한 위치에서 시작
        bits(:, startIdx:startIdx + burstLength - 1) = 0; % 비트 반전
    end
end