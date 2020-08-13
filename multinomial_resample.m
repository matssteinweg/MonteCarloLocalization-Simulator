% This function performs multinomial re-sampling
% Inputs:   
%           S_bar(t):       4XM
% Outputs:
%           S(t):           4XM
function S = multinomial_resample(S_bar)

    global M % number of particles
    
    S = zeros(size(S_bar));
    CDF = zeros(1,M);
    
    for m = 1:M
        CDF(m) = sum(S_bar(4, 1:m)); 
    end
    
    for m=1:M
        r = rand();
        i = find(CDF >=r, 1, 'first');
        if isempty(i)
            i = M;
        end
        S(:, m) = S_bar(:, i);
        S(4, m) = 1 / M;
    end
end
