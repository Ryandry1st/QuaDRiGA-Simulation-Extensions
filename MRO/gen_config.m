%% Create configuration file
% Should specify the information necessary to reproduce the simulation,
% although the exact builder object must be used for perfect reconstruction

% config file should have tx locations, rx start, heading, speed, end, the
% antenna descriptions, and scenario.

% assumes save_folder is defined by the simulation
file = fopen(strcat(save_folder,'simulation_config.txt'),'wt');

% header information
headers = {'\nUE Information'; 'number UEs: '; 'Initial positions: '; 
    'Headings (radians): '; 'Speeds (m/s): '; 'End positions: '; 'UE Antennas: '; '\nBS Information';
    'number BS: '};

fillers = {'\n'; l.no_rx; l.rx_track.initial_position; heading; speed; 
    l.rx_track.initial_position + l.rx_track.positions(:, end-1); l.rx_array.name; 
    ''; l.no_tx};
    
for i=1:l.no_tx
    headers{end+1} = strcat('\nBS', num2str(i));
    fillers{end+1} = '';
    
    headers{end+1}= 'Location: ';   
    headers{end+1}= 'Azimuth rotations (degrees): ';
    headers{end+1}= 'Antenna Type: ';
    headers{end+1}= 'Downtilts (degrees): ';
    headers{end+1}= 'Azimuth beamwidth (degrees): ';
    headers{end+1}= 'Elevation beamwidth (degrees): ';
    headers{end+1}= 'Front-to-back ratio (dB): ';
    
    fillers{end+1} = l.tx_position(:, i);
    fillers{end+1} = -1;
    fillers{end+1} = l.tx_array(i).name;
    fillers{end+1} = -1;
    fillers{end+1} = -1;
    fillers{end+1} = -1;
    fillers{end+1} = -1;

end

headers{end+1} = '\nSimulation Parameters';
headers{end+1} = 'Carrier Frequency (Hz): ';
headers{end+1} = 'Sampling Frequency (Hz): ';
headers{end+1} = 'Scenario: ';
% headers{end+1} = 'Simulation time: ';
headers{end+1} = 'Samples: ';
headers{end+1} = 'Bandwidth (MHz): ';
headers{end+1} = 'Resource Blocks: ';

fillers{end+1} = '\n';
fillers{end+1} = s.center_frequency;
fillers{end+1} = fs;
fillers{end+1} = scen;
% fillers{end+1} = total_time;
[~, ~, ~, len] = size(c(1).coeff);
fillers{end+1} = len;
fillers{end+1} = BW/1e6;
fillers{end+1} = num_RBs;


len = length(headers);

fprintf(file, "This configuration file describes the simulation used to generate the data within this folder. \nValues with a -1 are not useful for defining this simulation, but may be used for others. \nGenerally locations are given as x, y, z relative to the center of the simulation \nand headings are in radians where 0 means in the positive x direction and pi/2 would be in the positive y direction.\nUnits are in seconds, meters, meters per second, or hertz.\n \n");
for i=1:len
    fprintf(file, headers{i});
    if ~isstring(fillers{i}) && ~ischar(fillers{i})
        output_val = compose("%g  ", fillers{i});
        for j=1:length(output_val)
            fprintf(file, output_val(j));
        end
    else
        fprintf(file, fillers{i});
    end
    fprintf(file, ' \n');
end

fclose(file);