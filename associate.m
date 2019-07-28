% This function performs the ML data association
%           S_bar(t)            4XM
%           z(t)                2Xn
%           W                   2XN
%           Lambda_psi          1X1
%           Q                   2X2
% Outputs: 
%           outlier             1Xn
%           Psi(t)              1XnXM
function [outlier, Psi, c] = associate(S_bar, z, association_ground_truth)
    if nargin < 3
        association_ground_truth = [];
    end

    global KNOWN_ASSOCIATIONS % wheter to perform data association or use ground truth
    global lambda_psi % threshold on average likelihood for outlier detection
    global Q % covariance matrix of the measurement model
    global M % number of particles
    global N % number of landmarks
    global landmark_ids % unique landmark IDs
    
    n_measurements = size(z, 2); % number of measurements

    z_hat = zeros(2, M, N); % predicted measurements
    eta = 1/(2*pi*det(Q)^0.5); % mahalanobis factor

    % get predicted measurements for all landmarks
    for j = 1:N
        z_hat(:, :, j) = measurement_model(S_bar, j);
    end
    z_hat = reshape(z_hat, [2, M*N]);
    
    % compute innovation
    nu = repmat(z, 1, M*N) - repelem(z_hat, 1, n_measurements); % nu: [2, M*N*n_m]
    nu(2, :) = mod(nu(2,:)+pi,2*pi) - pi;
    % compute likelihood
    psi = eta * exp(-0.5 * sum((nu' / Q) .* nu', 2)); % psi_tmp: [M*N*n_m,1]
    psi = permute(reshape(psi, n_measurements, M, N), [3, 1, 2]); % psi: [N,n_m,M]
    
    % get maximum likelihood and associated index
    [Psi, c] = max(psi, [], 1); % Psi: [1,n,M]
    
    % use ground truth information about correct landmark
    if KNOWN_ASSOCIATIONS
    for n = 1:n_measurements
        Psi(1, n, :) = psi(association_ground_truth(n) == landmark_ids, n, :);
    end
    end
    
    % outlier detection
    outlier = mean(reshape(Psi, [n_measurements, M]), 2) <= lambda_psi;

end