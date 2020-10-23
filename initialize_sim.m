if del_builder
    if exist([pwd,'/tracks/builder_obj.mat'], 'file')
        delete([pwd,'/tracks/builder_obj.mat']);
    end
end

max_xy = floor((grid_resolution*sqrt(nGrid)-1)/2);

Tx_P = 10^(0.1*Tx_P_dBm)/1000;

if no_BS <= 5
    sim_definitions;
else
    random_cell_sites;
end

tx_powers = ones(1, l.no_tx)*Tx_P_dBm;                  % assumes same power for all tx, can be changed

%% number of receiver & specification of antenna type; length and resolution of UE track
l.no_rx = 1;                                              % Number of UEs and tracks - one track per UE
l.rx_array = qd_arrayant('omni');                         % Omni antennas at Rx
l.rx_array.center_frequency = FC;
samp_per_meter = 0.25;                                    % samples per meter for track interpolation
track_length = 500;                                       % track length in meters; currently same for all l.no_rx UEs