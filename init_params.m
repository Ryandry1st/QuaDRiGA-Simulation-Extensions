rng('default');
rng(0);

python_path = '/Users/ayp/opt/anaconda3/bin/python';
fixed_cvs_file = "Mavenir_locs.csv";

process_paths = 0;                                      % set to 1 to calculate channels along tracks
process_powermap = 1;                                   % set to 1 to calculate map of powers
del_builder = 1;                                        % set to 1 if you want to delete the builder file first
show_plot = 1;                                          % set to 1 to show plots of channels
save_work = 0;                                          % set to 1 if you want to save the workspace
save_opt = 0;                                           % set to 1 if you want to save json and npz files for later use by optimization algs.
save_npz = 0;                                           % set to 1 if you want to save json to npz

%'sf','quick','detailed'
usage = 'sf';
downtilt = 0;                                           % Downtilt value, can be independently set for each sector (15 is 3GPP typical)
Tx_P_dBm = 46;                                          %tx power in dBm

nGrid = (250)^2;
grid_resolution = 20;                                   % resolution of grid in meters for power map

ue_height = 1.5; 

no_BS = 10;
% Many-BS parameters
BS_drop = "random_constrained";                             % random_constrained,random_unconstrained,random_grid,fixed_cvs_file

MIN_BS_SEP = 200;
MIN_HEIGHT = 35;
MAX_HEIGHT = 35;
MIN_DT = 0;
MAX_DT = 20;
BS_LOC_VAR = 100;
OFFSET = [100, 100];

%3GPP_38.901_RMa_LOS,WINNER_UMa_C2_LOS, TwoRayGR, 3GPP_3D_UMa_LOS
scen = {'3GPP_38.901_RMa_LOS','3GPP_38.901_RMa_LOS'};                       % Temporarily fixing scenario for the whole path

ARRAY_TYPE = '3gpp-mmw';                % Array type at bs, main options include: omni, dipole, half-wave-dipole, patch, 3gpp-macro, 3gpp (more available in generate.m)
AZI_BEAMWIDTH = 65;                       % Azimuth beamwidth for sector antenna
ELE_BEAMWIDTH = 65;                      % Elevation beamwidth for sector antenna
FB_RATIO_DB = -25;                        % Front to back ratio in dB
ANTENNA_ELEMENTS = 4;                     % Number of antenna elements in a sector
FC = 1.8e9;                               % Carrier frequency
N_SECTORS = 3;

%3D channel model params:
M = 4;
N = 1;
pol = 6;
Mg = 1;
Ng = 1;
spacing = 0.5;
