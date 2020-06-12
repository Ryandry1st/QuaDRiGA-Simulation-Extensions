%% directives to the simulator
process_paths =1;                                       % set to 1 to calculate channels along tracks
process_powermap=0;                                     % set to 1 to calculate map of powers
show_plot = 1;                                          % set to 1 to show plots of channels
track_directory = '/Users/skasturia/Dropbox (Facebook)/tracks/'; % directory where channels along track are written out; customize to your run
save_work = 1;                                          % set to 1 if you want to save the workspace
fprintf('Simulation starting,with process_paths = %d, process_powermap = %d, show_plot = %d and save_work = %d \n',process_paths,process_powermap,show_plot,save_work)
fprintf('Results will be written to %s; abort if directory does not exist \n',track_directory)
%% simulation parameters
s = qd_simulation_parameters;                           % New simulation parameters
s.center_frequency = 2.53e9;                            % 2.53 GHz carrier frequency
s.sample_density = 1;                                   % num samples per half-wavelength
s.use_absolute_delays = 1;                              % Include delay of the LOS path
s.show_progress_bars = 1;                               % Enable progress bars; set to 0 to disable progress bars
fprintf('Center freq: %5.2f GHz, Sample spacing(m): %4.3f \n',s.center_frequency/1e9, 3e8/(s.center_frequency*s.sample_density*2))
%% Layout of transmitters & specification of antenna types
% We create a more complex network layout featuring an elevated transmitter
% (25 m) and a programmable number of UEs and each goes through paths where the scenario changes between LOS 
% and NLOS segments. The LOS-LOS change will create new small-scale fading parameters, but the
% large scale parameters (LSPs) will be highly correlated between those two segments.
l = qd_layout(s);                                          % Create new QuaDRiGa layout
l.no_tx = 4;                                               % One primary and three interfering base stations
num_interf = l.no_tx - 1;                                  % number of interfering bases stations
l.tx_array = qd_arrayant('dipole');                        % Dipole antennas at Tx
% l.tx_array = qd_arrayant('3gpp-3d',2,4,s.center_frequency,3);  % 2 vertical 4 horizontal, +-45 pol
l.tx_position(:,1) = [0; 0; 25];                           % Primary base station at 0,0,25
l.tx_position(:,2) = [0; -600; 25];                        % Interfering base station at 0,0,25
l.tx_position(:,3) = [-300; 520; 25];                      % Interfering base station at 0,0,25
l.tx_position(:,4) = [300; 520; 25];                       % Interfering base station at 0,0,25
%% number of receiver & specification of antenna type; length and resolution of UE track
l.no_rx = 100;                                              % Number of UEs and tracks - one track per UE
l.rx_array = qd_arrayant('dipole');                        % Dipole antennas at Rx
samp_per_meter = 0.25;                                      % samples per meter for track interpolation
track_length = 500;                                         % track length in meters; currently same for all l.no_rx UEs
if process_paths ==1
    fprintf('Number of Tx: %d, Number or UEs & paths: %d, track lengths: %3.0f m, Tx height: %4.1f m, Tx antenna type: %s \n',l.no_tx,l.no_rx,track_length,l.tx_position(3,1),l.tx_array(1).name)
end
%% parameters for generating power map
max_xy =300;                                                % max x and y extent for power map (change to 300)
ue_height = 1.5;                                            % height at which to create power map
grid_resolution = 2;                                        % resolution of grid in meters for power map
if process_powermap ==1
    fprintf('Area defined by X, Y max: %d meters, grid resolution: %d meters, UE height: %4.1f meters, Tx antenna type: %s \n',max_xy, grid_resolution, ue_height,l.tx_array(1).name)
end
%% RF environments; the ones below are specified in files in the Quadriga directory; each specifies scatterers, angular spread etc
% scen = {'FB_UMa_LOS','FB_UMa_NLOS'};                     % LOS and NLOS scenario name
scen = {'FB_UMa_NLOS','FB_UMa_NLOS'};                      % Temporarily fixing scenario name for the whole path