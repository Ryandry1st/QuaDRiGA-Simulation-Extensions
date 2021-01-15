function mvrcQv2_main(params)

if nargin == 0
    params = mvrcQv2_init;
end

big_tic = tic;

%% Drop users
fprintf('[Generate layout]');
layout_tic = tic;

n_coords = ceil(sqrt(params.no_rx_min))^2;
max_xy = floor((params.sample_distance*floor(sqrt(n_coords))-1)/2);
x_min = -max_xy;
x_max = -x_min;
y_min = x_min;
y_max = -y_min;
x_coords = x_min:params.sample_distance:x_max;
y_coords = y_max:-params.sample_distance:y_min;
n_x_coords = numel(x_coords);
n_y_coords = numel(y_coords);
no_rx = n_coords;

fprintf('\n\tDropping %d users in a [%d x %d](m) grid...', no_rx, max_xy, max_xy);
[Xn, Yn] = meshgrid(x_coords, y_coords);
rx_point = zeros(3, no_rx);
for n = 1:no_rx
    rx_point(:, n) = [Xn(n); Yn(n); params.rx_height];
end
fprintf('done.\n')

%% Drop basestations

fprintf('\tSetting tx positions...');
orientations = [];

switch params.BS_drop
    
    case 'csv'
        fprintf('\tLoading CSV file...')
        % Read the csv file for BS locations and sector orientations using the python helper functions
        commandStr = sprintf('%s pyScripts/Tx_Information_from_csv.py %s', params.python_path, params.fixed_cvs_file);
        [status1, output] = system(commandStr);
        tx_locs = str2num(output);
        if (size(tx_locs) < 1)
            disp("There was a problem with your python, traceback:");
            error(output)
        end
        commandStr = sprintf('%s pyScripts/Tx_Sector_Information_from_csv.py %s', params.python_path, params.fixed_cvs_file);
        [status2, output] = system(commandStr);
        if status1 == 0 && status2 == 0
            fprintf('success.\n')
        end
        orientations = str2num(output);
        params.no_tx = size(tx_locs, 1);
        
    case "rnd"
        boundary_xy = 0.9 * max_xy;
        locs_xy = zeros(params.no_tx, 2);
        locs_xy(1, :) = -boundary_xy + 2 * boundary_xy * rand(1, 2);
        counter = 1;
        while counter < params.no_tx
            candidate_point = -boundary_xy + 2 * boundary_xy * rand(1, 2);
            d = sqrt((locs_xy(1:counter, 1)-candidate_point(1)).^2+(locs_xy(1:counter, 2) - candidate_point(2)).^2);
            if d > params.isd
                counter = counter + 1;
                locs_xy(counter, :) = candidate_point;
            end
        end
        locs_z = params.tx_height_min + (params.tx_height_max - params.tx_height_min) .* rand(params.no_tx, 1);
        tx_locs = [locs_xy, locs_z];
        fprintf('done.\n');
        
    case 'hex'
        l_tmp = qd_layout.generate('regular', params.no_tx, params.isd);
        tx_locs = (l_tmp.tx_position).';
        locs_z = params.tx_height_min + (params.tx_height_max - params.tx_height_min) .* rand(params.no_tx, 1);
        tx_locs(:, 3) = locs_z;
        fprintf('done.\n');
end

%% Generate layout object
l = qd_layout(params.s);
l.simpar = params.s; % Set simulation parameters
l.name = params.chn_scenario;
l.no_rx = no_rx;
l.no_tx = params.no_tx;
for i = 1:l.no_tx
    l.tx_position(:, i) = tx_locs(i, :);
end
fprintf('\tSetting rx positions...');
l.rx_position = rx_point;
fprintf('done.\n');

