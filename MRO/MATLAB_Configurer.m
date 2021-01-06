% MATLAB Configurer
% Create a config file for running the MRO data generation
output_file_path = '';
config = {};

    config.sim_num = 0.5;
    config.no_UE = 1;
    
    config.UE_1_initial_position = [100, -200, 1.5];
    config.UE_1_velocity = [-8.4849, 8.4849, 0];
    config.UE_1_end_position = [-239.3943, 139.3943, 1.5];
    
    config.UE_2_initial_position = [600, 400, 1.5];
    config.UE_2_velocity = [0, -24.9988, 0];
    config.UE_2_end_position = [600, -599.95, 1.5];
    
    config.no_BS = 1;
    
    config.BS_1_location = [-500, 500, 30];
    config.BS_1_number_of_sectors = 3;
    config.BS_1_azimuth_rotations_degrees = [135, -135, 0];
    config.BS_1_downtilts_degrees = [5, 1, 5];
    config.BS_1_Tx_P_dBm = [20, 20, 20];                 
    config.BS_1_azimuth_beamwidth_degrees = 67;
    config.BS_1_elevation_beamwidth_degrees = 7.5;
    config.BS_1_front_to_back_ratio = -30;
    
    config.BS_2_location = [900, -300, 20];
    config.BS_2_number_of_sectors = 3;
    config.BS_2_azimuth_rotations_degrees = [45, -45, 180];
    config.BS_2_downtilts_degrees = [7, 10, 10];
    config.BS_2_Tx_P_dBm = [20, 20, 20];
    config.BS_2_azimuth_beamwidth_degrees = 67;
    config.BS_2_elevation_beamwidth_degrees = 7.5;
    config.BS_2_front_to_back_ratio = -30;
    
    config.BS_3_location = [0, 0, 25];
    config.BS_3_number_of_sectors = 3;
    config.BS_3_azimuth_rotations_degrees = [0, 135, -135];
    config.BS_3_downtilts_degrees = [25, 45, 45];
    config.BS_3_Tx_P_dBm = [20, 20, 20];
    config.BS_3_azimuth_beamwidth_degrees = 67;
    config.BS_3_elevation_beamwidth_degrees = 7.5;
    config.BS_3_front_to_back_ratio = -30;

    
    config.Carrier_Frequency_Hz = 28000000000.0;
    config.Sampling_Frequency_Hz = 1000;
    config.Samples = 40000;
    config.Bandwidth_MHz = 10;
    config.Resource_Blocks = 50;
    config.Simulation_Duration_s = 40;


jsonStr = jsonencode(config);
fid = fopen(append(output_file_path,'config.json'), 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid, jsonStr, 'char');
fclose(fid);