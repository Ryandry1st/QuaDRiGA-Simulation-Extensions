%% directives to the simulator
% process_paths = 0;                                      % set to 1 to calculate channels along tracks
% process_powermap = 1;                                   % set to 1 to calculate map of powers
% show_plot = 1;                                          % set to 1 to show plots of channels
% save_work = 1;                                          % set to 1 if you want to save the workspace
% save_opt = 1;
% save_npz = 1;
% 
%python_path = '/Users/ayp/opt/anaconda3/bin/python';
% fill with something like '/opt/anaconda3/bin/python3'
%% simulation parameters
% These are options to select/change
% set downtilt to -1 to use the csv downtilts, otherwise specify it as a
% scalar to be applied to all or a vector of #no_tx, no_sectors of values

%downtilt = 21;                                           % Downtilt value, can be independently set for each sector
%TX_P = 40;                                              % TX power in [W]
Tx_P_dBm = 10*log10(TX_P)+30;                           % TX power in [dBm]

if no_BS <= 5
    sim_definitions;
else
    random_cell_sites;
end

tx_powers = ones(1, l.no_tx)*Tx_P_dBm;                  % assumes same power for all tx, can be changed

%max_xy =600;                                            % max x and y extent for power map (change to 300)
%ue_height = 1.5;                                        % height at which to create power map

%grid_resolution = 5;                                    % resolution of grid in meters for power map

%% Report out
% fprintf('Simulation starting,with process_paths = %d, process_powermap = %d, show_plot = %d and save_work = %d \n',process_paths,process_powermap,show_plot,save_work)
% fprintf('Results will be written to %s \n',track_directory)
% fprintf('Center freq: %5.2f GHz, Sample spacing(m): %4.3f \n',s.center_frequency/1e9, 3e8/(s.center_frequency*s.sample_density*2))

% if process_powermap ==1
%     fprintf('Area defined by X, Y max: %d meters, grid resolution: %d meters, UE height: %4.1f meters, Tx antenna type: %s \n',max_xy, grid_resolution, ue_height,l.tx_array(1).name)
% end

%% number of receiver & specification of antenna type; length and resolution of UE track
l.no_rx = 1;                                              % Number of UEs and tracks - one track per UE
l.rx_array = qd_arrayant('dipole');                       % Dipole antennas at Rx
l.rx_array.center_frequency = FC;
samp_per_meter = 0.25;                                    % samples per meter for track interpolation
track_length = 500;                                       % track length in meters; currently same for all l.no_rx UEs
% if process_paths ==1
%     fprintf('Number of Tx: %d, Number or UEs & paths: %d, track lengths: %3.0f m, Tx height: %4.1f m, Tx antenna type: %s \n',l.no_tx,l.no_rx,track_length,l.tx_position(3,1),l.tx_array(1).name)
% end

%% RF environments
% scen = {'FB_UMa_LOS','FB_UMa_NLOS'};                     % LOS and NLOS scenario name
%scen = {'FB_UMa_NLOS','FB_UMa_NLOS'};                      % Temporarily fixing scenario for the whole path

%scen = {'Freespace','Freespace'};                      % Temporarily fixing scenario for the whole path
