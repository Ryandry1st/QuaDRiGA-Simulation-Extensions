clear all;
close all;
clc;

big_tic = tic;

seed = 0;

rng('default');
rng(seed);

set(0, 'defaultTextFontSize', 18) % Default Font Size
set(0, 'defaultAxesFontSize', 18) % Default Font Size
set(0, 'defaultAxesFontName', 'Arial') % Default Font Type
set(0, 'defaultTextFontName', 'Arial') % Default Font Type
set(0, 'defaultFigurePaperPositionMode', 'auto') % Default Plot position
set(0, 'DefaultFigurePaperType', '<custom>') % Default Paper Type
set(0, 'DefaultFigurePaperSize', [14.5, 6.9]) % Default Paper Size
set(0, 'DefaultAxesTitleFontWeight', 'normal');

python_path = '/Users/ayp/opt/anaconda3/bin/python';
fixed_cvs_file = "csvData/Mavenir_locs.csv";

%% QuaDRiGa Setup

s = qd_simulation_parameters; % Set general simulation parameters
s.center_frequency = 2e9; % 2 GHz center frequency
s.sample_density = 1.5;
s.use_3GPP_baseline = 1; % Disable spherical waves
s.show_progress_bars = 1; % Enable / disable status display
s.use_absolute_delays = 1;

% flags
save_results = 0;
save_layout = 0;
show_plot = 1;
random_ori_azi = 0;
clean_code = 1;

% layout
no_rx_min = 10000;
no_tx = 1;
sample_distance = 10;
BS_drop = "hex"; %hex, rnd, csv
downtilt = 5;
isd = 100;
tx_pwr_dBm = 46;
nSC = 600;
rx_height = 1.5;
tx_height = 25;
no_sectors = 3;
tx_height_min = tx_height;
tx_height_max = tx_height;

chn_scenario = 'Freespace';
%      * Freespace
%      * 3GPP_3D_UMi
%      * 3GPP_3D_UMa
%      * 3GPP_38.901_UMi
%      * 3GPP_38.901_UMa
%      * 3GPP_38.901_RMa
%      * 3GPP_38.901_Indoor_Mixed_Office
%      * 3GPP_38.901_Indoor_Open_Office
%      * 3GPP_38.901_InF_SL
%      * 3GPP_38.901_InF_DL
%      * 3GPP_38.901_InF_SH
%      * 3GPP_38.901_InF_DH

% Array type at bs, main options include: omni, dipole, half-wave-dipole, patch, 3gpp-macro, 3gpp-3d (more available in generate.m)
tx_antenna_type = '3gpp-3d';
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

downtilt = -downtilt; %Quadriga uses positive tilt to point "upward" so we have to negate to point "downward".

tx_antenna_3gpp_3d.M = 2;
tx_antenna_3gpp_3d.N = 1;
tx_antenna_3gpp_3d.center_freq = s.center_frequency;
tx_antenna_3gpp_3d.pol = 4;
tx_antenna_3gpp_3d.tilt = -15;
tx_antenna_3gpp_3d.spacing = 0.5;

% BS antenna configuration
tx_array_3GPP_3d = qd_arrayant(tx_antenna_type, tx_antenna_3gpp_3d.M, tx_antenna_3gpp_3d.N, tx_antenna_3gpp_3d.center_freq, tx_antenna_3gpp_3d.pol, downtilt, tx_antenna_3gpp_3d.spacing);
tx_array_3GPP_3d.element_position(1, :) = 0; % Distance from pole
tx_array_3GPP_3d.name = '3gpp-3d';

% MT antenna configuration
a_mt = qd_arrayant('omni');
%a_mt.copy_element(1, 2);
%a_mt.element_position(2, :) = [-s.wavelength / 2, s.wavelength / 2] * 0.5;
a_mt.center_frequency = s.center_frequency;

%% Drop users
fprintf('[Generate layout]');
layout_tic = tic;

