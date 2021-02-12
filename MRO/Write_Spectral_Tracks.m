%% Store Spectral Information
% This script is used to take the channel information from a simulation and
% convert it into a file format for NS3. There is no encoding and the data
% should be ready to be loaded in right away.


% See
% https://home.zhaw.ch/kunr/NTM1/literatur/LTE%20in%20a%20Nutshell%20-%20Physical%20Layer.pdf
% for details of LTE PHY options
BW_options   = [1.25, 2.5, 5, 10, 15, 20]; % requested bandwidth should be one of these
FFT_Sampling = [1.92, 3.84, 7.68, 15.36, 23.04, 30.72]*10e6;
FFT_options  = [128, 256, 1024, 1536, 2048];
RB_options   = [6, 12, 25, 50, 75, 100];
SC_options   = 12 * RB_options;


choice = find(BW_options == BW);

num_RBs = RB_options(choice);
fft_size = FFT_options(choice);
fft_freq = FFT_Sampling(choice);
RB_BW = 180e3;
subcarrier_spacing_Hz = 15e3;
BW = 10e6*BW;

Tx_P = 10.^(0.1 * Tx_P_dBm) / 1000;

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

Y_save = zeros(num_RBs, total_time*fs, N_SECTORS(1));
tic
for tx_k = 1:l.no_tx
    for rx_k = 1:l.no_rx
        for sector = 1:N_SECTORS(tx_k)
            name = strcat(save_folder, 'ULDL_', 'TX_', num2str(tx_k), '_Sector_', num2str(sector), '_UE_', num2str(rx_k), '_Channel_Response');
%             file = fopen(strcat(name, '.txt'), 'wt');

            % Get the frequency response values
            X = cn((tx_k-1)*l.no_rx+rx_k).fr(fft_freq, fft_size);
            X = squeeze(X(1, sector, :, :));

            X = X(range_of_interest, :);
            % X = 10*log10(abs(X).^2./(fft_size*BW)); % normalization
            % already occurs in the .fr() method. Scale by transmit power
            X = abs(X).^2 .* Tx_P(tx_k, sector);
            edges = 1:useful_fft_points / num_RBs:useful_fft_points + 1;
            bin_sets = discretize(1:useful_fft_points, edges);
            [~, len] = size(X);

            for i = 1:num_RBs
                Y = mean(X(bin_sets == i, :), 1); % average over the bin
                Y_save(i, :, sector) = mean(X(bin_sets == i, :), 1);
%                 for j = 1:len
%                     fprintf(file, '%g ', Y(j));
%                 end
%                 fprintf(file, '\n');
            end
%             fclose(file);

        end
        for sector = 1:N_SECTORS(tx_k)
            name = strcat(save_folder, 'ULDL_', 'TX_', num2str(tx_k), '_Sector_', num2str(sector), '_UE_', num2str(rx_k), '_Channel_Response');
            writematrix(Y_save(:, :, sector), strcat(name, '.csv')); % Writes too many digits
        end
        if show_plot % Show a 3D plot of the time-frequency response
            f = figure('Position', [100, 200, 1800, 800]);
            t = tiledlayout(f, 1, N_SECTORS(tx_k));
            for sector = 1:N_SECTORS(tx_k)
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
toc