function mvrcQv2_plotresults(savedResultFile)

set(0, 'defaultTextFontSize', 18) % Default Font Size
set(0, 'defaultAxesFontSize', 18) % Default Font Size
set(0, 'defaultAxesFontName', 'Helvetica') % Default Font Type
set(0, 'defaultTextFontName', 'Helvetica') % Default Font Type
set(0, 'defaultFigurePaperPositionMode', 'auto') % Default Plot position
set(0, 'DefaultFigurePaperType', '<custom>') % Default Paper Type
set(0, 'DefaultFigurePaperSize', [14.5, 6.9]) % Default Paper Size
set(0, 'DefaultAxesTitleFontWeight', 'normal');

load(savedResultFile);

%% PLOTS
% visualize the antenna array
%params.tx_array_3gpp_3d.visualize;

figure('Renderer', 'painters', 'Position', [10, 10, 1000, 1500]); clf
% Cell ID
%Heatmap
subplot(321)
imagesc([x_min, x_max], [y_min, y_max], cell_id);
c1 = colorbar;
c1.Location = 'northoutside';
c1.Label.String = "Cell ID";
axis([x_min, x_max, y_min, y_max]);
axis square;
hold on
for b = 1:size(tx_locs, 1)
    plot(tx_locs(b, 1), -tx_locs(b, 2), ...
        '.r', 'Markersize', 24);
    hold on;
end
xlabel('x (m)');
ylabel('y (m)');
grid on;

%CDF
subplot(322);
h = histogram(cell_id, 'Normalization', 'probability', 'FaceColor', 'red', 'LineWidth', 2);
axis square;
grid on;
ylabel('PDF');
xlabel('Cell ID');

%     %Coupling loss
%     %Heatmap
%     figure('Renderer', 'painters', 'Position', [10, 10, 1000, 1000]);
%     clf;
%     subplot(121);
%     imagesc([x_min, x_max], [y_min, y_max], coupling_loss_2d);
%     c1 = colorbar;
%     c1.Location = 'northoutside';
%     c1.Label.String = "Coupling loss (dB)";
%     axis([x_min, x_max, y_min, y_max]);
%     axis square;
%     hold on
%     for b = 1:size(tx_locs,1)
%         plot(tx_locs(b,1), -tx_locs(b,2), ...
%             '.r','Markersize', 24);
%         hold on;
%     end
%          xlabel('x (m)');
%     ylabel('y (m)');
%     grid on;
%
%     %CDF
%     subplot(122);
%     cdf_data = coupling_loss_2d(:);
%     cdf_data_min = min(cdf_data);
%     cdf_data_max = max(cdf_data);
%     cdf_data_mean = mean(cdf_data);
%     bins = cdf_data_min:0.01:cdf_data_max;
%     plot(bins, 100*qf.acdf(cdf_data, bins), '-r', 'Linewidth', 3);
%     grid on;
%     xlabel('Coupling loss (dB)');
%     ylabel('CDF (%)');
%     axis square;
%     title(sprintf('(min,max,avg)=(%0.0f,%0.0f,%0.0f)', cdf_data_min, cdf_data_max, cdf_data_mean));

% RSRP
%Heatmap
%figure('Renderer', 'painters', 'Position', [10, 10, 1000, 1000]); clf
subplot(323);
imagesc([x_min, x_max], [y_min, y_max], rsrp_2d);
c1 = colorbar;
%caxis([-120, -60]);
c1.Location = 'northoutside';
c1.Label.String = "RSRP (dBm)";
axis([x_min, x_max, y_min, y_max]);
axis square;
hold on
for b = 1:size(tx_locs, 1)
    plot(tx_locs(b, 1), -tx_locs(b, 2), ...
        '.r', 'Markersize', 24);
    hold on;
end
xlabel('x (m)');
ylabel('y (m)');
grid on;

%CDF
subplot(324);
cdf_data = rsrp_2d(:);
cdf_data_min = min(cdf_data);
cdf_data_max = max(cdf_data);
cdf_data_mean = mean(cdf_data);
bins = cdf_data_min:0.01:cdf_data_max;
plot(bins, 100*qf.acdf(cdf_data, bins), '-r', 'Linewidth', 3);
grid on;
xlabel('RSRP (dBm)');
ylabel('CDF (%)');
axis square;
title(sprintf('(min,max,avg)=(%0.0f,%0.0f,%0.0f)', cdf_data_min, cdf_data_max, cdf_data_mean));

% Geometry factor (=SINR)
%Heatmap
%figure('Renderer', 'painters', 'Position', [10, 550, 1000, 500]);
%clf;
subplot(325);
imagesc([x_min, x_max], [y_min, y_max], sinr_2d);
caxis([-5, 20]);
c1 = colorbar;
c1.Location = 'northoutside';
c1.Label.String = "Geometry factor (dB)";
axis([x_min, x_max, y_min, y_max]);
axis square;
hold on
for b = 1:size(tx_locs, 1)
    plot(tx_locs(b, 1), -tx_locs(b, 2), ...
        '.r', 'Markersize', 24);
    hold on;
end
xlabel('x (m)');
ylabel('y (m)');
grid on;

%CDF
subplot(326);
cdf_data = sinr_2d(:);
cdf_data_min = min(cdf_data);
cdf_data_max = max(cdf_data);
cdf_data_mean = mean(cdf_data);
bins = cdf_data_min:0.01:cdf_data_max;
plot(bins, 100*qf.acdf(cdf_data, bins), '-r', 'Linewidth', 3);
grid on;
xlabel('Geometry factor (dB)');
ylabel('CDF (%)');
axis square;
title(sprintf('(min,max,avg)=(%0.0f,%0.0f,%0.0f)', cdf_data_min, cdf_data_max, cdf_data_mean));

%         for t = 1:size(tx_locs,1)
%             scen = zeros(no_rx, 1);
%             for r = 1:no_rx
%                 switch char(l.rx_track(r).scenario(t))
%                     case '3GPP_3D_UMi_LOS'
%                         scen(r) = 0;
%                     case '3GPP_3D_UMi_NLOS'
%                         scen(r) = 1;
%                     otherwise
%                         scen(r) = nan;
%                 end
%             end
%             scen_2d(:, :, t) = reshape(scen, n_y_coords, n_x_coords);
%             f = figure(200+t); clf
%             imagesc([x_min, x_max], [y_min, y_max], scen_2d(:, :, t));
%             hold on;
%             axis([x_min, x_max, y_min, y_max]);
%             axis square;
%             colormap(f, gray(2));
%             for b = 1:size(tx_locs,1)
%                 plot(tx_locs(b,1), -tx_locs(b,2), ...
%                     '.r','Markersize', 24);
%                 hold on;
%             end
%             xlabel('x (m)');
%             ylabel('y (m)');
%             grid on; title('{3GPP\_3D\_UMi}:Black=LOS,White=NLOS')
%         end

figure(200);
imagesc([x_min, x_max], [y_min, y_max], rsrp_2d);
c1 = colorbar;
%caxis([-120, -60]);
c1.Location = 'northoutside';
c1.Label.String = "RSRP (dBm)";
axis([x_min, x_max, y_min, y_max]);
axis square;
hold on
for b = 1:size(tx_locs, 1)
    plot(tx_locs(b, 1), -tx_locs(b, 2), ...
        '.r', 'Markersize', 24);
    hold on;
end
xlabel('x (m)');
ylabel('y (m)');
grid on;

end