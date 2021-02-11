if ismac
    python_path = '/Users/ayp/opt/anaconda3/bin/python';
    %python_path = '/Users/rmd2758/opt/anaconda3/bin/python';
elseif isunix
    python_path = '/home/user/anaconda3/bin/python';
else
    python_path = 'python';
end

process_paths = 0; % set to 1 to calculate channels along tracks
process_powermap = 1; % set to 1 to calculate map of powers
show_plot = 0; % set to 1 to show plots of channels
save_work = 0; % set to 1 if you want to save the workspace
save_opt = 0; % set to 1 if you want to save json and npz files for later use by optimization algs.
save_npz = 0; % set to 1 if you want to save json to npz
restore_config = 1;
config_file = 'config.json';

rng('default');
seed = 0;

sim_num = '0.4';
downtilt = 10; % Downtilt value, can be independently set for each sector
Tx_P = 0.1;
Tx_P_dBm = 10 * log10(Tx_P) + 30;

max_xy = 1000; % max x and y extent for power map (change to 300)
ue_height = 1.5; % height at which to create power map
no_rx = 1;

grid_resolution = 10; % resolution of grid in meters for power map

scen = '3GPP_3D_UMi'; % Temporarily fixing scenario for the whole path

ARRAY_TYPE = '3gpp-macro'; % Array type at bs, main options include: omni, dipole, half-wave-dipole, patch, 3gpp-macro, 3gpp (more available in generate.m)
AZI_BEAMWIDTH = 67; % Azimuth beamwidth for sector antenna
ELE_BEAMWIDTH = 7.5; % Elevation beamwidth for sector antenna
FB_RATIO_DB = -30; % Front to back ratio in dB
%FB_ratio = 10^(FB_RATIO_DB/10);          % Front to back ratio in linear scale
ANTENNA_ELEMENTS = 4; % Number of antenna elements in a sector
FC = 1.8e9; % Carrier frequency
N_SECTORS = 3;

ARRAY_TYPE = 'omni';
if restore_config
    [no_rx, initial_loc, heading, speed, total_time, fs, fc, no_tx, N_SECTORS, orientations, tx_pos, Tx_P_dBm, sim_num, scen, seed] = read_config(config_file);
end

rng(seed);