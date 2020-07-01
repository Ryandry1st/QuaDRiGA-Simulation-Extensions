function write_track_data(cn, num_rx, num_sectors, num_interf, track_directory);
% This function takes an an array of objects of type qd_channel,
% assumes it has num_rx UEs, and num_interf interfering bases stations,
% and a string that specifies the directory path for where the channel
% information will be written out. The Rx signal power is computed from the
% desired base station and from the interfering base stations and written
% out in csv files, one file per track. 
% qd_channel is a Quadriga defined object that contains a sequence of X, Y,
% Z points and the associated RF channel at each of those points. The
% channels are specified by a set of paths and the delays of each path. The
% path format is converted to a frequency spectrum and the geometric mean
% of the frequency response is what is written. 

% Question to ask: are other sectors also interference? Probably. That
% is harder to remove though. I will start with assuming it is not.

% Also this looks like it assumes all base stations besides the first one
% are interference, which is not the case, it should be all but the
% strongest are interference.
    for track=1:num_rx
        for sector=1:num_sectors
            interf_pwr = zeros(cn(track).no_snap,num_interf);
            h = cn(track).fr( 100e6,512 );                          % Freq.-domain channel
            h = squeeze(h(:, sector, :, :));                              % Second dimension is for each sector
            sigpwr = mean(20*log10(abs(h)))'+10*log10(512);         % calculate geometric mean sigpwr - should really be gm of SINR
            selfintfpwr= sigpwr-100*ones(cn(track).no_snap,1);      % self interference - set to -100dB relative to desired signal
     %       pdp{track} = 10*log10(abs(ifft(h,[],1).').^2);         % Power-delay profile
            for interf=1:num_interf
                h = cn(track+num_rx*interf).fr( 100e6,512 );        % Freq.-domain channel
                h = squeeze(sum(h, 2));                             % Remove singleton dimensions
                interf_pwr(:,interf) = mean(20*log10(abs(h)))'+10*log10(512); % a geometric mean here could be replace by a power mean.
            end
            write_matrix=[cn(track).rx_position',sigpwr,selfintfpwr,interf_pwr]; % create matrix with x, y, z, signal, self interference
            writematrix(write_matrix,append(track_directory,'track',num2str(track),'-','sector', num2str(sector), '.csv'));
        end
    end
end