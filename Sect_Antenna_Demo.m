% This setup will test some of the features that I want to use
clear all;
close all;

%% User definitions
UE_HEIGHT = 1.5;                          % UE receiver height
TX_P = 250;                               % TX power in [W]
BS_DIST = 300;                            % UE receiver height 

MAX_XY = 400;                             % Maximum for the X and Y plotting
TRACK_LENGTHS = 50;                       % Distance receivers will travel

AZI_BEAMWIDTH = 66;                      % Azimuth beamwidth for sector antenna
ELE_BEAMWIDTH = 7;                       % Elevation beamwidth for sector antenna
FB_RATIO_DB = -30;                        % Front to back ratio in dB
FB_ratio = 10^(FB_RATIO_DB/10);           % Front to back ratio in linear scale
ANTENNA_ELEMENTS = 4;                     % Number of antenna elements in a sector
FC = 2.4e9;                               % Carrier frequency
DOWNTILT = 5;                            % Downtilt value, may not be manipulated in real system
ISOLATION_DB = 30;
coupling = 10^(-ISOLATION_DB/10);

SAMPLE_DISTANCE = 5;                      % Distance per power-grid measurement
USE_LOS = 1;                              % Select 1 to use LOS or 0 for NLOS 
ABSOLUTE_CMAP = 0;                        % Select 1 to use absolute cmap color
PLOT_SECTORS = 0;

N_SECTORS = 3;


%% Parameters updates
Tx_P_dBm = 10*log10(TX_P)+30;             % TX power in [dBm]

if USE_LOS == 1
    Rx_threshold_dBm = -45;               % Threshold for determining valuable links
    scen = 'FB_UMa_LOS';
    title_postend = 'LOS';
else
    Rx_threshold_dBm = -80;
    scen = 'FB_UMa_NLOS';
    title_postend = 'NLOS';
end

if FC<6e9                                 % Determine if this is mmWave or not
    below_mmWave=1;
else
    below_mmWave=0;
end

s = qd_simulation_parameters;
s.show_progress_bars=1;
s.center_frequency = FC;
s.sample_density = 1.8;                   % Samples per 1/2 wavelength
s.use_absolute_delays=1;

%% Define Antennas
% select antenna, 3gpp-macro is easily chosen as a sector antenna, but
% others could work as well if we know the antenna elements, for example

% a = qd_arrayant('3gpp-3d', ANTENNA_ELEMENTS, 1, FC, 4, DOWNTILT);
% a = qd_arrayant('multi', ANTENNA_ELEMENTS, 0.5, DOWNTILT);

a = qd_arrayant('3gpp-macro', AZI_BEAMWIDTH, ELE_BEAMWIDTH, -FB_RATIO_DB, DOWNTILT);
a.center_frequency = FC;
a.rotate_pattern(45, 'x', 1, 2);
a.append_array(a.copy());
a.coupling = [1, 1; 0, 0];
b = a.copy();  
b.rotate_pattern(-90, 'x', 1:2, 2);
a.append_array(b);
% a.combine_pattern();
Tx_ant = a.copy();

for i=1:N_SECTORS-1
    a2 = a.copy();
    a2.rotate_pattern(360/N_SECTORS*i, 'z');
    Tx_ant.append_array(a2);
end

no_antennas = size(calc_gain(Tx_ant));

% b = qd_arrayant('vehicular', 2, below_mmWave, 2); % Vehicular antenna receivers
b = qd_arrayant('dipole');
b.center_frequency = FC;

% a.visualize(1:4); % take a look at the radiation pattern, should be sector antenna
% b.visualize(1); % Primarily upward radiation pattern


%% Define BS and UEs
l = qd_layout(s);
l.tx_array = Tx_ant;
l.no_tx = 1;

% generate base stations in a ring
% l = qd_layout.generate('regular', l.no_tx, BS_DIST, a.copy());  
l.simpar = s.copy();                               % Apply simulation params

l.no_rx = 1;
l.rx_array(:) = b.copy();
l.randomize_rx_positions(250, UE_HEIGHT, UE_HEIGHT, TRACK_LENGTHS);
interpolate_positions(l.rx_track, s.samples_per_meter);
calc_orientation(l.rx_track);

% apply scenario to the tracks, this could be used to change which tracks
% are different scenarios
for i=1:l.no_rx
    l.rx_track(i).set_scenario(scen);
end

% l.tx_array(1).visualize(1:3);           % Visualize the 3 sectors