n_coords = ceil(sqrt(no_rx_min))^2;
max_xy = floor((sample_distance*floor(sqrt(n_coords))-1)/2);
x_min = -max_xy;
x_max = -x_min;
y_min = x_min;
y_max = -y_min;
x_coords = x_min:sample_distance:x_max;
y_coords = y_max:-sample_distance:y_min;
n_x_coords = numel(x_coords);
n_y_coords = numel(y_coords);
no_rx = n_coords;

fprintf('\n\tDropping %d users in a [%d x %d](m) grid...', no_rx, max_xy, max_xy);
[Xn, Yn] = meshgrid(x_coords, y_coords);
rx_point = zeros(3, no_rx);
for n = 1:no_rx
    rx_point(:, n) = [Xn(n); Yn(n); rx_height];
end
fprintf('done.\n')

%% Drop basestations

fprintf('\tSetting tx positions...');
orientations = [];

switch BS_drop

    case 'csv'
        fprintf('\tLoading CSV file...')
        % Read the csv file for BS locations and sector orientations using the python helper functions
        commandStr = sprintf('%s pyScripts/Tx_Information_from_csv.py %s', python_path, fixed_cvs_file);
        [status1, output] = system(commandStr);
        tx_locs = str2num(output);
        if (size(tx_locs) < 1)
            disp("There was a problem with your python, traceback:");
            error(output)
        end
        commandStr = sprintf('%s pyScripts/Tx_Sector_Information_from_csv.py %s', python_path, fixed_cvs_file);
        [status2, output] = system(commandStr);
        if status1 == 0 && status2 == 0
            fprintf('success.\n')
        end
        orientations = str2num(output);
        no_tx = size(tx_locs, 1);

    case "rnd"
        boundary_xy = 0.9 * max_xy;
        locs_xy = zeros(no_tx, 2);
        locs_xy(1, :) = -boundary_xy + 2 * boundary_xy * rand(1, 2);
        counter = 1;
        while counter < no_tx
            candidate_point = -boundary_xy + 2 * boundary_xy * rand(1, 2);
            d = sqrt((locs_xy(1:counter, 1)-candidate_point(1)).^2+(locs_xy(1:counter, 2) - candidate_point(2)).^2);
            if d > isd
                counter = counter + 1;
                locs_xy(counter, :) = candidate_point;
            end
        end
        locs_z = tx_height_min + (tx_height_max - tx_height_min) .* rand(no_tx, 1);
        tx_locs = [locs_xy, locs_z];
        fprintf('done.\n');

    case 'hex'
        l_tmp = qd_layout.generate('regular', no_tx, isd);
        tx_locs = (l_tmp.tx_position).';
        locs_z = tx_height_min + (tx_height_max - tx_height_min) .* rand(no_tx, 1);
        tx_locs(:, 3) = locs_z;
        fprintf('done.\n');
end

%% Generate layout object
l = qd_layout(s);
l.simpar = s; % Set simulation parameters
l.name = chn_scenario;
l.no_rx = no_rx;
l.no_tx = no_tx;
for i = 1:l.no_tx
    l.tx_position(:, i) = tx_locs(i, :);
end
fprintf('\tSetting rx positions...');
l.rx_position = rx_point;
fprintf('done.\n');

% tx array
if isempty(orientations)
    ori_azi = repmat((0:floor(360 / no_sectors):360-floor(360 / no_sectors)), 1, no_tx).' + 30;
    ori_azi(ori_azi > 180) = ori_azi(ori_azi > 180) - 360;
    if random_ori_azi
        ori_azi = -180 + 360 * rand(no_tx*no_sectors, 1);
    end
    ori_dt = downtilt * ones(no_tx*no_sectors, 1);
    orientations = [ori_azi, ori_dt];
end

