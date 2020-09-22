% Tutorial 2 Driving Course
% 800m drive course covered by an S-band satellite. Car moves along the
% trajectory with different reception.

%% Setup Trajectory
% 4 straight segments of 200m, 100m, 400m, and 53m with 90* turns, modeled
% by arcs with radius 10m=15.7m length -> ~800m length track.
clear all;
close all;

t = qd_track('linear', 200, pi/4);  % heading north east, 200m seg
t.name = 'Terminal';
t.initial_position(3, 1) = 2; % RX height is 2m

c = 10*exp(1j*(135:-1:45)*pi/180); % 10m to turn to SE
c = c(2:end)-c(1);  % start at a position relative to (0, 0)
t.positions = [t.positions, [t.positions(1, end) + real(c); t.positions(2,end) + imag(c); zeros(1, numel(c))]];

c = 100*exp(-1j*pi/4); % 200m SE
t.positions = [t.positions, [t.positions(1, end) + real(c); t.positions(2,end) + imag(c); zeros(1, numel(c))]];

c = 10*exp(1j*(-135:-45)*pi/180); % 10m to turn to NE
c = c(2:end)-c(1);  % start at a position relative to (0, 0)
t.positions = [t.positions, [t.positions(1, end) + real(c); t.positions(2,end) + imag(c); zeros(1, numel(c))]];

c = 400*exp(1j*pi/4); % 400m NE
t.positions = [t.positions, [t.positions(1, end) + real(c); t.positions(2,end) + imag(c); zeros(1, numel(c))]];

c = 10*exp(1j*(135:-1:45)*pi/180); % 10m to turn to SE
c = c(2:end)-c(1);  % start at a position relative to (0, 0)
t.positions = [t.positions, [t.positions(1, end) + real(c); t.positions(2,end) + imag(c); zeros(1, numel(c))]];

c = 53*exp(-1j*pi/4); % 200m SE
t.positions = [t.positions, [t.positions(1, end) + real(c); t.positions(2,end) + imag(c); zeros(1, numel(c))]];

t.calc_orientation; % calculate receiver orientations

l = qd_layout;
[~, l.rx_track] = interpolate(t.copy, 'distance', 0.1); % interpolate the track

l.visualize([], [], 0);
axis equal
title('track layout');

%% Assign propagation environment

t.scenario{1} = '3GPP_38.881_Urban_LOS';
t.add_segment([64;64;2], '3GPP_38.881_Urban_NLOS', 2);
t.add_segment([84;84;2], '3GPP_38.881_Urban_LOS', 2);
t.add_segment([233;68;2], '3GPP_38.881_Urban_NLOS', 2);
t.add_segment([272;103;2], '3GPP_38.881_Urban_LOS', 2);
t.add_segment([283;114;2], '3GPP_38.881_Urban_NLOS', 2);
t.add_segment([324;153;2], '3GPP_38.881_DenseUrban_NLOS', 2);
t.add_segment([420;250;2], '3GPP_38.881_Urban_NLOS', 2);
t.add_segment([490;320;2], '3GPP_38.881_Rural_LOS', 2);

%% Model stops at traffic lights
% start with 10m/s for 20s then slow and stop after 30s for 10s. Go for
% 66.5s to travel 530m and stop for 6.5s. Thus total time is 100s. You
% should sample the movement more often for a smoother profile

t.movement_profile = [0, 20, 30, 40, 66.5, 73, 100; % time points
                        0, 200, 265, 265, 530, 530, 800];     % distance points
                    
dist = t.interpolate('time', 0.1);
time = (0:numel(dist) - 2) * 0.1;
speed = diff(dist)*10;

figure
plot(time, speed, 'Linewidth', 2);
xlabel('Simulation Time (s)'); 
ylabel('Speed (m/s)'); grid on;
axis([0, 100, 0, 11]);


