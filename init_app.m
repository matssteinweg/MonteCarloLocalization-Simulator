% Initialize the app upon selection of a dataset. Draw landmarks |
% Initialize parameters | Set Visualization mode
function init_app(app, root, mapfile, dataset_id)
    %% initialize parameters
    global t % global simulation time
    global M % number of particles
    t = 0;
    
    global R % covariance matrix of the motion model
    global Q % covariance matrix of the measurement model
    global lambda_psi % threshold on average likelihood for outlier detection

    % default parameters for chosen dataset for reset button in app
    global default_R 
    global default_Q 
    global default_lambda_psi % threshold on average likelihood for outlier detection
    
    % global localization or tracking problem
    global global_localization 
    
    % enable buttons, spinners and switches
    app.Spinner_R12.Enable = 'on';
    app.Spinner_R3.Enable = 'on';
    app.Spinner_Q1.Enable = 'on';
    app.Spinner_Q2.Enable = 'on';
    app.ParticlesSlider.Enable = 'on';
    app.ParticleEditField.Enable = 'on';
    app.GlobalTrackingSwitch.Enable = 'on';
    app.OutlierSwitch.Enable = 'on';
    app.OutlierSpinner.Enable = 'on';
    app.MultinomialButton.Enable = 'on';
    app.SystematicButton.Enable = 'on';
    app.OffButton.Enable = 'on';
    app.Measurement_CheckBox.Enable = 'on';
    app.GroundTruth_CheckBox.Enable = 'on';
    app.Odometry_CheckBox.Enable = 'on';
    app.DefaultButton.Enable = 'on';
    app.DataAssociationSwitch.Enable = 'on';
    app.GlobalTrackingSwitch.Enable = 'on';

    % Dataset 1
    if dataset_id == 1
        default_R = [0.01^2, 0, 0; 0, 0.01^2, 0; 0, 0, 0.01^2];
        default_Q = [0.01^2, 0; 0, 0.01^2];
        default_lambda_psi = 2;
        global_localization = 0;
        M = 1000;
    % Dataset 2
    elseif dataset_id == 2
        default_R = [0.01^2, 0, 0; 0, 0.1^2, 0; 0, 0, 0.01^2];
        default_Q = [0.1^2, 0; 0, 0.1^2];
        default_lambda_psi = 2;
        global_localization = 0;
        M = 1000;
        % Dataset 2
    elseif dataset_id == 3
        default_R = [1^2, 0, 0; 0, 1^2, 0; 0, 0, 1^2];
        default_Q = [0.1^2, 0; 0, 0.1^2];
        default_lambda_psi = 0;
        global_localization = 0;
        M = 1000;
        % Dataset 2
    elseif dataset_id == 4
        default_R = [0.1^2, 0, 0; 0, 0.1^2, 0; 0, 0, 0.1^2];
        default_Q = [0.1^2, 0; 0, 0.1^2];
        default_lambda_psi = 2;
        global_localization = 0;
        M = 1000;% Dataset 2
    elseif dataset_id == 5
        default_R = [0.1^2, 0, 0; 0, 0.1^2, 0; 0, 0, 0.1^2];
        default_Q = [0.1^2, 0; 0, 0.1^2];
        default_lambda_psi = 2;
        global_localization = 0;
        M = 1000;
    else
        disp('Dataset does not exist!')
    end
    
    % set global parameters to default values
    R = default_R;
    Q = default_Q;
    lambda_psi = default_lambda_psi;

    % display values in spinners
    app.Spinner_R12.Value = sqrt(R(1, 1));
    app.Spinner_R3.Value = round(sqrt(R(3, 3)) / (2*pi) * 360);
    app.Spinner_Q1.Value = sqrt(Q(1, 1));
    app.Spinner_Q2.Value = round(sqrt(Q(2, 2)) / (2*pi) * 360);
    
    % display number of particles
    app.ParticlesSlider.Value = M;
    app.ParticleEditField.Value = M;
    
    % set global localization switch
    if global_localization
        app.GlobalTrackingSwitch.Value = 'Global';
    else
        app.GlobalTrackingSwitch.Value = 'Tracking';
    end

    % set outlier detection switch
    if lambda_psi > 0
        % outlier detection enabled
        app.OutlierSwitch.Value = 'On';
        app.OutlierSpinner.Visible = 'on';
        app.OutlierSpinner.Value = lambda_psi;
    else
        % outlier detection disabled
        app.OutlierSwitch.Value = 'Off';
        app.OutlierSpinner.Value = lambda_psi;
    end
    
    %% initialize and draw map
    map_data = load([root mapfile]);
    global map
    global landmark_ids
    global N
    map = map_data(:,2:3)'; % map including the coordinates of all landmarks | shape 2Xn for n landmarks
    landmark_ids = map_data(:,1)'; % contains the ID of each landmark | shape 1Xn for n landmarks
    N = length(landmark_ids);
    
    % include margin around landmarks
    margin = 10;
    xmin = min(map(1, :)) - margin;
    xmax = max(map(1, :)) + margin;
    ymin = min(map(2, :)) - margin;
    ymax = max(map(2, :)) + margin;

    % draw map
    cla(app.SimulationAxis)
    plot(app.SimulationAxis, map(1, :), map(2, :), 'ko')
    hold (app.SimulationAxis, 'on');
    axis(app.SimulationAxis, [xmin xmax ymin ymax])

    %% initialize simulation mode
    global RESAMPLE_MODE % use ground-truth data instead of ML data association
    global DATA_ASSOCIATION % perform batch update instead of sequential update
    
    % set default values
    DATA_ASSOCIATION = 'On'; 
    RESAMPLE_MODE = 2;

    % update switches
    app.DataAssociationSwitch.Value = DATA_ASSOCIATION;
    if RESAMPLE_MODE == 0
        app.OffButton.Value = 1;
    elseif RESAMPLE_MODE == 1
        app.MultinomialButton.Value = 1;
    else
        app.SystematicButton.Value = 1;
    end

    %% visualization mode

    global show_measurements % display a laser beam for each measurement
    global show_ground_truth % display groud truth position
    global show_odometry % display position according to odometry information
    
    % set default values
    show_measurements = true;
    show_ground_truth = true;
    show_odometry = true;
    
    % update check boxes
    app.Measurement_CheckBox.Value = show_measurements;
    app.GroundTruth_CheckBox.Value = show_ground_truth;
    app.Odometry_CheckBox.Value = show_odometry;
end