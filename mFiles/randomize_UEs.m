function [layout] = randomize_UEs(layout, track_info, grid)
% This function will generate UE's with random tracks that are assigned
% scenarios based on the overall LOS grid. It requires the layout, information for the
% rx track as a struct, as well as the grid information. It will return the
% layout with the rx_tracks placed within.

% Track info should have: length (to travel), street_min (minimum street distance),
% street_mu (average street distance), street_std, turn_rad (turn radius), turn_prob,
% min_start (x and y values), max_start (x and y values)

% First, generate initial directions
directions = randi([0, 7], 1, layout.no_rx) * pi / 4;

% Set the starting positions for the receivers and assign a path
for i = 1:layout.no_rx

    x_cor = randi([track_info.min_start, track_info.max_start]);
    y_cor = randi([track_info.min_start, track_info.max_start]);

    test = qd_track('street', track_info.length, directions(i), track_info.street_min, track_info.street_mu, track_info.street_std, track_info.curve_rad, track_info.turn_prob);
    test.initial_position = [x_cor; y_cor; 1.5];
    layout.rx_track(i) = test;
    layout.rx_name{i} = num2str(i);
end

segments = track_info.segments;

for i = 1:layout.no_rx
    layout.rx_track(1, i).no_segments = segments;
    for j = 1:segments
        if find_grid_region(layout.rx_track(1, i).positions(1:2, layout.rx_track(1, i).segment_index(j)), grid) % Check if a segment is in an NLOS region
            layout.rx_track(1, i).scenario{j} = 'FB_UMa_LOS';
        else
            layout.rx_track(1, i).scenario{j} = 'FB_UMa_NLOS';
        end
    end
end


end
