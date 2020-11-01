function generate_street_tracks(l, track_length, samp_per_meter, seg_min, seg_mean, seg_sigma, max_start, scen)
%l is an object of type qd_layout; this is created before this function
%call and configured with location of transmitters (gNBs) and with antenna
%types specified earlier. This function adds l.no_rx tracks to the
%qd_layout object. As currently configured, each track uses the quadriga
%"street" construct which models street sections of minimum length min_seg,
%mean segment length mean_seg and standard deviation of seg_sigma. Intial
%segment orientation is random over 2pi. Initial position is random over +-
%max_start. Each street is broken up into random segments and segments
%switch randomly between NLOS and LOS type environments (which are passed
% to this function via the set of strings "scen". Currently this feature of
% is practically disabled by making both entries of "scen" identical due to
% issues with it breaking spatial consistency
tracklen = track_length * ones(l.no_rx); % All track lengths set equally to track_length
for track = 1:l.no_rx
    l.rx_track(1, track) = qd_track('street', tracklen(track), 2*pi*rand, seg_min, seg_mean, seg_sigma); % Using the "street" construct
    l.rx_track(1, track).initial_position = [(rand - .5) * max_start; (rand - .5) * max_start; 1.0 + rand * 0.2]; % height assuming person in car
    l.rx_track(1, track).interpolate_positions(samp_per_meter); % samples per meter
    seg_vec = cumsum(randi([round(tracklen(track) / 4), round(tracklen(track) / 3)], [1, 3])); % generate segment boundaries randomly- scaling approx meters
    seg_vec = min(seg_vec, (tracklen(track) - 1)); % limiting max seg to max track length
    l.rx_track(1, track).segment_index = [1, ceil(seg_vec * samp_per_meter)]; % 4 segments starting points
    scene_sel = randi([1, 2], [1, 4]); % random numbers used to select between scenes listed in set "scen"
    l.rx_track(1, track).scenario = {scen{scene_sel(1)}, scen{scene_sel(2)}, scen{scene_sel(3)}, scen{scene_sel(4)}}; % Scenarios selected randomly
    l.rx_track(1, track).name = append('street', num2str(track)); % the track name will go from street1 to street2 to street3 etc
end
end