% tx array
if isempty(orientations)
    ori_azi = repmat((0:floor(360 / params.no_sectors):360-floor(360 / params.no_sectors)), 1, params.no_tx).' + 30;
    ori_azi(ori_azi > 180) = ori_azi(ori_azi > 180) - 360;
    if params.random_ori_azi
        ori_azi = -180 + 360 * rand(params.no_tx*params.no_sectors, 1);
    end
    ori_dt = params.downtilt * ones(params.no_tx*params.no_sectors, 1);
    orientations = [ori_azi, ori_dt];
end

fprintf('\tSetting tx antenna arrays...');
for i = 1:l.no_tx
    fprintf('%d(of %d)/',i,l.no_tx);
    index = params.no_sectors * (i - 1) + 1;
    for j = 1:params.no_sectors
        n = index + j - 1;
        theta_n = orientations(n, 2);
        switch params.tx_antenna_type
            case '3gpp-macro'
                tx_array_cpy(j) = qd_arrayant('3gpp-macro', params.tx_antenna_3gpp_macro.phi_3dB, params.tx_antenna_3gpp_macro.theta_3dB, params.tx_antenna_3gpp_macro.rear_gain, theta_n);
            case '3gpp-3d'
                tx_array_cpy(j) = qd_arrayant('3gpp-3d', params.tx_antenna_3gpp_3d.M, params.tx_antenna_3gpp_3d.N, params.tx_antenna_3gpp_3d.center_freq, params.tx_antenna_3gpp_3d.pol, theta_n, params.tx_antenna_3gpp_3d.spacing);
        end
    end
    tx_array_i = copy(tx_array_cpy(1));
    no_el = tx_array_i.no_elements;
    for j = 2:params.no_sectors
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
fprintf('done.\n');

% rx array
l.rx_array = params.a_mt;
fprintf('\tSetting layout scenarios for all users...');
l.set_scenario(params.chn_scenario, [], [], params.indoor_frc, params.SC_lambda_rx, params.SC_lambda_tx);
fprintf('done.\n');

if params.save_layout
    fprintf('\nSaving layout file...')
    if ~exist([pwd, '/savedLayouts'], 'dir')
        mkdir(pwd, '/savedLayouts');
    end
    save('savedLayouts/layout.mat', '-v7.3', 'l', 'x_min', 'x_max', 'y_min', 'y_max', 'x_coords', 'y_coords', 'n_x_coords', 'n_y_coords', 'params.sample_distance', 'params.no_rx_min');
    fprintf('success.\n');
end
%l.visualize([],[],0);axis square
fprintf('[Generate layout] runtime = %1.0f min\n', toc(layout_tic)/60);

%% Generate channels
% Channels are now generated using the default QuaDRiGa method (phase 1 only used the LOS path).
% This w1l take quite some time.
generate_channels_tic = tic;

if params.save_load_channels
    try
        load([pwd, '/savedBuilders/builder_obj.mat']);
        fprintf("Found a builder!\n");
        % replace the base station transmitters with the new ones
        for i=1:numel(p_builder)
            p_builder(1, i).tx_array(1, :) = l.tx_array(i).copy();
        end
        cl = merge(get_channels(p_builder));
    catch
        fprintf("Could not find builder or channel data, recalculating. \n");
        [cl, p_builder] = l.get_channels; % Generate channels

        if ~exist([pwd, '/savedBuilders'], 'dir')
            mkdir(pwd, '/savedBuilders');
        end
        save([pwd, '/savedBuilders/builder_obj.mat'], '-v7.3', 'p_builder');
    end
end

nEl = l.tx_array(1, 1).no_elements / 3; % Number of elements per sector
nEl = {1:nEl, nEl + 1:2 * nEl, 2 * nEl + 1:3 * nEl}; % Element indices per sector
fprintf('Spliting channels between sectors...');
c(:, :) = split_tx(cl, nEl); % Split channels from each sector
fprintf('success.');
fprintf('\n[Generate channels] runtime = %1.3f min\n', toc(generate_channels_tic)/60)

%% POSTPROCESSING
fprintf('Post processing...');

