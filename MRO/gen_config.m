%% Create configuration file
% Should specify the information necessary to reproduce the simulation,
% although the exact builder object must be used for perfect reconstruction

% config file should have tx locations, rx start, heading, speed, end, the
% antenna descriptions, and scenario.

% assumes save_folder is defined by the simulation
file = fopen(strcat(save_folder,'simulation_config.txt'),'wt');
BW = 10e6;
num_RBs = 50;

% header information
headers = {'UE Information '; 'number of UEs: '};
fillers = {'\n'; l.no_rx};

for i=1:l.no_rx
    headers{end+1} = ['UE ' num2str(i) ' initial position: '];
    fillers{end+1} = l.rx_track(i).initial_position;
    
    headers{end+1} = ['UE ' num2str(i) ' velocity: '];
    fillers{end+1} = l.rx_track(i).positions(:, end)/total_time;
    
    headers{end+1} = ['UE ' num2str(i) ' end position: '];
    fillers{end+1} = l.rx_track(i).initial_position + l.rx_track(i).positions(:, end);
    
    headers{end+1} = ['UE ' num2str(i) ' initial attachment: '];
    fillers{end+1} = '1 \n'; %TODO figure out a clean way of determining this???
    
end

headers{end+1} = 'BS Information ';
fillers{end+1} = '\n';

headers{end+1} = 'number of BS: ';
fillers{end+1} = [num2str(l.no_tx) ' \n'];
    
for i=1:l.no_tx 
    headers{end+1}= ['BS ' num2str(i) ' location: '];
    headers{end+1}= ['BS ' num2str(i) ' number of sectors: '];
    headers{end+1}= ['BS ' num2str(i) ' azimuth rotations (degrees): '];
    headers{end+1}= ['BS ' num2str(i) ' downtilts (degrees): '];
%     headers{end+1}= ['BS ' num2str(i) ' Transmit Powers (dBm): '];
    headers{end+1}= ['BS ' num2str(i) ' azimuth beamwidth (degrees): '];
    headers{end+1}= ['BS ' num2str(i) ' elevation beamwidth (degrees): '];
    headers{end+1}= ['BS ' num2str(i) ' front-to-back ratio (dB): '];
    
    fillers{end+1} = l.tx_position(:, i);
    fillers{end+1} = l.tx_array(1, i).no_elements;
    if exist('orientations', 'var')
        fillers{end+1} = orientations((i-1)*N_SECTORS+1:i*N_SECTORS, 2);
        fillers{end+1} = orientations((i-1)*N_SECTORS+1:i*N_SECTORS, 1);
    else
        fillers{end+1} = -1;
        fillers{end+1} = -1;
    end
    if exist('Tx_P_dBm', 'var')
%         fillers{end+1} = [Tx_P_dBm, Tx_P_dBm, Tx_P_dBm];
    else
        fillers{end+1} = -1;
    end
    if exist('AZI_BEAMWIDTH', 'var')
        fillers{end+1} = AZI_BEAMWIDTH;
    else
        fillers{end+1} = -1;
    end
    if exist('ELE_BEAMWIDTH', 'var')
        fillers{end+1} = ELE_BEAMWIDTH;
    else
        fillers{end+1} = -1;
    end
    if exist('FB_RATIO_DB', 'var')
        fillers{end+1} = [num2str(FB_RATIO_DB), ' \n'];
    else
        fillers{end+1} = '-1 \n';
    end
end

headers{end+1} = '\nSimulation Parameters ';
headers{end+1} = 'Carrier Frequency (Hz): ';
headers{end+1} = 'Sampling Frequency (Hz): ';
headers{end+1} = 'Samples: ';
headers{end+1} = 'Bandwidth (MHz): ';
headers{end+1} = 'Resource Blocks: ';
headers{end+1} = 'Simulation duration (s): ';

fillers{end+1} = '\n';
fillers{end+1} = s.center_frequency;
fillers{end+1} = fs;
[~, samples] = size(l.rx_track(1).positions);
fillers{end+1} = samples;
fillers{end+1} = BW/1e6;
fillers{end+1} = num_RBs;
fillers{end+1} = samples/fs;


len = length(headers);

for i=1:len
    fprintf(file, headers{i});
    if ~isstring(fillers{i}) && ~ischar(fillers{i})
        output_val = compose("%f ", round(fillers{i}, 6));
        for j=1:length(output_val)
            fprintf(file, output_val(j));
        end
    else
        fprintf(file, fillers{i});
    end
    fprintf(file, '\n');
end

fclose(file);

%% Generate README
file = fopen(strcat(save_folder,'README.txt'),'wt');
fprintf(file, "This file describes the other files contained within this folder. \n\n");
fprintf(file, "The configuration file (simulation_config.txt) describes the simulation used to generate the data within this folder.\n");
fprintf(file, "Values with a -1 are not useful for defining this simulation, but may be used for others. \nGenerally locations are given as x, y, z relative to the center of the simulation and \nheadings are in radians where 0 means in the positive x direction and pi/2 would be in the positive y direction.");
fprintf(file, "\nUnits are in seconds, meters, meters per second, or hertz.\n\n");
fprintf(file, "The configuration file is formatted thusly:\n");
fprintf(file, "UE Information \n\tInformation relevant for the movement of the UEs.\n\n");
fprintf(file, "BS Information \n\tInformation describing the base stations and its sectors.\n\n");
fprintf(file, "Simulation Paramters \n\tOverall parameters such as carrier frequency and sampling rate.\n\n");

fprintf(file, "Remaining files, which begin with ULDL_Channel_Response, are the traces of the channel response between a UE and an eNB, \nspecified by the trace title. The files are created by simulation with the QuaDRiGa channel simulator and the following additional parameters:\n");
test_str = ['UE height: ' num2str(ue_height) 'm\nUE antenna model: ' l.rx_array(1).name '\nBS Antenna Model: ' l.tx_array(1, 1).name '\nScenario: ' scen '\nTransmit power per sector: ', num2str(Tx_P_dBm) 'dBm and seed: ' num2str(seed)];
fprintf(file, test_str);