%WidebandRSRP Calculate the wideband RSRP from the channel and transmitters
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

% Wideband SINR
% The wideband SINR is essentially the same as the GF. However, the 3GPP model uses the RSRP values
% for the calculation of this metric. The calculation method is described in 3GPP TR 36.873 V12.5.0
% in Section 8.1 on Page 38. Essentially, the RSRP values describe the average received power (over
% all antenna elements at the receiver) for each transmit antenna port. Hence, in the phase 2
% calibration, there are 4 RSRP values, one for each transmit antenna. The wideband SINR is the GF
% calculated from the first RSRP value, i.e. the average power for the first transmit antenna port.

% Assume equal power in each sector tx
pwr_mW_perSC_perMIMOtx = (10^(0.1 * Tx_P_dBm(1, 1)) / useful_fft_points / mimo_no_tx);
sector_pwr = pwr_mW_perSC_perMIMOtx * ones(l.no_tx*no_sectors);

rsrp_p0 = zeros(l.no_rx, l.no_tx*no_sectors, total_time*fs);

% Calculate the RSRP value from the first transmit antenna:
for ir = 1:l.no_rx
    for it = 1:l.no_tx * no_sectors
        for is = 1:total_time*fs
            tmp = c(ir, it).coeff(1, 1, :, is); % Coefficients from first Tx antenna
            rsrp_p0(ir, it, is) = 10*log10((sector_pwr(it)) * sum(abs(tmp(:)).^2) / l.rx_array(1, 1).no_elements); % Divide by num Rx antennas
        end
    end
end