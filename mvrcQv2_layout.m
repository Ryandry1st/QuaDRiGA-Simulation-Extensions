function varargout = mvrcQv2_layout(params)
%MVRCQV2_LAYOUT
% Generate the layout for a set of params. Called if no layout exists or
% saving_load_layout is 0. Returns a layout object
fprintf('[Generate layout]');

if params.sim_style == 0
    no_rx = params.no_rx;
    max_xy = params.max_xy;
else
    n_coords = ceil(sqrt(params.no_rx_min))^2;
    max_xy = floor((params.sample_distance*floor(sqrt(n_coords))-1)/2);
    x_min = -max_xy;
    x_max = -x_min;
    y_min = x_min;
    y_max = -y_min;
    x_coords = x_min:params.sample_distance:x_max;
    y_coords = y_max:-params.sample_distance:y_min;
    n_x_coords = numel(x_coords);
    n_y_coords = numel(y_coords);
    no_rx = n_coords;

    fprintf('\n\tDropping %d users in a [%d x %d](m) grid...', no_rx, max_xy, max_xy);
    [Xn, Yn] = meshgrid(x_coords, y_coords);
    rx_point = zeros(3, no_rx);
    for n = 1:no_rx
        rx_point(:, n) = [Xn(n); Yn(n); params.rx_height];
    end

    fprintf('done.\n')
end

%% Drop basestations

fprintf('\tSetting tx positions...');
orientations = [];

switch params.BS_drop

    case 'csv'
        fprintf('\tLoading CSV file...')
        % Read the csv file for BS locations and sector orientations using the python helper functions
        commandStr = sprintf('%s pyScripts/Tx_Information_from_csv.py %s', params.python_path, params.fixed_cvs_file);
        [status1, output] = system(commandStr);
        tx_locs = str2num(output);
        if (size(tx_locs) < 1)
            disp("There was a problem with your python, traceback:");
            error(output)
        end
        commandStr = sprintf('%s pyScripts/Tx_Sector_Information_from_csv.py %s', params.python_path, params.fixed_cvs_file);
        [status2, output] = system(commandStr);
        if status1 == 0 && status2 == 0
            fprintf('success.\n')
        end
        orientations = str2num(output);
        params.no_tx = size(tx_locs, 1);

    case 'rnd'
        boundary_xy = 0.7 * max_xy;
        locs_xy = zeros(params.no_tx, 2);
        locs_xy(1, :) = -boundary_xy + 2 * boundary_xy * rand(1, 2);
        counter = 1;
        while counter < params.no_tx
            candidate_point = -boundary_xy + 2 * boundary_xy * rand(1, 2);
            d = sqrt((locs_xy(1:counter, 1)-candidate_point(1)).^2+(locs_xy(1:counter, 2) - candidate_point(2)).^2);
            if d > params.isd
                counter = counter + 1;
                locs_xy(counter, :) = candidate_point;
            end
        end
        locs_z = params.tx_height_min + (params.tx_height_max - params.tx_height_min) .* rand(params.no_tx, 1);
        tx_locs = [locs_xy, locs_z];
        fprintf('done.\n');

    case 'hex'
        l_tmp = qd_layout.generate('regular', params.no_tx, params.isd);
        tx_locs = (l_tmp.tx_position).';
        locs_z = params.tx_height_min + (params.tx_height_max - params.tx_height_min) .* rand(params.no_tx, 1);
        tx_locs(:, 3) = locs_z;
        fprintf('done.\n');
    otherwise
        tx_locs = params.tx_loc;