%% Setup Channels
% Set the transmit powers and determine which pairings are above the
% threshold
tx_powers = ones(1, l.no_tx)*Tx_P_dBm;
[pairs, powers] = l.set_pairing('power', Rx_threshold_dBm, tx_powers);

% tic
% p = l.init_builder;                               % Create channel builders
% gen_parameters( p );                              % Generate small-scale fading
% c = get_channels( p );                            % Generate channel coefficients
% cn = merge( c );
% toc

%% Make power map
% Make the power map
if USE_LOS == 1
    [ map,x_coords,y_coords] = l.power_map(scen, 'quick', SAMPLE_DISTANCE, -MAX_XY,MAX_XY,-MAX_XY,MAX_XY,UE_HEIGHT, tx_powers);
else
    [ map,x_coords,y_coords] = l.power_map(scen, 'quick', SAMPLE_DISTANCE, -MAX_XY,MAX_XY,-MAX_XY,MAX_XY,UE_HEIGHT, tx_powers);
end

% map contains data as {no_Tx} [y, x, rx_element, tx_sector]
P = 10*log10(sum(abs(cat(3, map{:})).^2, 3:4));    % Total received power [dBm]


%% Visualize the power map
l.visualize([], [], 0);
hold on;
imagesc( x_coords, y_coords, P);                   % Plot the received power
axis([-MAX_XY MAX_XY -MAX_XY MAX_XY])              % Plot size

% Choose between absolute or relative coloring
if ABSOLUTE_CMAP == 0
    caxis( max(P(:)) + [-20 0] )                   % Relative color range
else
    if USE_LOS == 1                                % Absolute color range
        caxis( [-45 -25]);
    else
        caxis( [-90 -65]);
    end
end


colmap = colormap;
colormap( colmap);                         
c = colorbar;
c.Label.String = "Receive Power [dBm]";
set(gca,'layer','top')
title("Total Power Map " +title_postend);


%% Individual Sectors
% Use this section if you want to see individual sectors power maps
if PLOT_SECTORS == 1
    P1 = 10*log10(sum(abs(cat(3, map{:}(:, :, :, 1))).^2, 3));
    P2 = 10*log10(sum(abs(cat(3, map{:}(:, :, :, 2))).^2, 3));
    P3 = 10*log10(sum(abs(cat(3, map{:}(:, :, :, 3))).^2, 3));
    
    % Plot sector 1
    l.visualize([], [], 0);
    hold on;
    imagesc( x_coords, y_coords, P1);                  
    axis([-MAX_XY MAX_XY -MAX_XY MAX_XY])             

    % Choose between absolute or relative coloring
    if ABSOLUTE_CMAP == 0
        caxis( max(P(:)) + [-20 0] )                   
    else
        if USE_LOS == 1                                
            caxis([-65, -40]);
        else
            caxis( [-90 -65]);
        end
    end


    colmap = colormap;
    colormap( colmap);                          
    c = colorbar;
    c.Label.String = "Receive Power [dBm]";
    set(gca,'layer','top')


    l.visualize([], [], 0);
    hold on;
    imagesc( x_coords, y_coords, P2);                  
    axis([-MAX_XY MAX_XY -MAX_XY MAX_XY])             

    % Choose between absolute or relative coloring
    if ABSOLUTE_CMAP == 0
        caxis( max(P(:)) + [-20 0] )                   
    else
        if USE_LOS == 1                                
            caxis([-65, -40]);
        else
            caxis( [-90 -65]);
        end
    end


    colmap = colormap;
    colormap( colmap);                           % Adjust colors to be "lighter"
    c = colorbar;
    c.Label.String = "Receive Power [dBm]";
    set(gca,'layer','top')

    l.visualize([], [], 0);
    hold on;
    imagesc( x_coords, y_coords, P3);                   % Plot the received power
    axis([-MAX_XY MAX_XY -MAX_XY MAX_XY])              % Plot size

    % Choose between absolute or relative coloring
    if ABSOLUTE_CMAP == 0
        caxis( max(P(:)) + [-20 0] )                   % Relative color range
    else
        if USE_LOS == 1                                % Absolute color range
            %caxis( [-45 -25]);
            caxis([-65, -40]);
        else
            caxis( [-90 -65]);
        end
    end


    colmap = colormap;
    colormap( colmap);                           % Adjust colors to be "lighter"
    c = colorbar;
    c.Label.String = "Receive Power [dBm]";
    set(gca,'layer','top')
    
end



