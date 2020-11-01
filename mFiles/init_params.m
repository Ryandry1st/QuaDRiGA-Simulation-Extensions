python_path = '/Users/ayp/opt/anaconda3/bin/python';
fixed_cvs_file = "Mavenir_locs.csv";

process_paths = 0; % set to 1 to calculate channels along tracks
process_powermap = 1; % set to 1 to calculate map of powers
del_builder = 1; % set to 1 if you want to delete the builder file first
show_plot = 1; % set to 1 to show plots of channels
save_work = 0; % set to 1 if you want to save the workspace
save_opt = 0; % set to 1 if you want to save json and npz files for later use by optimization algs.
save_npz = 0; % set to 1 if you want to save json to npz
random_ori_azi = 0; % set to 1 if you want to randomize the azimuth angle of the BSs.

FC = 2e9;
N_SECTORS = 3;

%'sf','quick','detailed'
usage = 'detailed';

downtilt = 5; % Downtilt value, can be independently set for each sector (15 is 3GPP typical)

Tx_P_dBm = 46; %tx power in dBm

nSC = 600; %600 = 10MHz bandwidth

nGrid = (100)^2;

grid_resolution = 10; % resolution of grid in meters for power map

ue_height = 1.5;

no_BS = 4;

%hex, rnd, csv
BS_drop = "csv";

MIN_BS_SEP = 50;

MIN_HEIGHT = 25;

MAX_HEIGHT = MIN_HEIGHT;


%3GPP_38.901_RMa_LOS,WINNER_UMa_C2_LOS, TwoRayGR, 3GPP_3D_UMa_LOS,Freespace
scen = {'3GPP_3D_UMi_NLOS', '3GPP_3D_UMi_NLOS'};

% Array type at bs, main options include: omni, dipole, half-wave-dipole, patch, 3gpp-macro, 3gpp-3d (more available in generate.m)
tx_antenna_type = '3gpp-3d';

%3gpp_macro:phi_3dB, theta_3dB, rear_gain, electric_tilt
% BS height is 32m
%   An antenna with a custom gain in elevation and azimuth. See. 3GPP TR 36.814 V9.0.0 (2010-03),
%   Table A.2.1.1-2, Page 59
%      * phi_3dB - Half-Power in azimuth direction (default = 70 deg)
%      * theta_3dB - Half-Power in elevation direction (default = 10 deg)
%      * rear_gain - Front-to back ratio (default = 25 dB)
%      * electric_tilt - Electrical downtilt (default = 15 deg)
tx_antenna_3gpp_macro.phi_3dB = 70;
tx_antenna_3gpp_macro.theta_3dB = 10;
tx_antenna_3gpp_macro.rear_gain = 25;
tx_antenna_3gpp_macro.electric_tilt = 15;

%3gpp_3d:M, N, center_freq, pol, tilt, spacing
% BS height is 25m
%   The antenna model for the 3GPP-3D channel model (TR 36.873, v12.5.0, pp.17).
%      * M   - Number of vertical elements (M)
%      * N   - Number of horizontal elements (N)
%      * center_freq - The center frequency in [Hz]
%      * pol - Polarization indicator
%           1. K=1, vertical polarization only
%           2. K=1, H/V polarized elements
%           3. K=1, +/-45 degree polarized elements
%           4. K=M, vertical polarization only
%           5. K=M, H/V polarized elements
%           6. K=M, +/-45 degree polarized elements
%      * tilt - The electric downtilt angle in [deg] for pol = 4,5,6
%      * spacing - Element spacing in [λ], Default: 0.5
tx_antenna_3gpp_3d.M = 2;
tx_antenna_3gpp_3d.N = 1;
tx_antenna_3gpp_3d.center_freq = FC;
tx_antenna_3gpp_3d.pol = 4;
tx_antenna_3gpp_3d.tilt = 15;
tx_antenna_3gpp_3d.spacing = 0.5;
