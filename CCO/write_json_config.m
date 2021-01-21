%% Write config parameters to config.json
BW = 10e6;
num_RBs = 50;

clear config;
for i=1:l.no_rx
    config.UE(i).name = append('UE_', int2str(i));
    config.UE(i).initial_position = l.rx_track(i).initial_position;
    config.UE(i).velocity = round(l.rx_track(i).positions(:, end)/total_time, 4);
    config.UE(i).end_position = round(l.rx_track(i).initial_position + l.rx_track(i).positions(:, end), 4);
    config.UE(i).initial_attachment = 1;
end


for i=1:l.no_tx
    config.BS(i).name = append('BS_', int2str(i));
    config.BS(i).location = l.tx_position(:, i);
    config.BS(i).number_of_sectors = l.tx_array(1, i).no_elements;
    if exist('orientations', 'var')
        config.BS(i).azimuth_rotations_degrees = orientations((i-1)*l.tx_array(1, i).no_elements+1:i*l.tx_array(1, i).no_elements, 2);
        config.BS(i).downtilts_degrees = orientations((i-1)*l.tx_array(1, i).no_elements+1:i*l.tx_array(1, i).no_elements, 1);
    else
        config.BS(i).azimuth_rotations_degrees = -1;
        config.BS(i).downtilts_degrees = -1;
    end
    
    if exist('Tx_P_dBm', 'var')
        config.BS(i).tx_p_dbm = Tx_P_dBm(i, :);
    else
        config.BS(i).tx_p_dbm = -1;
    end
    
    if exist('AZI_BEAMWIDTH', 'var')
    	config.BS(i).azimuth_beamwidth_degrees = AZI_BEAMWIDTH;
    else
        config.BS(i).azimuth_beamwidth_degrees = -1;
    end
    
    if exist('ELE_BEAMWIDTH', 'var')
        config.BS(i).elevation_beamwidth_degrees = ELE_BEAMWIDTH;
    else
        config.BS(i).elevation_beamwidth_degrees = -1;
    end
    
    if exist('FB_RATIO_DB', 'var')
        config.BS(i).front_to_back_ratio = FB_RATIO_DB;
    else
        config.BS(i).front_to_back_ratio = -1;
    end
end

config.simulation.carrier_frequency_hz = s.center_frequency;
config.simulation.sampling_frequency_hz = fs;
[~, samples] = size(l.rx_track(1).positions);
config.simulation.samples = samples;
config.simulation.bandwidth_Mhz = BW/1e6;
config.simulation.resource_blocks = num_RBs;
config.simulation.simulation_duration_s = samples/fs;
config.simulation.sim_num = sim_num;
config.simulation.scenario = scen;
config.simulation.seed = seed;

jsonStr = jsonencode(config);
fid = fopen(append(save_folder,'rf_config.json'), 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid, jsonStr, 'char');
fclose(fid);