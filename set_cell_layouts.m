%% Antenna Definitions
FB_ratio = 10^(FB_RATIO_DB/10);           % Front to back ratio in linear scale


if ismac
    if strcmp(python_path, 'python')
        disp("You are using a Mac, please remember to set your python path in initialize_sim");
        python_path = input("Please input the python path here:", 's');
    end
end
% Path definitions
if save_work == 1
    if downtilt == 4
        track_directory = ['tracks/DT',num2str(round(downtilt)),'/',num2str(TX_P),'W/',datestr(now,'mm-dd-HH-MM'),'/'];
    else
        track_directory = ['tracks/DT',num2str(round(downtilt)),'/',datestr(now,'mm-dd-HH-MM'),'/'];
    end
    mkdir(track_directory);
else
    track_directory = '\';
end


%% grid packing
fprintf('\tDropping BS location ')
orientations = [];

switch BS_drop
    
    case 'csv'
        
        fprintf('\tLoading CSV file...')
        % Read the csv file for BS locations and sector orientations using the python helper functions
        commandStr = sprintf('%s python_helpers/Tx_Information_from_csv.py %s',python_path,fixed_cvs_file);
        [status output] = system(commandStr);
        locs = str2num(output);
        if(size(locs) < 1)
            disp("There was a problem with your python, traceback:");
            error(output)
        end
        commandStr = sprintf('%s python_helpers/Tx_Sector_Information_from_csv.py %s',python_path,fixed_cvs_file);
        [status, output] = system(commandStr);
        if status==0
            fprintf('success.\n')
        end
        orientations = str2num(output);
        no_BS = size(locs,1);
        
    case "rnd"
        
        boundary_xy = 0.8*max_xy;
        locs_xy = zeros(no_BS, 2);
        locs_xy(1,:) = -boundary_xy+2*boundary_xy*rand(1,2);
        counter = 1;
        while counter<no_BS
            candidate_point = -boundary_xy+2*boundary_xy*rand(1,2);
            d = sqrt((locs_xy(1:counter,1)-candidate_point(1)).^2+(locs_xy(1:counter,2)-candidate_point(2)).^2);
            if d > MIN_BS_SEP
                fprintf('%i/',counter)
                counter = counter + 1;
                locs_xy(counter,:) = candidate_point;
            end
        end
        
        locs_z = MIN_HEIGHT + (MAX_HEIGHT-MIN_HEIGHT) .* rand(no_BS, 1);
        locs = [locs_xy, locs_z];
        
    case 'hex'
        l = qd_layout.generate('regular', no_BS, MIN_BS_SEP);
        locs = (l.tx_position).';
        locs_z = MIN_HEIGHT + (MAX_HEIGHT-MIN_HEIGHT) .* rand(no_BS, 1);
        locs(:,3) = locs_z;
end

fprintf('\n')
% orientations should be [no_bs*no_sectors_per_bs, 2] (2 = [azimuth, downtilt])
if isempty(orientations)
    if random_ori_azi
        ori_azi = -180 + 360 * rand(no_BS*N_SECTORS, 1);
    else
        ori_azi = repmat(0:floor(360/N_SECTORS):360-floor(360/N_SECTORS),1,no_BS).';
    end
    
    if downtilt == -1
        ori_dt = MIN_DT + (MAX_DT-MIN_DT) .* rand(no_BS*N_SECTORS, 1);
    else
        ori_dt = ones(no_BS*N_SECTORS, 1);
    end
    orientations = [ori_azi, ori_dt];
end

%% Simulation initializers
s = qd_simulation_parameters;             % New simulation parameters
s.center_frequency = FC;                  % 1.8 GHz carrier frequency middle of lte band 3
s.sample_density = 1;                     % num samples per half-wavelength
s.use_absolute_delays = 1;                % Include delay of the LOS path
s.show_progress_bars = 1;                 % Enable progress bars; set to 0 to disable progress bars
s.use_3GPP_baseline = 1;

l = qd_layout(s);
l.set_scenario(scen{1});
[l.no_tx,~]=size(locs);
for i=1:l.no_tx
    l.tx_position(:, i) = locs(i, :);
end

[l.no_tx, ~] = size(locs);
num_interf = l.no_tx - 1;                  % number of interfering bases stations

%% Specify Sector Antennas
% Use csv defined orientations and downtilts
if downtilt == -1
    for i=1:l.no_tx
        index = N_SECTORS*(i-1)+1;
        l.tx_array(i) = qd_arrayant(ARRAY_TYPE, AZI_BEAMWIDTH, ELE_BEAMWIDTH, -FB_RATIO_DB, orientations(index, 2));
        l.tx_array(i).rotate_pattern(orientations(index, 1), 'z');
        % fprintf('antenna %d sector 1 with dt = %d and azi = %d \n', i, orientations(index, 2), orientations(index, 1));
        
        for j=1:N_SECTORS-1
            a = qd_arrayant(ARRAY_TYPE, AZI_BEAMWIDTH, ELE_BEAMWIDTH, -FB_RATIO_DB, orientations(index+j, 2));
            a.rotate_pattern(orientations(index+j, 1), 'z');
            l.tx_array(i).append_array(a);
        end
        l.tx_array(i).center_frequency = FC;
    end
    
else
    % Use the same downtilt for all sectors
    if isscalar(downtilt)
        for i=1:l.no_tx
            index = 3*(i-1)+1;
            l.tx_array(i) = qd_arrayant(ARRAY_TYPE, M, N, FC, pol, downtilt, spacing, Mg, Ng, [], []);
            %l.tx_array(i) = qd_arrayant(ARRAY_TYPE, AZI_BEAMWIDTH, ELE_BEAMWIDTH, -FB_RATIO_DB, downtilt);
            l.tx_array(i).rotate_pattern(orientations(index, 1), 'z');
            for j=1:N_SECTORS-1
                a = qd_arrayant(ARRAY_TYPE, M, N, FC, pol, downtilt, spacing, Mg, Ng, [], []);
                %a = qd_arrayant(ARRAY_TYPE, AZI_BEAMWIDTH, ELE_BEAMWIDTH, -FB_RATIO_DB, downtilt);
                a.rotate_pattern(orientations(index+j, 1), 'z');
                l.tx_array(i).append_array(a);
            end
            l.tx_array(i).center_frequency = FC;
        end
        orientations(:, 2) = downtilt;
        % Use vector defined downtilt for each sector
    else
        error("Vectored downtilts are not prepared to be used yet, stop the simulation and change the downtilt.")
    end
    
end


