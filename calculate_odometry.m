% This function calculates the odometry information
% Inputs:
%           e_L(t):         1X1
%           e_R(t):         1X1
%           delta_t:        1X1
%           S(t-1):         4XM
% Outputs:
%           u(t):           3XM
function u = calculate_odometry(e_R, e_L, delta_t, S)
if ~delta_t
    u = [0; 0; 0];
    return;
end

% odometry parameters
E_T = 2048; % encoder ticks per wheel evolution
B= 0.35; % distance between contact points of wheels in m
R_L = 0.1; % radius of the left wheel in m
R_R = 0.1; % radius of the right wheel in m

omega_R_t = 2 * pi * e_R / (E_T * delta_t);
omega_L_t = 2 * pi * e_L / (E_T * delta_t);
omega_t = (omega_R_t * R_R - omega_L_t * R_L) / B; % angular velocity
velocity_t = (omega_R_t * R_R + omega_L_t * R_L) / 2; % translational velocity

% particle evolution based on odometry information
u = [(velocity_t * delta_t) .* cos(S(3, :));
     velocity_t * delta_t .* sin(S(3, :));
     repmat(omega_t * delta_t, 1, size(S, 2))];

end