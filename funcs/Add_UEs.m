% Add UEs based on initial location and velocity information
% Assumes:
% UE travel along linear tracks for dedicated lengths
% All UE are 1.5m tall and do not change height

l.no_rx = params.no_rx;
[assignments, edges] = discretize(1:l.no_rx, l.no_tx);
per_BS_UE = histcounts(assignments);

% Overwrite to place all UE in center point
% per_BS_UE = zeros(size(per_BS_UE));
% per_BS_UE(1) = l.no_rx;

rng(params.ue_seed);

turn_positions = zeros(l.no_rx, params.total_time, 3);
turn_times = zeros(l.no_rx, params.total_time);
counter = 0;
speed_set = [];
for k=1:l.no_tx
    [locs, vels, speeds, no_segments, t_unit, turns] = RandomizeUE(per_BS_UE(k), params.P_local, params.local_radius, params.total_time, l.tx_track(k).initial_position(1), l.tx_track(k).initial_position(2), max_xy, params.P_turn);
    speed_set = [speed_set; speeds];
    for i=1:per_BS_UE(k)
        counter = counter + 1;
        t = qd_track('linear', t_unit*speeds(i), atan2(vels(i, 2, 1), vels(i, 1, 1)));
        t.initial_position = locs(i, :)'; 
        turn_positions(counter, 1, :) = locs(i, :)';
        
        if k>1
            t.name = ['Rx',sprintf('%06.0f',i + sum(per_BS_UE(1:k-1)))];
        else
            t.name = ['Rx',sprintf('%06.0f',i)];
        end

        t.movement_profile = [0, t_unit; 0, speeds(i)*t_unit];
        [~, t] = interpolate(t.copy, 'time', 1/params.fs);
        
        if no_segments > 1
            turn_positions(counter, 2, :) = t.positions(:, end)+locs(i, :)';
            turn_times(counter, 2) = t_unit;
        end

        for j=2:no_segments
            tmp = qd_track('linear', t_unit*speeds(i), atan2(vels(i, 2, j), vels(i, 1, j)));
%             tmp.set_speed(speeds(i));
            tmp.movement_profile = [0, t_unit; 0, speeds(i)*t_unit];
            tmp.interpolate('time', 1/params.fs);

            t.positions = [t.positions,...
                [t.positions(1, end) + tmp.positions(1, 2:end);
                 t.positions(2, end) + tmp.positions(2, 2:end);
                 1.5*ones(1, numel(tmp.positions(1, 2:end)))]];
            % only add the next position turn if there is a subsequent
            % point

            turn_positions(counter, j+1, :) = t.positions(:, end)+locs(i, :)';
            turn_times(counter, j+1) = t_unit*j;


        end
        if k>1
            l.rx_track(i + sum(per_BS_UE(1:k-1))) = t.copy();
            l.rx_track(i + sum(per_BS_UE(1:k-1))).positions = l.rx_track(i + sum(per_BS_UE(1:k-1))).positions(:, 1:end-1); % remove last unnecessary point
        else
            l.rx_track(i) = t.copy();
            l.rx_track(i).positions = l.rx_track(i).positions(:, 1:end-1); % remove last unnecessary point
        end
    end
end

rng(params.seed);
save(append(params.save_folder_r,'ue_mobility.mat'), 'turn_times', 'turn_positions', 'speed_set');
% l.visualize;
