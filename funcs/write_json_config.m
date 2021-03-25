%% Write config parameters to config.json
BW = 10e6;
num_RBs = 50;

clear config;
if params.P_turn == 0 || params.total_time == 1
    for i=1:l.no_rx
        config.UE(i).name = append('UE_', int2str(i));
        config.UE(i).initial_position = round(l.rx_track(i).initial_position, 2);
        config.UE(i).velocity = round(l.rx_track(i).positions(:, end)/params.total_time, 4);
        config.UE(i).end_position = round(l.rx_track(i).initial_position + l.rx_track(i).positions(:, end), 4);
        config.UE(i).initial_attachment = 1;
    end
    config.simulation.mobility_type='constant_velocity';
else
    load([params.save_folder_r, 'ue_mobility.mat']);
    for i=1:l.no_rx
        config.UE(i).name = append('UE_', int2str(i));
        config.UE(i).initial_attachment = 1;
        config.UE(i).turn_times = turn_times(i, :);
        config.UE(i).speed = round(speed_set(i), 2);
        config.UE(i).turn_positions = struct;
        for j=1:numel(config.UE(i).turn_times)
            config.UE(i).turn_positions.(append('t', num2str(j-1))) = round(turn_positions(i, j, :), 2);
        end
        config.UE(i).initial_attachment = 1;
%         for j=1:numel(config.UE(i).turn_times)
%             config.UE(i).turn_positions(j, :) = round(turn_positions(i, j, :), 2);
%         end
    end
    config.simulation.mobility_type='random_turns';
end
delete([params.save_folder_r, 'ue_mobility.mat']);


for i=1:l.no_tx
    config.BS(i).name = append('BS_', int2str(i));
    config.BS(i).location = round(l.tx_position(:, i), 2);
    config.BS(i).number_of_sectors = params.no_sectors;
    if isfield(params, 'orientations')
        config.BS(i).azimuth_rotations_degrees = params.orientations((i-1)*params.no_sectors+1:i*params.no_sectors, 1);
        config.BS(i).downtilts_degrees = params.orientations((i-1)*params.no_sectors+1:i*params.no_sectors, 2);
    else
        config.BS(i).azimuth_rotations_degrees = -1;
        config.BS(i).downtilts_degrees = -1;
    end
    
    if isfield(params, 'Tx_P_dBm')
        config.BS(i).tx_p_dbm = params.Tx_P_dBm(1, :);
    else
        config.BS(i).tx_p_dbm = -1;
    end
    
    switch params.tx_antenna_type
        case '3gpp-macro'
            config.BS(i).azimuth_beamwidth_degrees = params.AZI_BEAMWIDTH;
            config.BS(i).azimuth_beamwidth_degrees = params.tx_antenna_3gpp_macro.phi_3dB;
            config.BS(i).elevation_beamwidth_degrees = params.tx_antenna_3gpp_macro.theta_3dB;
            config.BS(i).front_to_back_ratio = params.tx_antenna_3gpp_macro.rear_gain;
%             tx_array_cpy(j) = qd_arrayant('3gpp-macro', params.tx_antenna_3gpp_macro.phi_3dB, params.tx_antenna_3gpp_macro.theta_3dB, params.tx_antenna_3gpp_macro.rear_gain, theta_n);
        case '3gpp-3d'
            config.BS(i).M = params.tx_antenna_3gpp_3d.M;
            config.BS(i).N = params.tx_antenna_3gpp_3d.N;
            config.BS(i).polarization = params.tx_antenna_3gpp_3d.pol;
            config.BS(i).spacing_wavelengths = params.tx_antenna_3gpp_3d.spacing;
%             tx_array_cpy(j) = qd_arrayant('3gpp-3d', params.tx_antenna_3gpp_3d.M, params.tx_antenna_3gpp_3d.N, params.tx_antenna_3gpp_3d.center_freq, params.tx_antenna_3gpp_3d.pol, theta_n, params.tx_antenna_3gpp_3d.spacing);
    end
end

config.simulation.carrier_frequency_hz = params.fc;
config.simulation.sampling_frequency_hz = params.fs;
[~, samples] = size(l.rx_track(1).positions);
config.simulation.samples = samples;
config.simulation.bandwidth_Mhz = params.BW/1e6;
config.simulation.resource_blocks = num_RBs;
config.simulation.simulation_duration_s = samples/params.fs;
config.simulation.sim_num = params.sim_num;
config.simulation.scenario = params.scen;
config.simulation.seed = params.seed;

jsonStr = jsonencode(config);
fid = fopen(append(params.save_folder_r,'rf_config.json'), 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid, jsonStr, 'char');
fclose(fid);

commandStr = sprintf('%s pyScripts/bootstrap_protocol_config.py --output_file="%sprotocol_config.json" --input_file="%s"', params.python_path, params.save_folder_r, [params.save_folder_r, 'rf_config.json']);
status = system(commandStr);

if status
   warning("Generating random protocol_config.json failed, you should check on this"); 
end