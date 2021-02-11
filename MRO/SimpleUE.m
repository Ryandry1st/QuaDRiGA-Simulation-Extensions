% Simple UE
% generates a single UE with a simple route through a simulation
close all;
clear all;
tic;

init_params;

%% File path information
% save_folder = ['Output_files\',datestr(now,'mm-dd-HH-MM'),'\'];
if restore_config
    save_folder = ['Output_files/Scenario ', sim_num, '/'];
    if ~exist(save_folder, 'dir')
        mkdir(save_folder);
    end
    directories = dir(save_folder);
    num_dir = numel(directories([directories(:).isdir]))-2;
    save_folder = [save_folder, 'trial ', num2str(num_dir+1), '/'];
    mkdir(save_folder);
    
    distance = speed .* total_time;
    samples_per_meter = fs/max(speed);
    
    s = qd_simulation_parameters;             % New simulation parameters
    s.center_frequency = fc;               % 1.8 GHz carrier frequency middle of lte band 3
    s.sample_density = 1;                     % num samples per half-wavelength
    s.use_absolute_delays = 1;                % Include delay of the LOS path
    s.show_progress_bars = 1;                 % Enable progress bars; set to 0 to disable progress bars
    s.use_3GPP_baseline = 0;
    s.samples_per_meter = samples_per_meter;
    s.sample_density = samples_per_meter*3e8/2/s.center_frequency;
    
    l = qd_layout(s);
    l.no_tx = no_tx;
    
    
    for i=1:l.no_tx
        l.tx_position(:, i) = tx_pos(i, :)';
        index = N_SECTORS(i)*(i-1)+1;
        l.tx_array(i) = qd_arrayant(ARRAY_TYPE, AZI_BEAMWIDTH, ELE_BEAMWIDTH, -FB_RATIO_DB, orientations(index, 1));
        l.tx_array(i).rotate_pattern(orientations(index, 2), 'z');
        % fprintf('antenna %d sector 1 with dt = %d and azi = %d \n', i, orientations(index, 2), orientations(index, 1));
        
        for j=1:N_SECTORS(i)-1
            a = qd_arrayant(ARRAY_TYPE, AZI_BEAMWIDTH, ELE_BEAMWIDTH, -FB_RATIO_DB, orientations(index+j, 1));
            a.rotate_pattern(orientations(index+j, 2), 'z');
            l.tx_array(i).append_array(a);
        end
        l.tx_array(i).center_frequency = fc;
    end
    
    %% Setup UE
    l.no_rx = no_rx;
    
else
    save_folder = ['Output_files\Scenario ', sim_num, '\'];
    mkdir(save_folder);
    
    %% Simulation Choices
    initial_loc = [100, -200, 1.5;
        600, 400, 1.5];
    
    heading = [3*pi/4, 3*pi/2];
    speed = [12, 25];
    total_time = 40; % 40s time frame
    fs = 1000;                               % 1ms sampling time
    
    distance = speed .* total_time;
    samples_per_meter = fs/max(speed);
    
    %% General setup
    s = qd_simulation_parameters;             % New simulation parameters
    s.center_frequency = 28e9;               % 1.8 GHz carrier frequency middle of lte band 3
    s.sample_density = 1;                     % num samples per half-wavelength
    s.use_absolute_delays = 1;                % Include delay of the LOS path
    s.show_progress_bars = 1;                 % Enable progress bars; set to 0 to disable progress bars
    s.use_3GPP_baseline = 0;
    s.samples_per_meter = samples_per_meter;
    s.sample_density = samples_per_meter*3e8/2/s.center_frequency;
    
    
    %% Chose BS layout
    l = qd_layout(s);
    l.no_tx = 3;
    N_SECTORS(i) = 3;
    orientations = [5, 135;
        1, -135;
        5, 0;
        7, 45;
        10, -45;
        10, 180;
        25, 0;
        45, 135;
        45, -135];
    
    l.tx_position(:, 1) = [-500, 500, 30]';
    l.tx_position(:, 2) = [-500, -500, 30]';
    l.tx_position(:, 2) = [900, -300, 20]';
    
    for i=1:l.no_tx
        index = N_SECTORS(i)*(i-1)+1;
        l.tx_array(i) = qd_arrayant(ARRAY_TYPE, AZI_BEAMWIDTH, ELE_BEAMWIDTH, -FB_RATIO_DB, orientations(index, 1));
        l.tx_array(i).rotate_pattern(orientations(index, 2), 'z');
        % fprintf('antenna %d sector 1 with dt = %d and azi = %d \n', i, orientations(index, 2), orientations(index, 1));
        
        for j=1:N_SECTORS(i)-1
            a = qd_arrayant(ARRAY_TYPE, AZI_BEAMWIDTH, ELE_BEAMWIDTH, -FB_RATIO_DB, orientations(index+j, 1));
            a.rotate_pattern(orientations(index+j, 2), 'z');
            l.tx_array(i).append_array(a);
        end
        l.tx_array(i).center_frequency = FC;
    end
    
    %% Setup UE
    l.no_rx = 2;
end

l.rx_array = qd_arrayant('dipole');

if numel(Tx_P_dBm) == 1
    Tx_P_dBm = ones(l.no_tx, N_SECTORS(i))*Tx_P_dBm;
end
%% UE path
for i=1:l.no_rx
    t = qd_track('linear', distance(i), heading(i));  % heading north 400m
    t.initial_position(:, 1) = initial_loc(i, :);
    
    %     t.scenario{1} = scen;
    
    t.movement_profile = [0, total_time; % time points
        0, distance(i)];     % distance points
    t.name = ['rx' num2str(i)];
    t.calc_orientation; % calculate receiver orientations
    [~, l.rx_track(1, i)] = interpolate(t.copy, 'time', 1/fs); % interpolate the track at 1/fs rate
    l.rx_track(1, i).positions = l.rx_track(1, i).positions(:, 1:end-1); % remove the last point so it is the correct number of samples
end

%% Process Path
calc_orientation(l.rx_track)
l.set_scenario(scen, [], [], 0);
p = l.init_builder;                                       % Create channel builders
gen_parameters( p );                                      % Generate small-scale fading
c = get_channels( p );                                    % Generate channel coefficients
cn = merge( c );

used_time = toc;
fprintf("Time taken for simulation = %3.1f s", used_time);
l.visualize([],[],0);                                     % Show BS and MT positions on the map


%% Outputs
% First we want to output the data like the fading_trace_generator file
% then we want to output some sort of configuration file
% And finally a .mat file of anything useful like p and cn
Write_Spectral_Tracks;
saveas(gcf, strcat(save_folder, 'Layout.png'))
write_txt_config;
write_json_config;
% save(strcat(save_folder, 'workspace.mat'), '-v7.3', 'p', 'cn');
% config file should have tx locations, rx start, heading, speed, end, the
% antenna descriptions, and scenario.

fprintf("Total time = %3.1f s", toc);
if process_powermap == 1
    
    [ map,x_coords,y_coords] = l.power_map('3GPP_3D_UMa_NLOS', 'quick',grid_resolution,-max_xy,max_xy,-max_xy,max_xy,ue_height, Tx_P_dBm(1, 1));
    % scenario FB_UMa_NLOS, type 'quick', sample distance, x,y min/max, rx
    % height; type can be 'quick', 'sf', 'detailed', 'phase'
    
    % P = 10*log10(sum( abs( cat(3,map{:}) ).^2 ,3));         % Total received power
    P = 10*log10(sum(abs(cat(3, map{:})), 3:4));        % Simplified Total received power; Assumed W and converted to dBm
    if show_plot ==1
        l.visualize([],[],0);
        hold on;
        imagesc( x_coords, y_coords, P);          % Plot the received power
        axis([-max_xy max_xy -max_xy max_xy])                               % Plot size
        %caxis( max(powermatrix.Tx1pwr,[],'all') + [-20 0] )                  % Color range
        caxis( max(P(:)) + [-50 -5] )
        % caxis([-75, -30]);
        colmap = colormap;
        colbar = colorbar;
        colbar.Label.String = "Receive Power [dBm]";
        % colormap( colmap*0.5 + 0.5 );                           % Adjust colors to be "lighter"
        set(gca,'layer','top')                                    % Show grid on top of the map
        hold on;
        set(0,'DefaultFigurePaperSize',[14.5 7.3])                % Adjust paper size for plot                                  % Show BS and MT positions on the map
    end
    saveas(gcf, strcat(save_folder, 'Rough_RSRP_Map.png'))
end