for i = 1:l.no_tx
    index = no_sectors * (i - 1) + 1;
    for j = 1:no_sectors
        n = index + j - 1;
        theta_n = orientations(n, 2);
        tx_array_cpy(j) = qd_arrayant(tx_antenna_type, tx_antenna_3gpp_3d.M, tx_antenna_3gpp_3d.N, tx_antenna_3gpp_3d.center_freq, tx_antenna_3gpp_3d.pol, theta_n, tx_antenna_3gpp_3d.spacing);
    end
    tx_array_i = copy(tx_array_cpy(1));
    no_el = tx_array_i.no_elements;
    for j = 2:no_sectors
        phi = orientations(index+j-1, 1);
        for m = 1:no_el
            tx_array_i.copy_element(m, (j - 1)*no_el+m);
            tx_array_i.rotate_pattern(phi, 'z', (j - 1)*no_el+m);
        end
    end
    phi_1 = orientations(index, 1);
    for m = 1:no_el
        tx_array_i.rotate_pattern(phi_1, 'z', m);
    end
    l.tx_array(i) = tx_array_i;
end

% rx array
l.rx_array = a_mt;
indoor_frc = 0;
fprintf('\tSetting layout scenarios for all users...');
l.set_scenario(chn_scenario, [], [], indoor_frc);
fprintf('done.\n');

if save_layout
    if ~exist([pwd, '/savedLayouts'], 'dir')
        mkdir(pwd, '/savedLayouts');
    end
    fprintf('\nSaving layout file...')
    save('savedLayouts/layout.mat', '-v7.3', 'l', 'x_min', 'x_max', 'y_min', 'y_max', 'x_coords', 'y_coords', 'n_x_coords', 'n_y_coords', 'sample_distance', 'no_rx_min');
    fprintf('success.\n');
end
%l.visualize([],[],0);axis square
fprintf('[Generate layout] runtime = %1.0f min\n', toc(layout_tic)/60);

%% Generate channels
% Channels are now generated using the default QuaDRiGa method (phase 1 only used the LOS path).
% This w1l take quite some time.
generate_channels_tic = tic;
cl = l.get_channels; % Generate channels
nEl = l.tx_array(1, 1).no_elements / 3; % Number of elements per sector
nEl = {1:nEl, nEl + 1:2 * nEl, 2 * nEl + 1:3 * nEl}; % Element indices per sector
fprintf('\nSpliting channels to sectors...');
c(:, :) = split_tx(cl, nEl); % Split channels from each sector
fprintf('success.');
fprintf('\n[Generate channels] runtime = %1.0f min\n', toc(generate_channels_tic)/60)

%% POSTPROCESSING
fprintf('\nPost processing...');

%Coupling Loss
pg_eff = zeros(l.no_rx, l.no_tx*no_sectors); % Calculate the effective path gain from the channels

mimo_no_tx = l.tx_array(1, 1).no_elements / no_sectors;
mimo_no_rx = l.rx_array(1, 1).no_elements;
no_mimo_links = mimo_no_tx * mimo_no_rx; % Get the number of MIMO sub-channels in the channel matrix

for ir = 1:l.no_rx % Extract effective PG vor each BS-MT link
    for it = 1:l.no_tx * no_sectors
        pg_eff(ir, it) = sum(abs(c(ir, it).coeff(:)).^2) / no_mimo_links;
    end
end

% Calculate the coupling loss from the effective PG
coupling_loss = 10 * log10(max(pg_eff(:, :), [], 2));
coupling_loss_2d = reshape(coupling_loss, n_y_coords, n_x_coords);

% Wideband SINR
% The wideband SINR is essentially the same as the GF. However, the 3GPP model uses the RSRP values
% for the calculation of this metric. The calculation method is described in 3GPP TR 36.873 V12.5.0
% in Section 8.1 on Page 38. Essentially, the RSRP values describe the average received power (over
% all antenna elements at the receiver) for each transmit antenna port. Hence, in the phase 2
% calibration, there are 4 RSRP values, one for each transmit antenna. The wideband SINR is the GF
% calculated from the first RSRP value, i.e. the average power for the first transmit antenna port.

