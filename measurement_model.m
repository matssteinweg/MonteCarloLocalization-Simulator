% This function is the implementation of the measurement model.
% The bearing should be in the interval [-pi,pi)
% Inputs:
%           S(t)                           4XM
%           j                              1X1
% Outputs:  
%           h                              2XM
function z_j = measurement_model(S, j)

global map % map including the coordinates of all landmarks | shape 2Xn for n landmarks
global M % number of particles

landmark_repmat = repmat(map(:, j), 1, M);
distance = landmark_repmat - S(1:2, :);
    
r = zeros(1, M);
angle = zeros(1, M);
    
for i = 1:size(distance, 2)
    r(i) = norm(distance(:, i));
    angle(i) = atan2(landmark_repmat(2,i) - S(2,i), landmark_repmat(1,i) - S(1,i));
end
    
angle = angle - S(3,:);
angle = mod(angle+pi,2*pi) - pi;

% expected measurement of landmark j
z_j = [r; angle];

end