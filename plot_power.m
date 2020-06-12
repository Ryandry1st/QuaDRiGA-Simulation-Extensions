figure
hold off;
hold on
title('Geometric mean of Signal power in dBm')
for track=1:l.no_rx
    h = cn(track).fr( 100e6,512 );                          % Freq.-domain channel
    h = squeeze(h);                                         % Remove singleton dimensions
    pwr = mean(20*log10(abs(h)))'+10*log10(512);            % calculate geometric mean sigpwr - should really be gm of SINR
    plot3(cn(track).rx_position(1,:)',cn(track).rx_position(2,:)',pwr')
end
grid;
xlabel('X coordinates');
ylabel('Y coordinates');


for interf=1:num_interf;
    figure;
    title('Interferer power from gNB')
    hold off;
    hold on;
    for track=1:l.no_rx
        h = cn(track+interf*l.no_rx).fr( 100e6,512 );                          % Freq.-domain channel
        h = squeeze(h);                                         % Remove singleton dimensions
        pwr = mean(20*log10(abs(h)))'+10*log10(512);            % calculate geometric mean sigpwr - should really be gm of SINR
        plot3(cn(track+interf*l.no_rx).rx_position(1,:)',cn(track+interf*l.no_rx).rx_position(2,:)',pwr')
    end
    grid;
    xlabel('X coordinates');
    ylabel('Y coordinates');
end
