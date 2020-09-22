% Simple UE
% generates a single UE with a simple route through a simulation
close all;
clear all;
tic;

%% File path information
% save_folder = ['Output_files\',datestr(now,'mm-dd-HH-MM'),'\'];
sim_num = 0;
save_folder = ['Output_files\Scenario ', num2str(sim_num), '\'];
mkdir(save_folder);

%% Simulation Choices
speed = 10;
initial_loc = [-100, -100, 1.5];
distance = 400;
heading = pi/2;
fs = 1000;                               % 1ms sampling time
samples_per_meter = fs/speed; 

%% General setup
s = qd_simulation_parameters;             % New simulation parameters
s.center_frequency = 1.8e9;               % 1.8 GHz carrier frequency middle of lte band 3
s.sample_density = 1;                     % num samples per half-wavelength
s.use_absolute_delays = 1;                % Include delay of the LOS path
s.show_progress_bars = 1;                 % Enable progress bars; set to 0 to disable progress bars
s.use_3GPP_baseline = 0;
s.samples_per_meter = samples_per_meter;
s.sample_density = samples_per_meter*3e8/2/s.center_frequency;
scen = 'FB_UMa_NLOS';


%% Chose BS layout
l = qd_layout(s);
l.no_tx = 2;
l.tx_position(:, 1) = [0, 0, 25]';
l.tx_position(:, 2) = [-200, 100, 20]';
l.tx_array(1) = qd_arrayant('dipole');
l.tx_array(2) = qd_arrayant('dipole');
N_SECTORS = 1;

%% Setup UE
l.no_rx = 1;
l.rx_array = qd_arrayant('dipole');

%% UE path
t = qd_track('linear', distance, heading);  % heading north 400m
t.initial_position(:, 1) = initial_loc;
                    
t.scenario{1} = scen;

t.movement_profile = [0, distance/speed; % time points
                        0, distance];     % distance points

t.calc_orientation; % calculate receiver orientations
[~, l.rx_track] = interpolate(t.copy, 'time', 1/fs); % interpolate the track at 1/fs rate
l.rx_track.positions = l.rx_track.positions(:, 1:end-1); % remove the last point so it is the correct number of samples

%% Process Path
calc_orientation(l.rx_track)
p = l.init_builder;                                       % Create channel builders
gen_parameters( p );                                      % Generate small-scale fading
c = get_channels( p );                                    % Generate channel coefficients
cn = merge( c );

total_time = toc;
l.visualize([],[],0);                                     % Show BS and MT positions on the map

%% Outputs
% First we want to output the data like the fading_trace_generator file
% then we want to output some sort of configuration file
% And finally a .mat file of anything useful like p and cn
Write_Spectral_Tracks;
saveas(gcf, strcat(save_folder, 'Layout.png'))
gen_config;
% save(strcat(save_folder, 'workspace.mat'), '-v7.3', 'p', 'cn');
% config file should have tx locations, rx start, heading, speed, end, the
% antenna descriptions, and scenario.