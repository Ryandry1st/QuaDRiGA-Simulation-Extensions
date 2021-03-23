function params = mvrcQv2_init(config_file)

if ~exist('config_file', 'var')
    config_file = 'quadriga_config.json';
else
    if isempty(config_file)
        config_file = 'quadriga_config.json';
    end
end

addpath(genpath([pwd, '/funcs']));
addpath(genpath([pwd, '/QuaDriGa_2020.11.03_v2.4.0']));
% addpath(genpath([pwd, '/MVRCfuncs']));


if ismac
    python_path = '/Users/ayp/opt/anaconda3/bin/python';
    %python_path = '/Users/rmd2758/opt/anaconda3/bin/python';
elseif isunix
    python_path = '/home/user/anaconda3/bin/python';
else
    python_path = 'python';
end

fixed_cvs_file = "csvData/Mavenir_locs.csv";

%% QuaDRiGa Setup

s = qd_simulation_parameters; % Set general simulation parameters
s.center_frequency = 2e9; % 2 GHz center frequency
s.sample_density = 1;
s.use_3GPP_baseline = 0; % Disable spherical waves
s.show_progress_bars = 1; % Enable / disable status display
s.use_absolute_delays = 0;

% flags
save_results = 1;
save_layout = 1;
save_load_channels = 0;
random_ori_azi = 0;
clean_code = 0;
run_i = 'hex_tx7_rx20164_3gpp3duma_seed0';

% layout
no_rx_min = 5000;
max_xy = 500;
no_tx = 10;
sample_distance = 10;
BS_drop = "rnd"; %hex, rnd, csv
downtilt = 20; % only used if orientations = []
isd = 500;
tx_pwr_dBm = 46; %average tx power (total over all antenna and all freq)
nSC = 600;
rx_height = 1.5;
tx_height = 25;
no_sectors = 3;
tx_height_min = tx_height;
tx_height_max = tx_height;

SC_lambda_rx = 20;
SC_lambda_tx = [];
indoor_frc = 0;
scen = 'Freespace';
%      * Freespace
%      * 3GPP_3D_UMi
%      * 3GPP_38.901_UMi Example: [Tx height:25m, Rx height: 1.5-2.5 m, ISD: 200m]
%      * 3GPP_38.901_UMa Example: [Tx height:25m, Rx height: 1.5-2.5 m, ISD: 500m]
%      * 3GPP_38.901_RMa Example: [Tx height:35m, Rx height: 1.5-2.5 m, ISD: 5000m]
%      * 3GPP_38.901_Indoor_Mixed_Office
%      * 3GPP_38.901_Indoor_Open_Office
%      * 3GPP_38.901_InF_SL
%      * 3GPP_38.901_InF_DL
%      * 3GPP_38.901_InF_SH
%      * 3GPP_38.901_InF_DH

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
tx_array_3gpp_macro = qd_arrayant('3gpp-macro', tx_antenna_3gpp_macro.phi_3dB, tx_antenna_3gpp_macro.theta_3dB, tx_antenna_3gpp_macro.rear_gain, tx_antenna_3gpp_macro.electric_tilt);
tx_array_3gpp_macro.element_position(1, :) = 0; % Distance from pole
tx_array_3gpp_macro.name = '3gpp-macro';

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

tx_antenna_3gpp_3d.M = 8;
tx_antenna_3gpp_3d.N = 1;
tx_antenna_3gpp_3d.center_freq = s.center_frequency;
tx_antenna_3gpp_3d.pol = 4;
tx_antenna_3gpp_3d.tilt = 0;
tx_antenna_3gpp_3d.spacing = 0.5;

% BS antenna configuration
tx_array_3gpp_3d = qd_arrayant('3gpp-3d', tx_antenna_3gpp_3d.M, tx_antenna_3gpp_3d.N, tx_antenna_3gpp_3d.center_freq, tx_antenna_3gpp_3d.pol, downtilt, tx_antenna_3gpp_3d.spacing);
tx_array_3gpp_3d.element_position(1, :) = 0; % Distance from pole
tx_array_3gpp_3d.name = '3gpp-3d';

% MT antenna configuration
a_mt = qd_arrayant('omni');
%a_mt.copy_element(1, 2);
%a_mt.element_position(2, :) = [-s.wavelength / 2, s.wavelength / 2] * 0.5;
a_mt.center_frequency = s.center_frequency;

read_config();

celledge_angle = atand(tx_height/(max_xy/2));
% put everything in a struct for later use
w = whos;
params = struct();
for a = 1:length(w)
    params.(w(a).name) = eval(w(a).name);
end
s.center_frequency = fc;

return
