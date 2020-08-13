% This function performs systematic re-sampling
% Inputs:   
%           S_bar(t):       4XM
% Outputs:
%           S(t):           4XM
function S = systematic_resample(S_bar)
	
    global M % number of particles 
    
    S = zeros(size(S_bar));
    CDF = zeros(1, M);
    
    for m = 1:M
        CDF(m) = sum(S_bar(4, 1:m)); 
    end
    
    r = rand() / M;
    for m = 1:M
        k = find(CDF >= (r + (m-1)/M), 1, 'first');
        if isempty(k)
            k = M;
            disp(k);
        end
        S(:, m) = S_bar(:, k);
        S(4, m) = 1 / M;
    end
end