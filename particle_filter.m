% This function performs one iteration of the particle filter.
% Inputs:
%           S(t-1)                    4XM
%           v                         1X1
%           omega                     1X1
%           z                         2Xn
%           association_ground_truth  1Xn
% Outputs:
%           S(t)                      4XM
%           measurement_info          1Xn
function [S, measurement_info] = particle_filter(S, v, omega, delta_t, z, association_ground_truth)

% set simulation mode
global DATA_ASSOCIATION % use association ground truth or perform ML data association
global RESAMPLE_MODE % re-sampling strategy for weighted particles

% import global variables
global landmark_ids % unique 
global t % global time

% number of measurements available
n_measurements = size(z, 2); 

% information on measurements: 0 correctly associated measurement | 1
% incorrectly associated measurement | 2 outlier
measurement_info = zeros(1, n_measurements);

% predict step including particle diffusion
[S_bar] = predict(S, v, omega, delta_t);

% check if measurements are available
if n_measurements > 0
    
    % ML data association or ground truth information
    if strcmp(DATA_ASSOCIATION, 'Off')
        [outlier, Psi, c] = associate(S_bar, z, association_ground_truth);
    else
        [outlier, Psi, c] = associate(S_bar, z);
    end

    % print number of outliers detected
    if sum(outlier)
            fprintf('warning, %d/%d measurements were labeled as outliers, t=%d\n', sum(outlier), n_measurements, t);
    end

    % store information about measurements
    for i = 1 :n_measurements
        associated_landmark = landmark_ids(mode(c(1, i, :))); % associated landmark for majority of particles
        if association_ground_truth(i) ~= associated_landmark && outlier(i) == 0
            fprintf('warning, %d th measurement(of landmark %d) was incorrectly associated to landmark %d, t=%d\n', ...
                i, association_ground_truth(i), associated_landmark, t);
            measurement_info(i) = 1; % valid measurement incorrectly associated
        elseif outlier(i) == 1
            measurement_info(i) = 2; % outlier
        end
    end
        
    % weight particles
    S_bar = weight(S_bar, Psi, outlier);
        
    % resample particles
    switch RESAMPLE_MODE
        case 0
            S = S_bar;
        case 1
            S = multinomial_resample(S_bar);
        case 2
            S = systematic_resample(S_bar);
    end
else
    % use particle set after prediction as final particle set in case
    % there's no measurements available
    S = S_bar;
    measurement_info = [];
end
end
