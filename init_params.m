python_path = '/Users/ayp/opt/anaconda3/bin/python';

process_paths = 0;                                      % set to 1 to calculate channels along tracks
process_powermap = 1;                                   % set to 1 to calculate map of powers
show_plot = 0;                                          % set to 1 to show plots of channels
save_work = 0;                                          % set to 1 if you want to save the workspace
save_opt = 1;                                           % set to 1 if you want to save json and npz files for later use by optimization algs.
save_npz = 0;                                           % set to 1 if you want to save json to npz

downtilt = 21;                                           % Downtilt value, can be independently set for each sector
TX_P = 40;

max_xy = 600;                                            % max x and y extent for power map (change to 300)
ue_height = 1.5;                                        % height at which to create power map

grid_resolution = 10;                                    % resolution of grid in meters for power map

scen = {'Freespace','Freespace'};                      % Temporarily fixing scenario for the whole path

ARRAY_TYPE = '3gpp-macro';                % Array type at bs, main options include: omni, dipole, half-wave-dipole, patch, 3gpp-macro, 3gpp (more available in generate.m)
AZI_BEAMWIDTH = 67;                       % Azimuth beamwidth for sector antenna
ELE_BEAMWIDTH = 7.5;                      % Elevation beamwidth for sector antenna
FB_RATIO_DB = -30;                        % Front to back ratio in dB
%FB_ratio = 10^(FB_RATIO_DB/10);          % Front to back ratio in linear scale
ANTENNA_ELEMENTS = 4;                     % Number of antenna elements in a sector
FC = 1.8e9;                               % Carrier frequency
N_SECTORS = 3;