end

    %% Generate layout object
    l = qd_layout(params.s);
    l.simpar = params.s; % Set simulation parameters
    l.name = params.scen;
    l.no_rx = no_rx;
    l.no_tx = params.no_tx;
    for i = 1:l.no_tx
        l.tx_position(:, i) = tx_locs(i, :);
    end
    fprintf('\tSetting rx positions...');
    if params.sim_style == 0
        if params.random_UEs == 0
            for i=1:l.no_rx
                t = qd_track('linear', params.distance(i), params.heading(i));  % heading north 400m
                t.initial_position(:, 1) = params.initial_loc(i, :);

                %     t.scenario{1} = scen;

                t.movement_profile = [0, params.total_time; % time points
                    0, params.distance(i)];     % distance points
                t.name = ['rx' num2str(i)];
                t.calc_orientation; % calculate receiver orientations
                [~, l.rx_track(1, i)] = interpolate(t.copy, 'time', 1/params.fs); % interpolate the track at 1/fs rate
                l.rx_track(1, i).positions = l.rx_track(1, i).positions(:, 1:end-1); % remove the last point so it is the correct number of samples
            end
        else % Generate and assign random UEs
            Add_UEs;
        end
    else
        l.rx_position = rx_point;
    end
    fprintf('done.\n');

    % tx array
    if isempty(orientations)
        ori_azi = repmat((0:floor(360 / params.no_sectors):360-floor(360 / params.no_sectors)), 1, params.no_tx).' + 30;
        ori_azi(ori_azi > 180) = ori_azi(ori_azi > 180) - 360;
        if params.random_ori_azi
            ori_azi = -180 + 360 * rand(params.no_tx*params.no_sectors, 1);
        end
        ori_dt = params.downtilt * ones(params.no_tx*params.no_sectors, 1);
        orientations = [ori_azi, ori_dt];
    end

    fprintf('\tSetting tx antenna arrays...');
    for i = 1:l.no_tx
        fprintf('%d(of %d)/',i,l.no_tx);
        index = params.no_sectors * (i - 1) + 1;
        for j = 1:params.no_sectors
            n = index + j - 1;
            theta_n = orientations(n, 2);
            switch params.tx_antenna_type
                case '3gpp-macro'
                    tx_array_cpy(j) = qd_arrayant('3gpp-macro', params.tx_antenna_3gpp_macro.phi_3dB, params.tx_antenna_3gpp_macro.theta_3dB, params.tx_antenna_3gpp_macro.rear_gain, theta_n);
                case '3gpp-3d'
                    tx_array_cpy(j) = qd_arrayant('3gpp-3d', params.tx_antenna_3gpp_3d.M, params.tx_antenna_3gpp_3d.N, params.tx_antenna_3gpp_3d.center_freq, params.tx_antenna_3gpp_3d.pol, theta_n, params.tx_antenna_3gpp_3d.spacing);
            end
        end
        tx_array_i = copy(tx_array_cpy(1));
        no_el = tx_array_i.no_elements;
        for j = 2:params.no_sectors
            phi = orientations(index+j-1, 1);
            for m = 1:no_el
                tx_array_i.copy_element(m, (j - 1)*no_el+m);
                tx_array_i.rotate_pattern(phi, 'z', (j - 1)*no_el+m);
            end
        end
        phi_1 = orientations(index, 1);
        for m = 1:no_el
            tx_array_i.rotate_pattern(phi_1, 'z', m);
        end
        l.tx_array(i) = tx_array_i;
    end
    fprintf('done.\n');

    % rx array
    l.rx_array = params.a_mt;
    fprintf('\tSetting layout scenarios for all users...');
    calc_orientation(l.rx_track);
    l.set_scenario(params.scen, [], [], params.indoor_frc, params.SC_lambda_rx, params.SC_lambda_tx);
    fprintf('done.\n');

    old_orientations = orientations;
    if params.save_layout
        fprintf('Saving layout file...')
        if ~exist([pwd, '/savedLayouts'], 'dir')
            mkdir(pwd, '/savedLayouts');
        end
        if params.sim_style
            save('savedLayouts/layout.mat', '-v7.3', 'l', 'x_min', 'x_max', 'y_min', 'y_max', 'x_coords', 'y_coords', 'n_x_coords', 'n_y_coords', 'old_orientations');
        else
            save('savedLayouts/layout.mat', '-v7.3', 'l', 'max_xy', 'old_orientations');
            fprintf('success.\n');
    end

    if nargout > 0
        varargout {1} = l; 
    end
    if nargout > 1
        varargout {2} = max_xy;
    end
    if nargout > 2
        varargout {3} = orientations;
    end
    if nargout > 3 && params.sim_style > 0
        varargout {4} = x_min; varargout {5} = x_max; varargout {6} = y_min;
        varargout {7} = y_max; varargout {8} = x_coords; varargout {9} = y_coords;
        varargout {10} = n_x_coords; varargout {11} = n_y_coords; 
    end
end
