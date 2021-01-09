% MATLAB Configurer
% Create a config file for running the MRO data generation
output_file_path = '';
config = {};
    
    config.UE(1).name = 'UE_1';
    config.UE(1).initial_position = [100, -200, 1.5];
    config.UE(1).velocity = [-8.4849, 8.4849, 0];
    
    config.UE(2).name = 'UE_2';
    config.UE(2).initial_position = [600, 400, 1.5];
    config.UE(2).velocity = [0, -24.9988, 0];
    
    
    config.BS(1).name = 'BS_1';
    config.BS(1).location = [-500, 500, 30];
    config.BS(1).number_of_sectors = 3;
    config.BS(1).azimuth_rotations_degrees = [135, -135, 0];
    config.BS(1).downtilts_degrees = [5, 1, 5];
    config.BS(1).tx_p_dbm = [20, 20, 20];                 
    config.BS(1).azimuth_beamwidth_degrees = 67;
    config.BS(1).elevation_beamwidth_degrees = 7.5;
    config.BS(1).front_to_back_ratio = -30;
    
    config.BS(2).name = 'BS_2';
    config.BS(2).location = [900, -300, 20];
    config.BS(2).number_of_sectors = 3;
    config.BS(2).azimuth_rotations_degrees = [45, -45, 180];
    config.BS(2).downtilts_degrees = [7, 10, 10];
    config.BS(2).tx_p_dbm = [20, 20, 20];
    config.BS(2).azimuth_beamwidth_degrees = 67;
    config.BS(2).elevation_beamwidth_degrees = 7.5;
    config.BS(2).front_to_back_ratio = -30;
    
    config.BS(3).name = 'BS_3';
    config.BS(3).location = [0, 0, 25];
    config.BS(3).number_of_sectors = 3;
    config.BS(3).azimuth_rotations_degrees = [0, 135, -135];
    config.BS(3).downtilts_degrees = [25, 45, 45];
    config.BS(3).tx_p_dbm = [20, 20, 20];
    config.BS(3).azimuth_beamwidth_degrees = 67;
    config.BS(3).elevation_beamwidth_degrees = 7.5;
    config.BS(3).front_to_back_ratio = -30;

    
    config.simulation.sim_num = '0.6'; % should be a string
    config.simulation.seed = 0;
    config.simulation.carrier_frequency_hz = 28000000000.0;
    config.simulation.sampling_frequency_hz = 1000;
    config.simulation.samples = 40000;
    config.simulation.bandwidth_Mhz = 10;
    config.simulation.resource_blocks = 50;
    config.simulation.simulation_duration_s = 40;
    config.simulation.scenario = 'Freespace';


jsonStr = jsonencode(config);
fid = fopen(append(output_file_path,'config.json'), 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid, jsonStr, 'char');
fclose(fid);