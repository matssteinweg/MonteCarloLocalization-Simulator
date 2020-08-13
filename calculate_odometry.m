% This function calculates the odometry information
% Inputs:
%           e_L(t):         1X1
%           e_R(t):         1X1
%           E_T:            1X1
%           B:              1X1
%           R_L:            1X1
%           R_R:            1X1
%           delta_t:        1X1
% Outputs:
%           v:              1X1
%           omega:          1X1
function [v, omega] = calculate_odometry(e_R, e_L, E_T, B, R_R, R_L, delta_t)

    if ~delta_t
        v = 0;
        omega = 0;
        return;
    end

    omega_R_t = 2 * pi * e_R / (E_T * delta_t);
    omega_L_t = 2 * pi * e_L / (E_T * delta_t);
    omega = (omega_R_t * R_R - omega_L_t * R_L) / B; % angular velocity
    v = (omega_R_t * R_R + omega_L_t * R_L) / 2; % translational velocity

end