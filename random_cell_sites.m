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


%% Simulation initializers
s = qd_simulation_parameters;             % New simulation parameters
s.center_frequency = FC;               % 1.8 GHz carrier frequency middle of lte band 3
s.sample_density = 1;                     % num samples per half-wavelength
s.use_absolute_delays = 1;                % Include delay of the LOS path
s.show_progress_bars = 1;                 % Enable progress bars; set to 0 to disable progress bars
s.use_3GPP_baseline = 0;

%% grid packing
xy_inc = 1.9*(max_xy-OFFSET(1))/floor(sqrt(no_BS));

if sqrt(2*xy_inc^2) < MIN_BS_SEP
    error("Your average separation is only %f but you requested at least %i", sqrt(2*xy_inc^2), MIN_BS_SEP);
end
no_per_x_line = floor(sqrt(no_BS));
no_per_y_line = ceil(sqrt(no_BS)); % the last column may be undefilled
locs_z = MIN_HEIGHT + (MAX_HEIGHT-MIN_HEIGHT) .* rand(no_BS, 1);

locs_xy = zeros(no_BS, 2);

xlocs = [0:no_per_x_line-1].*(2*(max_xy-OFFSET(1, 1))/(no_per_x_line-1)) - max_xy+OFFSET(1, 1);
ylocs = [0:no_per_y_line-1].*(2*(max_xy-OFFSET(1, 2))/(no_per_y_line-1)) - max_xy+OFFSET(1, 2);

for i=0:no_BS-1
    j = floor(i/no_per_x_line)+1;
    k = mod(i, no_per_x_line)+1;
    locs_xy(i+1, :) = [xlocs(k), ylocs(j)] + sqrt(BS_LOC_VAR)*randn(1, 2);
end


locs = [locs_xy, locs_z];

% orientations should be [no_bs*no_sectors_per_bs, 2] (2 = [azimuth, downtilt]) 
ori_azi = 360 .* rand(no_BS*N_SECTORS, 1);
if downtilt == -1
    ori_dt = MIN_DT + (MAX_DT-MIN_DT) .* rand(no_BS*N_SECTORS, 1);
else
    ori_dt = ones(no_BS*N_SECTORS, 1);
end
orientations = [ori_azi, ori_dt];

l = qd_layout(s);                          % Create new QuaDRiGa layout
[l.no_tx, ~] = size(locs);
num_interf = l.no_tx - 1;                  % number of interfering bases stations

% assign positions based on the csv information
for i=1:l.no_tx
    l.tx_position(:, i) = locs(i, :)';
end

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
            l.tx_array(i) = qd_arrayant(ARRAY_TYPE, AZI_BEAMWIDTH, ELE_BEAMWIDTH, -FB_RATIO_DB, downtilt);
            l.tx_array(i).rotate_pattern(orientations(index, 1), 'z');
            for j=1:N_SECTORS-1
                a = qd_arrayant(ARRAY_TYPE, AZI_BEAMWIDTH, ELE_BEAMWIDTH, -FB_RATIO_DB, downtilt);
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


