%% Write config parameters to config.json
BW = 10e6;
num_RBs = 50;

config.no_UE = l.no_rx;
for i=1:l.no_rx
    config.(append('UE_', int2str(i), '_initial_position')) = l.rx_track(i).initial_position;
    config.(append('UE_', int2str(i), '_velocity')) = round(l.rx_track(i).positions(:, end)/total_time, 4);
    config.(append('UE_', int2str(i), '_end_position')) = round(l.rx_track(i).initial_position + l.rx_track(i).positions(:, end), 4);
    config.(append('UE_', int2str(i), '_initial_attachment')) = 1;
end

config.no_BS = l.no_tx;
for i=1:l.no_tx
    config.(append('BS_', int2str(i), '_location')) = l.tx_position(:, i);
    config.(append('BS_', int2str(i), '_number_of_sectors')) = l.tx_array(1, i).no_elements;
    if exist('orientations', 'var')
        config.(append('BS_', int2str(i), '_azimuth_rotations_degrees')) = orientations((i-1)*l.tx_array(1, i).no_elements+1:i*N_SECTORS, 2);
        config.(append('BS_', int2str(i), '_downtilts_degrees')) = orientations((i-1)*l.tx_array(1, i).no_elements+1:i*l.tx_array(1, i).no_elements, 1);
    else
        config.(append('BS_', int2str(i), '_azimuth_rotations_degrees')) = -1;
        config.(append('BS_', int2str(i), '_downtilts_degrees')) = -1;
    end
    
    if exist('Tx_P_dBm', 'var')
        config.(append('BS_', int2str(i), '_Tx_P_dBm')) = Tx_P_dBm(i, :);
    else
        config.(append('BS_', int2str(i), '_Tx_P_dBm')) = -1;
    end
    
    if exist('AZI_BEAMWIDTH', 'var')
    	config.(append('BS_', int2str(i), '_azimuth_beamwidth_degrees')) = AZI_BEAMWIDTH;
    else
        config.(append('BS_', int2str(i), '_azimuth_beamwidth_degrees')) = -1;
    end
    
    if exist('ELE_BEAMWIDTH', 'var')
        config.(append('BS_', int2str(i), '_elevation_beamwidth_degrees')) = ELE_BEAMWIDTH;
    else
        config.(append('BS_', int2str(i), '_elevation_beamwidth_degrees')) = -1;
    end
    
    if exist('FB_RATIO_DB', 'var')
        config.(append('BS_', int2str(i), '_front_to_back_ratio')) = FB_RATIO_DB;
    else
        config.(append('BS_', int2str(i), '_front_to_back_ratio')) = -1;
    end
end

config.Carrier_Frequency_Hz = s.center_frequency;
config.Sampling_Frequency_Hz = fs;
[~, samples] = size(l.rx_track(1).positions);
config.Samples = samples;
config.Bandwidth_MHz = BW/1e6;
config.Resource_Blocks = num_RBs;
config.Simulation_Duration_s = samples/fs;
config.sim_num = sim_num;
config.Scenario = scen;

jsonStr = jsonencode(config);
fid = fopen(append(save_folder,'config.json'), 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid, jsonStr, 'char');
fclose(fid);