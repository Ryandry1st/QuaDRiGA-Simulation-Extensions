%% Store Spectral Information
% This script is used to take the channel information from a simulation and
% convert it into a file format for NS3. There is no encoding and the data
% should be ready to be loaded in right away.
show_plot = 0;

% See
% https://home.zhaw.ch/kunr/NTM1/literatur/LTE%20in%20a%20Nutshell%20-%20Physical%20Layer.pdf
% for details of LTE PHY options
BW_options   = [1.25, 2.5, 5, 10, 15, 20]; % requested bandwidth should be one of these
FFT_Sampling = [1.92, 3.84, 7.68, 15.36, 23.04, 30.72]*10e6;
FFT_options  = [128, 256, 1024, 1536, 2048];
RB_options   = [6, 12, 25, 50, 75, 100];
SC_options   = 12 * RB_options;


choice = find(BW_options == params.BW);
if isempty(choice)
    choice = find(BW_options*10e6 == params.BW);
    if isempty(choice)
        error("No valid BW selected, try again");
    end
else
    params.BW = 10e6*params.BW;
end

num_RBs = RB_options(choice);
fft_size = FFT_options(choice);
fft_freq = FFT_Sampling(choice);
RB_BW = 180e3;
subcarrier_spacing_Hz = 15e3;


Tx_P = 10.^(0.1 * params.Tx_P_dBm) / 1000;

% naively assign the center most values as the useful frequencies, and
% throw away edge values (broad assumption on the overhead usage)

useful_BW = RB_BW * num_RBs; %[1.14, 2.265, 4.515, 9.015, 13.515, 18.015]MHz
useful_fft_points = floor(useful_BW/subcarrier_spacing_Hz);

difference = fft_size - useful_fft_points;
range_of_interest = floor(difference/2) + 1:fft_size - floor(difference/2) - 1;

if length(range_of_interest) > useful_fft_points
    range_of_interest(end) = [];

elseif length(range_of_interest) < useful_fft_points
    range_of_interest = [range_of_interest, max(range_of_interest) + 1];

end

% x, y, z, t, associated cell id, associated rsrp, <= 6 neighbor cell ids,
% <= 6 neighbors rsrps
if l.no_tx < 2
    MRO_report = zeros(10, params.total_time*params.fs);
    kbest = 2;
    rsrp_index = 9:10;
elseif l.no_tx == 2
    MRO_report = zeros(16, params.total_time*params.fs);
    kbest = 5;
    rsrp_index = 12:16;
else
    MRO_report = zeros(18, params.total_time*params.fs);
    kbest = 6;
    rsrp_index = 13:18;
end
Y_save = zeros(num_RBs, params.total_time*params.fs, params.no_sectors);


%% Start calculations
tic
WidebandRSRP; % Calculates RSRP values
MRO_report(4, :) = (1:l.rx_track(1).no_snapshots)/params.fs;
for tx_k = 1:l.no_tx
    for rx_k = 1:l.no_rx
        MRO_report(1:3, :) = l.rx_track(rx_k).positions + l.rx_track(rx_k).initial_position;
        [MRO_report(6, :), MRO_report(5, :)] = max(rsrp_p0(rx_k, :, :), [], 2);
        [B, I] = maxk(rsrp_p0(rx_k, :, :), kbest+1, 2);
        MRO_report(rsrp_index, :) = B(1, 2:end, :);
        MRO_report(7:rsrp_index(1)-1, :) = I(1, 2:end, :);

        if ~params.batch
            for sector = 1:params.no_sectors
                % Get the frequency response values
                X = c(rx_k, (tx_k-1)*params.no_sectors+sector).fr(fft_freq, fft_size);
                X = squeeze(X);

                X = X(range_of_interest, :);
                % X = 10*log10(abs(X).^2./(fft_size*BW)); % normalization
                % already occurs in the .fr() method. Scale by transmit power
                X = abs(X).^2./(fft_size) .* Tx_P(1, 1);
                edges = 1:useful_fft_points / num_RBs:useful_fft_points + 1;
                bin_sets = discretize(1:useful_fft_points, edges);
                [~, len] = size(X);

                for i = 1:num_RBs
                    Y = mean(X(bin_sets == i, :), 1); % average over the bin
                    Y_save(i, :, sector) = mean(X(bin_sets == i, :), 1);
                end

            Y_save = round(Y_save, 5, 'significant');
            end
            for sector = 1:params.no_sectors
                name = strcat(params.save_folder_r, 'ULDL_', 'TX_', num2str(tx_k), '_Sector_', num2str(sector), '_UE_', num2str(rx_k), '_Channel_Response');
                writematrix(Y_save(:, :, sector), strcat(name, '.csv'));

            end
        end
        
        name = strcat(params.save_folder_r,  'track_UE', num2str(rx_k));
%         if all(params.orientations == params.orientations(1))
        name = [name, '_DT', num2str(params.orientations(1, 2))];
%         end
        % Performs PSD RSRP calculation, not 3gpp version
%             MRO_report(4, :) = 10*log10(squeeze(mean(Y_save(:, :, sector), 1)))+30; % +30 to get dBm
        % Performs 3gpp RSRP calculation (wideband)
        T = array2table(round(MRO_report', 4, 'significant'));
        T.Properties.VariableNames(1:6) = {'x','y','z','t','serving pci', 'serving rsrp'};
        for i=7:rsrp_index(1)-1
            T.Properties.VariableNames(i) = {['neigh ', num2str(i-6), ' pci']};
        end
        for i=rsrp_index
            T.Properties.VariableNames(i) = {['neigh ', num2str(i-rsrp_index(1)+1), ' rsrp']};
        end
        writetable(T, strcat(name, '.csv'));

            
        if show_plot % Show a 3D plot of the time-frequency response
            f = figure('Position', [100, 200, 1800, 800]);
            t = tiledlayout(f, 1, params.no_sectors);
            for sector = 1:params.no_sectors
                nexttile
                surf(1:100:total_time*fs, 1:num_RBs, 10*log10(Y_save(:, 1:100:end, sector)));
                xlabel("Time [ms]")
                ylabel("Frequency [Hz]")
                zlabel("Channel Gain [dB]")
            end
            title(t, ['Time-Freq Response ', 'TX', num2str(tx_k), ' UE', num2str(rx_k)]);
            saveas(gcf, strcat(save_folder, ['Time-Freq_Response', '_TX_', num2str(tx_k), '_UE_', num2str(rx_k), '.png']));
            close all;
        end
    end
end
BSmetadata;
toc