%% Simulation Layout and Antenna Setup
% 2.2GHz parabolic dish antenna 3m diameter, gain of 44dBi, LHCP polarized.
% Terminal is a dual polarized patch antenna (LHCP/RHCP) pointing towards
% the sky. TX power is 100W = 64dBW isotropic radiator for space segment.
% Ignoring curvature of the earth
l = qd_layout;
l.simpar.center_frequency = 2.2e9;

l.rx_track = t;
l.rx_track.split_segment(10, 50, 30, 12); % create additional segments
l.rx_track.correct_overlap;               % fix segment start positions

l.set_satellite_pos(52.3, 29.7, 172.7);   % geospatial coordinates
l.tx_array = qd_arrayant('parabolic', 3, l.simpar.center_frequency, [], 3);
l.tx_track.orientation = [0; -29.7; 97.3]*pi/180; % orient transmitter
l.tx_name{1} = 'Satellite';

l.rx_array = qd_arrayant('patch');
l.rx_array.center_frequency = l.simpar.center_frequency;
l.rx_array.copy_element(1, 2);    % make identical antenna

l.rx_array.rotate_pattern(90, 'x', 2);     % rotate second antenna by 90
l.rx_array.coupling = 1/sqrt(2)*[1 1; 1j -1j];   % set LHCP/RHCP polarization
l.rx_array.combine_pattern;
l.rx_array.rotate_pattern(-90, 'y');    % point towards the sky

[map, x_coords, y_coords] = l.power_map('3GPP_38.881_Urban_LOS', 'sf', 2e4, -6e6, 6e6, -5e6, 5e6);
P = 10*log10(map{:}(:, :, 1)) + 50;       % RX copolar power @ 50dBm TX power
l.visualize([], [], 2);
axis([-5e6, 5e6, -5e6, 5e6]);
hold on;
imagesc(x_coords, y_coords, P);
hold off;

colorbar('South');
colmap = colormap;
colormap(colmap*0.5 + 0.5);
axis equal
set(gca, 'XTick', (-5:5)*1e6);
set(gca, 'YTick', (-5:5)*1e6);
caxis([-150, -90])
set(gca, 'layer', 'top');
title('Beam Footprint in dBm');


%% Generate Channel Coefficients
c = l.get_channels(0.01);

pow = 10*log10(reshape(sum(abs(c.coeff(:, :, :, :)).^2, 3), 2, []));
time = (0:c.no_snap-1)*0.01;

ar = zeros(1, c.no_snap);
ar(900:1200) = -200;      %NLOS from P2 to P3
ar(3000:4000) = -200;     %Stop at P5
ar(4650:5050) = -200;     % NLOS from P6 to P7
ar(5300:5800) = -200;     % NLOS still from P6 to P7
ar(6650:7300) = -200;     % Stop at P9
ar(7800:8900) = -200;     % stop at P9 still

figure('Position', [100, 100, 1200, 400]);
a = area(time, ar, 'FaceColor', [0.7, 0.9, 0.7], 'Linestyle', 'None'); % area shading
hold on;
plot(time, pow'+50);
hold off;
xlabel('Simulation Time');
ylabel('RX Power [dBm]');
grid on;
axis([0, 100, [-150, -80]]);
legend('Event', 'RX LHCP', 'RX RHCP');
set(gca, 'layer', 'top');

text( 7,-85,'P2' ); text( 11,-85,'P3' ); text( 8,-145,'NLOS' );
text( 20,-85,'P4' ); text( 33,-85,'P5' ); text( 32,-145, 'Stop' );
text( 45.5,-85,'P6' ); text( 50.5,-85,'P7' ); text( 44,-145,'NLOS' );
text( 57,-85,'P8' ); text( 53,-145,'NLOS' );
text( 69,-85,'P9' ); text( 68,-145, 'Stop' );
text( 77,-85,'P10' ); text( 80,-145, 'Urban' );text( 92,-145, 'Rural' );