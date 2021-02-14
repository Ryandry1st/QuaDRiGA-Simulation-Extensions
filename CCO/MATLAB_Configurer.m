% MATLAB Configurer
% Create a config file for running the MRO data generation
output_file_path = '';
config = {};

config.simulation.sim_num = '0.6'; % should be a string
config.simulation.seed = 0;
config.simulation.carrier_frequency_Mhz = 2000.0;
config.simulation.sampling_frequency_hz = 1000;
config.simulation.samples = 40000;
config.simulation.bandwidth_Mhz = 10;
config.simulation.resource_blocks = 50;
config.simulation.simulation_duration_s = 40;
config.simulation.scenario = 'Freespace'; %'Freespace', '3GPP_38.901_UMa', '3GPP_3D_UMa'
config.simulation.CCO_0_MRO_1 = 0; % set to 1 for MRO
config.simulation.no_tx = 1;
config.simulation.isd = 500; % intersite distance
config.simulation.sample_distance = 20;
config.simulation.no_rx_min = 5000;
config.simulation.BS_drop = 'hex'; % Choose 'hex', 'rnd', 'csv' for built in layouts
config.simulation.batch_tilts = [2,4,6,8,10,12,14,16];
config.simulation.batch_tilts = [2];

config.simulation.parallel = 0; % Set to 1 to enable parallel operation
%config.simulation.run_i = 'hex_tx7_rx20164_3gpp3duma_seed0';
config.simulation.run_i = 'temp';

config.UE(1).name = 'UE_1';
config.UE(1).initial_position = [100, -200, 1.5];
config.UE(1).velocity = [-8.4849, 8.4849, 0];

%     config.UE(2).name = 'UE_2';
%     config.UE(2).initial_position = [600, 400, 1.5];
%     config.UE(2).velocity = [0, -24.9988, 0];


config.BS(1).name = 'BS_1';
config.BS(1).location = [-500, 500, 30];
config.BS(1).number_of_sectors = 3;
config.BS(1).azimuth_rotations_degrees = [135, -135, 0];
config.BS(1).downtilts_degrees = [5, 1, 5];
config.BS(1).tx_p_dbm = [0, 0, 0];
config.BS(1).azimuth_beamwidth_degrees = 67;
config.BS(1).elevation_beamwidth_degrees = 7.5;
config.BS(1).front_to_back_ratio = -30;

config.BS(2).name = 'BS_2';
config.BS(2).location = [900, -300, 20];
config.BS(2).number_of_sectors = 3;
config.BS(2).azimuth_rotations_degrees = [45, -45, 180];
config.BS(2).downtilts_degrees = [7, 10, 10];
config.BS(2).tx_p_dbm = [0, 0, 0];
config.BS(2).azimuth_beamwidth_degrees = 67;
config.BS(2).elevation_beamwidth_degrees = 7.5;
config.BS(2).front_to_back_ratio = -30;

config.BS(3).name = 'BS_3';
config.BS(3).location = [0, 0, 25];
config.BS(3).number_of_sectors = 3;
config.BS(3).azimuth_rotations_degrees = [0, 135, -135];
config.BS(3).downtilts_degrees = [25, 45, 45];
config.BS(3).tx_p_dbm = [0, 0, 0];
config.BS(3).azimuth_beamwidth_degrees = 67;
config.BS(3).elevation_beamwidth_degrees = 7.5;
config.BS(3).front_to_back_ratio = -30;


% error reporting
fprintf(['Preparing simulation number ', config.simulation.sim_num, '\n']);

fprintf(['...Setting path loss model to ', config.simulation.scenario, '\n'])

if numel(config.simulation.batch_tilts) == 0
    fprintf("...Using the BS tilts you defined.\n");
elseif numel(config.simulation.batch_tilts) == 1
    fprintf('...Setting all BS tilts to %i.\n', config.simulation.batch_tilts);
else
    fprintf(['...You set multiple tilts = ', num2str(config.simulation.batch_tilts), '.\n']);
end

if strcmp(config.simulation.BS_drop, 'hex') || strcmp(config.simulation.BS_drop, 'rnd') || strcmp(config.simulation.BS_drop, 'csv')
    fprintf('...Using a new BS layout for %i locations.\n', config.simulation.no_tx);
else
    fprintf('...Using the locations you defined for the BS.\n');
end

if config.simulation.CCO_0_MRO_1 == 0 && config.simulation.no_rx_min < 1000
    fprintf('...Did you mean to do CCO? You have chosen very few no_rx_min=%i.\n', config.simulation.no_rx_min);
end

jsonStr = jsonencode(config);
fid = fopen(append(output_file_path, 'config.json'), 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid, jsonStr, 'char');
fclose(fid);