% Assume equal power in each sector tx
pwr_mW_perSC_perMIMOtx = (10^(0.1 * tx_pwr_dBm) / nSC / mimo_no_tx);
sector_pwr = pwr_mW_perSC_perMIMOtx * ones(l.no_tx*no_sectors, 1);

rsrp_p0 = zeros(l.no_rx, l.no_tx*no_sectors);

% Calculate the RSRP value from the first transmit antenna:
for ir = 1:l.no_rx
    for it = 1:l.no_tx * no_sectors
        tmp = c(ir, it).coeff(:, 1, :); % Coefficients from first Tx antenna
        rsrp_p0(ir, it) = (sector_pwr(it)) * sum(abs(tmp(:)).^2) / l.rx_array(1, 1).no_elements; % Divide by num Rx antennas
    end
end

[rsrp_max, cell_id] = max(rsrp_p0(:, :), [], 2);
cell_id = reshape(cell_id, n_y_coords, n_x_coords);
rsrp_dBm = 10 * log10(rsrp_max);
rsrp_2d = reshape(rsrp_dBm, n_y_coords, n_x_coords);
interf_dBm = 10 * log10(sum(rsrp_p0(:, :), 2)-rsrp_max);

% Calculate wideband SINR
sinr_dB = zeros(l.no_rx, 1);
sinr_dB(:) = rsrp_dBm - interf_dBm;
sinr_2d = reshape(sinr_dB, n_y_coords, n_x_coords);

% Calculate map variable needed by CCO algorithm
map = {}; %{n_y_coords*n_x_coords×no_sectors: double}
for b = 1:l.no_tx
    map_i = zeros(n_y_coords, n_x_coords, no_sectors);
    for i = 1:no_sectors
        n = (b - 1) * no_sectors + i;
        map_i(:, :, i) = reshape(rsrp_p0(:, n), n_y_coords, n_x_coords);
    end
    map{b} = map_i;
end

%% SAVE DATA
% % create a struct where powers over the x,y grid are available for each tx on an x,y grid
powermatrix = struct;
powermatrix.x = x_coords;
powermatrix.y = -y_coords;
powermatrix.z = rx_height;
powermatrix.ptx = pwr_mW_perSC_perMIMOtx; % power in watts
powermatrix.downtilt = squeeze(orientations(:, 2));
%map is (y,x,no_rxant,no_rxant) x no_tx
for i = 1:l.no_tx
    powermatrix.(append('Tx', int2str(i), 'pwr')) = 10 * log10(squeeze(map{i})); % dBm
    powermatrix.(append('Tx', int2str(i), 'loc')) = l.tx_position(:, i);
end
if save_results == 1
    if ~exist([pwd, '/savedResults/json'], 'dir')
        mkdir([pwd, '/savedResults/json']);
    end
    if ~exist([pwd, '/savedResults/npz'], 'dir')
        mkdir([pwd, '/savedResults/npz']);
    end
    file_name = append('powermatrixDT', num2str(round(downtilt)));
    jsonStr = jsonencode(powermatrix);
    fid = fopen(['savedResults/json/', file_name, '.json'], 'w');
    if fid == -1, error('Cannot create JSON file'); end
    fwrite(fid, jsonStr, 'char');
    fclose(fid);
    commandStr = sprintf('%s pyScripts/make_npz_from_json.py %s', python_path, file_name);
    fprintf('\tAttempting to write to NPZ file...')
    status = system(commandStr);
    if ~(status == 0)
        error('Cannot create NPZ file!');
    else
        fprintf('success.\n')
    end
end

%% PLOTS

