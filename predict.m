% This function performs the prediction step.
% Inputs:
%           S(t-1)            4XN
%           u(t)              3X1
% Outputs:   
%           S_bar(t)          4XN
function [S_bar] = predict(S, u)

    global R % covariance matrix of motion model | shape 3X3
    global M % number of particles
    
    S_bar(1:3,:) = S(1:3,:) + u; % apply motion model
    S_bar(1:3,:) = S_bar(1:3,:) + randn(3, M) .* repmat(sqrt(diag(R)), 1, M); % diffusion
    S_bar(3, :) = mod(S_bar(3,:)+pi,2*pi) - pi; % keep angle in range
    S_bar(4,:) = S(4,:); % particle weights remain unchanged during prediction
    
end