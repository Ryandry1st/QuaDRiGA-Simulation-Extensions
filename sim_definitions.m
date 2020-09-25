%% Antenna Definitions
% ARRAY_TYPE = '3gpp-macro';          % Array type at bs, main options include: omni, dipole, half-wave-dipole, patch, 3gpp-macro, 3gpp (more available in generate.m)
% AZI_BEAMWIDTH = 67;                       % Azimuth beamwidth for sector antenna
% ELE_BEAMWIDTH = 7.5;                      % Elevation beamwidth for sector antenna
% FB_RATIO_DB = -30;                        % Front to back ratio in dB
 FB_ratio = 10^(FB_RATIO_DB/10);           % Front to back ratio in linear scale
% ANTENNA_ELEMENTS = 4;                     % Number of antenna elements in a sector
% FC = 1.8e9;                               % Carrier frequency
% N_SECTORS = 3;

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


%% Layout of transmitters & specification of antenna types
% Read the csv file for BS locations and sector orientations using the python helper functions
commandStr = strcat(python_path, ' Tx_Information_from_csv.py "Mavenir_locs.csv"');
[status, output] = system(commandStr);

locs = str2num(output);
if(size(locs) < 1)
    disp("There was a problem with your python, traceback:");
    error(output)
end

commandStr = strcat(python_path, ' Tx_Sector_Information_from_csv.py "Mavenir_locs.csv"');
[status, output] = system(commandStr);

orientations = str2num(output);

if(size(orientations) < 1)
    disp("There was a problem with your python, traceback:");
    error(output)
end

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
        index = 3*(i-1)+1;
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