%Coupling Loss
pg_eff = zeros(l.no_rx, l.no_tx*params.no_sectors); % Calculate the effective path gain from the channels

mimo_no_tx = l.tx_array(1, 1).no_elements / params.no_sectors;
mimo_no_rx = l.rx_array(1, 1).no_elements;
no_mimo_links = mimo_no_tx * mimo_no_rx; % Get the number of MIMO sub-channels in the channel matrix

for ir = 1:l.no_rx % Extract effective PG vor each BS-MT link
    for it = 1:l.no_tx * params.no_sectors
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
pwr_mW_perSC_perMIMOtx = (10^(0.1 * params.tx_pwr_dBm) / params.nSC / mimo_no_tx);
sector_pwr = pwr_mW_perSC_perMIMOtx * ones(l.no_tx*params.no_sectors, 1);

rsrp_p0 = zeros(l.no_rx, l.no_tx*params.no_sectors);

% Calculate the RSRP value from the first transmit antenna:
for ir = 1:l.no_rx
    for it = 1:l.no_tx * params.no_sectors
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
map = {}; %{n_y_coords*n_x_coords×params.no_sectors: double}
for b = 1:l.no_tx
    map_i = zeros(n_y_coords, n_x_coords, params.no_sectors);
    for i = 1:params.no_sectors
        n = (b - 1) * params.no_sectors + i;
        map_i(:, :, i) = reshape(rsrp_p0(:, n), n_y_coords, n_x_coords);
    end
    map{b} = map_i;
end

%% SAVE DATA
% % create a struct where powers over the x,y grid are available for each tx on an x,y grid
powermatrix = struct;
powermatrix.x = x_coords;
powermatrix.y = -y_coords;
powermatrix.z = params.rx_height;
powermatrix.ptx = pwr_mW_perSC_perMIMOtx; % power in mW
powermatrix.downtilt = squeeze(orientations(:, 2));
%map is (y,x,no_rxant,no_rxant) x params.no_tx
for i = 1:l.no_tx
    powermatrix.(append('Tx', int2str(i), 'pwr')) = 10 * log10(squeeze(map{i})); % dBm
    powermatrix.(append('Tx', int2str(i), 'loc')) = l.tx_position(:, i);
end
if params.save_results == 1
    if ~exist([pwd, '/savedResults/json'], 'dir')
        mkdir([pwd, '/savedResults/json']);
    end
    if ~exist([pwd, '/savedResults/npz'], 'dir')
        mkdir([pwd, '/savedResults/npz']);
    end
    if ~exist([pwd, '/savedResults/mat'], 'dir')
        mkdir([pwd, '/savedResults/mat']);
    end
    
    file_name = append('powermatrixDT', num2str(round(params.downtilt)));
    save([pwd, '/savedResults/mat/', file_name], 'no_rx', 'tx_locs', 'n_x_coords', 'n_y_coords', 'x_min', 'x_max', 'y_min', 'y_max', 'cell_id', 'rsrp_2d', 'sinr_2d', 'params', '-v7.3');
    
    jsonStr = jsonencode(powermatrix);
    fid = fopen(['savedResults/json/', file_name, '.json'], 'w');
    if fid == -1, error('Cannot create JSON file'); end
    fwrite(fid, jsonStr, 'char');
    fclose(fid);
    commandStr = sprintf('%s pyScripts/make_npz_from_json.py %s', params.python_path, file_name);
    fprintf('Attempting to write to NPZ file...')
    status = system(commandStr);
    if ~(status == 0)
        error('Cannot create NPZ file!');
    else
        fprintf('success.\n')
    end
end

%% END OF PROGRAM
fprintf('[Simulation] runtime: %.1f s = %1.1f min (%.0f UE/sec.)\n', toc(big_tic), toc(big_tic)/60, no_rx/toc(big_tic));
if params.clean_code
    MBeautify.formatCurrentEditorPage()
end

return