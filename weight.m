% This function calcultes the weights for each particle based on the
% observation likelihood
%           S_bar(t)            4XM
%           outlier             1Xn
%           Psi(t)              1XnXM
% Outputs: 
%           S_bar(t)            4XM
function S_bar = weight(S_bar, Psi, outlier)

    % get valid measurements
    Psi_valid = Psi(1, outlier == 0, :);
    % weight proportional to the product of all likelihoods
    p = prod(Psi_valid, 2);
    p = p / sum(p);
    S_bar(4, :) = p;

end
