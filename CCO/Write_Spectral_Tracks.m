%% Store Spectral Information
% This script is used to take the channel information from a simulation and
% convert it into a file format for NS3. There is no encoding and the data
% should be ready to be loaded in right away.

num_RBs = 50;
BW = 10e6;
fft_size = 1024;
RB_BW = 180e3;
Tx_P = 10.^(0.1*Tx_P_dBm)/1000;

% naively assign the center most values as the useful frequencies, and
% throw away edge values (broad assumption on the overhead usage)

useful_BW = RB_BW * num_RBs; % 9MHz
useful_fft_points = floor(useful_BW/BW*fft_size);

difference = fft_size - useful_fft_points;
range_of_interest = floor(difference/2)+1:fft_size-floor(difference/2)-1;

if length(range_of_interest) > useful_fft_points
    range_of_interest(end) = [];

elseif length(range_of_interest) < useful_fft_points
    range_of_interest = [range_of_interest, max(range_of_interest)+1];

end
            
       
Y_save = zeros(num_RBs, total_time*fs);
for tx_k=1:l.no_tx
    for rx_k=1:l.no_rx
        for sector=1:N_SECTORS(tx_k)
            name = strcat(save_folder, 'ULDL_', 'TX_', num2str(tx_k), '_Sector_',num2str(sector), '_UE_', num2str(rx_k), '_Channel_Response');
            file = fopen(strcat(name, '.txt'), 'wt');

            % Get the frequency response values
            X = cn((tx_k-1)*l.no_rx + rx_k).fr(BW, fft_size);
            X = squeeze(X(1, sector, :, :));

            X = X(range_of_interest, :);
            % X = 10*log10(abs(X).^2./(fft_size*BW)); % normalization
            % already occurs in the .fr() method. Scale by transmit power
            X = abs(X).^2 .* Tx_P(tx_k, sector); 
            edges = 1:useful_fft_points/num_RBs:useful_fft_points+1;
            bin_sets = discretize(1:useful_fft_points, edges);
            [~, len] = size(X);


            for i=1:num_RBs
                Y = mean(X(bin_sets==i, :), 1); % average over the bin
                Y_save(i, :) = mean(X(bin_sets==i, :), 1);
               for j=1:len
                    fprintf(file, '%g ', Y(j));
                end
                fprintf(file, '\n'); 
            end
            fclose(file);
            
            writematrix(Y_save, strcat(name, '.csv')); % Writes too many digits
        end
    end
end