if show_plot

    %Antenna element vertical radiation pattern (dB)
    theta = tx_array_3GPP_3d.elevation_grid.' * 180 / pi;
    % Antenna element horizontal radiation pattern (dB)
    phi = tx_array_3GPP_3d.azimuth_grid * 180 / pi;
    figure(100);
    clf;
    meshc(phi, theta, 10*log10(abs(tx_array_3GPP_3d.Fa).^2));
    xlabel('\phi');
    ylabel('\theta');
    zlabel('A(\theta,\phi) (dB)');
    title('Antenna pattern');
    colorbar;
    view([45, 45])

    figure('Renderer', 'painters', 'Position', [10, 10, 1000, 1500]); clf
    % Cell ID
    %Heatmap
    subplot(321)
    imagesc([x_min, x_max], [y_min, y_max], cell_id);
    c1 = colorbar;
    c1.Location = 'northoutside';
    c1.Label.String = "Cell ID";
    axis([x_min, x_max, y_min, y_max]);
    axis square;
    hold on
    for b = 1:l.no_tx
        plot(l.tx_position(1, b), -l.tx_position(2, b), ...
            '.r', 'Linewidth', 3, 'Markersize', 24);
        hold on;
    end
    xlabel('x (m)');
    ylabel('y (m)');
    grid on;

    %CDF
    subplot(322);
    %     cdf_data = cell_id(:);
    %     cdf_data_min = min(cdf_data);
    %     cdf_data_max = max(cdf_data);
    %     cdf_data_mean = mean(cdf_data);
    %     bins = cdf_data_min:1:cdf_data_max;
    %     stem(bins, 100*qf.acdf(cdf_data, bins), '-r', 'Linewidth', 3);
    %     grid on;
    %     xlabel('Cell ID');
    %     ylabel('CDF (%)');
    %     axis square;
    %     title(sprintf('(min,max,avg)=(%0.0f,%0.0f,%0.0f)', cdf_data_min, cdf_data_max, cdf_data_mean));

    h = histogram(cell_id, 'Normalization', 'probability', 'FaceColor', 'red', 'LineWidth', 2);
    axis square;
    grid on;
    ylabel('PDF');
    xlabel('Cell ID');

    %     %Coupling loss
    %     %Heatmap
    %     figure('Renderer', 'painters', 'Position', [10, 10, 1000, 1000]);
    %     clf;
    %     subplot(121);
    %     imagesc([x_min, x_max], [y_min, y_max], coupling_loss_2d);
    %     c1 = colorbar;
    %     c1.Location = 'northoutside';
    %     c1.Label.String = "Coupling loss (dB)";
    %     axis([x_min, x_max, y_min, y_max]);
    %     axis square;
    %     hold on
    %     for b = 1:l.no_tx
    %         plot(l.tx_position(1, b), -l.tx_position(2, b), ...
    %             '.r', 'Linewidth', 3, 'Markersize', 24);
    %         hold on;
    %     end
    %     xlabel('x (m)');
    %     ylabel('y (m)');
    %     grid on;
    %
    %     %CDF
    %     subplot(122);
    %     cdf_data = coupling_loss_2d(:);
    %     cdf_data_min = min(cdf_data);
    %     cdf_data_max = max(cdf_data);
    %     cdf_data_mean = mean(cdf_data);
    %     bins = cdf_data_min:0.01:cdf_data_max;
    %     plot(bins, 100*qf.acdf(cdf_data, bins), '-r', 'Linewidth', 3);
    %     grid on;
    %     xlabel('Coupling loss (dB)');
    %     ylabel('CDF (%)');
    %     axis square;
    %     title(sprintf('(min,max,avg)=(%0.0f,%0.0f,%0.0f)', cdf_data_min, cdf_data_max, cdf_data_mean));

    % RSRP
    %Heatmap
    %figure('Renderer', 'painters', 'Position', [10, 10, 1000, 1000]); clf
    subplot(323);
    imagesc([x_min, x_max], [y_min, y_max], rsrp_2d);
    c1 = colorbar;
    %caxis([-120, -60]);
    c1.Location = 'northoutside';
    c1.Label.String = "RSRP (dBm)";
    axis([x_min, x_max, y_min, y_max]);
    axis square;
    hold on
    for b = 1:l.no_tx
        plot(l.tx_position(1, b), -l.tx_position(2, b), ...
            '.r', 'Linewidth', 3, 'Markersize', 24);
        hold on;
    end
    xlabel('x (m)');
    ylabel('y (m)');
    grid on;

    %CDF
    subplot(324);
    cdf_data = rsrp_2d(:);
    cdf_data_min = min(cdf_data);
    cdf_data_max = max(cdf_data);
    cdf_data_mean = mean(cdf_data);
    bins = cdf_data_min:0.01:cdf_data_max;
    plot(bins, 100*qf.acdf(cdf_data, bins), '-r', 'Linewidth', 3);
    grid on;
    xlabel('RSRP (dBm)');
    ylabel('CDF (%)');
    axis square;
    title(sprintf('(min,max,avg)=(%0.0f,%0.0f,%0.0f)', cdf_data_min, cdf_data_max, cdf_data_mean));

    % Geometry factor (=SINR)
    %Heatmap
    %figure('Renderer', 'painters', 'Position', [10, 550, 1000, 500]);
    %clf;
    subplot(325);
    imagesc([x_min, x_max], [y_min, y_max], sinr_2d);
    caxis([-5, 20]);
    c1 = colorbar;
    c1.Location = 'northoutside';
    c1.Label.String = "Geometry factor (dB)";
    axis([x_min, x_max, y_min, y_max]);
    axis square;
    hold on
    for b = 1:l.no_tx
        plot(l.tx_position(1, b), -l.tx_position(2, b), ...
            '.r', 'Linewidth', 3, 'Markersize', 24);
        hold on;
    end
    xlabel('x (m)');
    ylabel('y (m)');
    grid on;

    %CDF
    subplot(326);
    cdf_data = sinr_2d(:);
    cdf_data_min = min(cdf_data);
    cdf_data_max = max(cdf_data);
    cdf_data_mean = mean(cdf_data);
    bins = cdf_data_min:0.01:cdf_data_max;
    plot(bins, 100*qf.acdf(cdf_data, bins), '-r', 'Linewidth', 3);
    grid on;
    xlabel('Geometry factor (dB)');
    ylabel('CDF (%)');
    axis square;
    title(sprintf('(min,max,avg)=(%0.0f,%0.0f,%0.0f)', cdf_data_min, cdf_data_max, cdf_data_mean));

    for t = 1:l.no_tx
        scen = zeros(length(l.rx_track), 1);
        for r = 1:length(l.rx_track)
            switch char(l.rx_track(r).scenario(t))
                case '3GPP_3D_UMi_LOS'
                    scen(r) = 0;
                case '3GPP_3D_UMi_NLOS'
                    scen(r) = 1;
                otherwise
                    scen(r) = nan;
            end
        end
        scen_2d(:, :, t) = reshape(scen, n_y_coords, n_x_coords);
        f = figure(200+t); clf
        imagesc([x_min, x_max], [y_min, y_max], scen_2d(:, :, t));
        hold on;
        axis([x_min, x_max, y_min, y_max]);
        axis square;
        colormap(f, gray(2));
        for b = 1:l.no_tx
            plot(l.tx_position(1, b), -l.tx_position(2, b), ...
                '.r', 'Linewidth', 3, 'Markersize', 24);
            hold on;
        end
        xlabel('x (m)');
        ylabel('y (m)');
        grid on; title('{3GPP\_3D\_UMi}:Black=LOS,White=NLOS')
    end

end

% End of post processing
fprintf('done.\n');

%% END OF PROGRAM
fprintf('\n[Simulation] runtime: %.1f s = %1.1f min (%.0f UE/sec.)\n', toc(big_tic), toc(big_tic)/60, l.no_rx/toc(big_tic));
if clean_code
    MBeautify.formatCurrentEditorPage()
end
