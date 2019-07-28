% Run Simulation of a MCL localization for landmark based maps and range
% measurements.
function run_simulation(app, root, simulationfile)
    %% Initialize simulation data
    % store simulation data in cell array
    fid = fopen([root simulationfile], 'r');
    if fid <= 0
      fprintf('Failed to open simoutput file "%s"\n\n', simulationfile);
      return
    end
    simulation_data = {};
    while 1
        line = fgetl(fid);
        if ~ischar(line)
            break
        end
        simulation_data = [simulation_data(:)' {line}];
    end
    fclose(fid);

    %% Initialize particles
    global global_localization % global localization or tracking problem
    global M % number of particles
    global map % landmark coordinates
    global start_pose  % start pose in case of tracking problem
    
    if global_localization
        particle_margin = 10; % spread of particles accross borders of the map in m
        
        % randomly initialized particles
        S = [rand(1, M) * (max(map(1, :)) - min(map(1, :)) + 2*particle_margin) + min(map(1, :)) - particle_margin;
             rand(1, M) * (max(map(2, :)) - min(map(2, :)) + 2*particle_margin) + min(map(2, :)) - particle_margin;
             rand(1, M) * 2*pi - pi;
             1 / M * ones(1, M)];
    else
        % tracking problem with initial estimate
        initial_data = sscanf(simulation_data{1}, '%f');
        start_pose = initial_data(7:9);
        S = [repmat(start_pose, 1, M); 
             1 / M * ones(1, M)];        
    end
    
    %% Initialize parameters and data structures
    % initial wheel-encoder readings
    enc = [0; 0]; 

    % number of timesteps in simulation data
    n_timesteps = size(simulation_data, 2);
    
    % import global variables
    global t % global time
    global show_measurements % visualization mode
    global show_ground_truth % visualization mode
    global show_odometry % visualization mode
    global stop_execution % stop execution flag set by app
    stop_execution = 0;
    
    % save simulation statistics
    pose_errors = zeros(3, n_timesteps);
    odom_plots = gobjects(1 , n_timesteps);
    ground_truth_plots = gobjects(1 , n_timesteps);
    short_term_plots = [];
    particle_plot = [];
    total_measurements = 0; % total number of measurements in simulation
    total_outliers = 0; % total number of detected outliers
    total_misassociations = 0; % total number of incorrectly associated measurements

    %% Run simulation
    for timestep = 1:n_timesteps

        % read data for current timestep
        line = simulation_data{timestep};
        timestep_data = sscanf(line, '%f');

        % save values from previous timestep
        pt = t; % previous time in seconds
        penc = enc; % wheel-encoder information of previous timestep

        % get information from simulationfile
        t = timestep_data(1); % current time in seconds
        odom = timestep_data(2:4); % odometry information
        enc = timestep_data(5:6); % wheel-encoder information
        true_pose = timestep_data(7:9); % ground-truth pose  
        n_measurements = timestep_data(10); % number of observations available
        if (n_measurements > 0) % if observations for current timestep available
            bearings = timestep_data(12:3:end); % bearing of observation
            ranges = timestep_data(13:3:end); % distance to observed landmark
            z = [ranges'; bearings']; % measurements
            association_ground_truth = timestep_data(11:3:end);  % id of observed landmark
        else
            bearings = [];
            ranges = [];
            z = [ranges';bearings'];
            association_ground_truth = [];
        end

        % relative information to last timestep
        delta_t = t - pt; % time difference
        delta_enc = enc - penc; % wheel-encoder difference

        % compute odometry information
        u = calculate_odometry(delta_enc(1), delta_enc(2), delta_t, S);

        % run Particle Filter
        [S, measurement_info] = particle_filter(S, u, z, association_ground_truth);
        
        % get measurement statistics from Particle Filter
        outliers = length(find(measurement_info == 2));
        misassociations = length(find(measurement_info == 1));
        total_outliers = total_outliers + outliers;
        total_measurements = total_measurements + n_measurements;
        total_misassociations = total_misassociations + misassociations;
        
        % get pose estimate
        mu = mean(S(1:3,:), 2);
        pos_sigma = cov(S(1,:),S(2,:));
        var_theta = var(S(3,:));
        sigma = zeros(3,3);
        sigma(1:2, 1:2) = pos_sigma;
        sigma(3, 3) = var_theta;

        % compute pose error
        pose_error = true_pose - mu;
        pose_error(3) = mod(pose_error(3)+pi,2*pi)-pi;
        pose_errors(:, timestep) = pose_error;

        %% Plot Simulation
        
        % display simulation time
        title(app.SimulationAxis, sprintf('Simulation Time: %.1f s', round(t, 1)));

        % delete short-term-plots
        for k = 1:length(short_term_plots)
            delete(short_term_plots(k))
        end

        short_term_plots = gobjects(1, 2*n_measurements);
        % Measurements are displayed from the ground truth object due to
        % inaccurate state estimate in case of several hypotheses.
        % A measurement is considered incorrectly associated if the most
        % frequent association among all particles is incorrect.
        if show_measurements
            % plot measurements
            plot_colors = ['g', 'r', 'y']; % correctly associated measurements: green | incorrectly associated measurements: red | outliers: yellow
            for i = 1:n_measurements
                plot_color = plot_colors(measurement_info(i)+1);
                measurement_endpoint = true_pose(1:2) +[ranges(i)*cos(true_pose(3)+bearings(i));ranges(i)*sin(true_pose(3)+bearings(i))];
                short_term_plots(i) = plot(app.SimulationAxis, measurement_endpoint(1), measurement_endpoint(2), strcat(plot_color,'.'));
                % laser beam plots
                short_term_plots(n_measurements+i) = plot(app.SimulationAxis, true_pose(1)+[0 ranges(i)*cos(true_pose(3)+bearings(i))], ...
                                    true_pose(2)+[0 ranges(i)*sin(true_pose(3)+bearings(i))], plot_color);
            end
        end

        % plot robot location: odometry information blue | particles green |
        % ground truth black
        if show_ground_truth
            odom_plots(timestep) = plot(app.SimulationAxis, true_pose(1), true_pose(2), 'kx');
        else
            for k = 1:length(odom_plots)
            delete(odom_plots(k))
            end
        end
        if show_odometry
            ground_truth_plots(timestep) = plot(app.SimulationAxis, odom(1), odom(2), 'bx');
        else
            for k = 1:length(ground_truth_plots)
            delete(ground_truth_plots(k))
            end
        end
        
        % plot particles
        delete(particle_plot);
        particle_plot = scatter(app.SimulationAxis, S(1, :), S(2, :), 3, 'filled', 'g');
        
        % plot uncertainty ellipse around predicted location
        uncertainty_ellipse = get_uncertainty_ellipse(mu, sigma);
        
        % update fields for estimated pose and error
        app.xField.Value = mu(1);
        app.yField.Value = mu(2);
        app.thetaField.Value = round(mu(3) / (2*pi) * 360);
        app.xField_2.Value = pose_error(1);
        app.yField_2.Value = pose_error(2);
        app.thetaField_2.Value = round(pose_error(3) / (2*pi) * 360);
        
        % close-up plot
        cla(app.CloseUpAxis)
        % plot ellipse
        plot(app.CloseUpAxis, uncertainty_ellipse(1,:), uncertainty_ellipse(2,:), 'g', 'LineWidth', 3);
        % plot particles
        particle_plot_close = scatter(app.CloseUpAxis, S(1, :), S(2, :), 3, 'filled', 'g');
        alpha(particle_plot_close, 0.1);
        hold (app.CloseUpAxis, 'on');
        x = true_pose(1); % ground truth position x
        y = true_pose(2); % ground truth position y
        axis(app.CloseUpAxis, [x-0.5 x+0.5 y-0.5 y+0.5]) % display 0.5m in both directions around ground truth
        % plot ground truth
        plot(app.CloseUpAxis, x, y, 'kx', 'MarkerSize', 20);
        % set ticks
        xticks(app.CloseUpAxis, [x-0.5, x-0.25, x, x+0.25, x+0.5]);
        xticklabels(app.CloseUpAxis, [-0.5, -0.25, 0, 0.25, 0.5])
        yticks(app.CloseUpAxis, [y-0.25, y, y+0.25, y+0.5]);
        yticklabels(app.CloseUpAxis, [-0.25, 0, 0.25, 0.5])
        
        % display measurement statistics
        app.MeasurementField.Value = total_measurements;
        app.IncorrectField.Value = total_misassociations;
        app.OutlierField.Value = total_outliers;

        % pause
        pause(0.2);
        
        % stop execution flag set in app -> stop simulation
        if stop_execution
            break;
        end

    end
    
    if stop_execution == 0
        % get error statistics
        maex = mean(abs(pose_errors(1,:)));
        maey = mean(abs(pose_errors(2,:)));
        maet = mean(abs(pose_errors(3,:)));

        % update fields
        app.ErrorLabel.Text = 'Mean Absolute Error';
        app.xField_2.Value = maex;
        app.yField_2.Value = maey;
        app.thetaField_2.Value = round(maet / (2*pi) * 360);

        % change stop button in app
        app.StopButton.Text = 'End';
        app.PauseButton.Enable = 'off';
        app.DropDown.Enable = 'off';
    end
end
