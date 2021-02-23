function mvrcQv2_MRO(params)

if nargin == 0
    params = mvrcQv2_init;
end
tic

save_folder = ['savedResults/Scenario ', params.sim_num, '/'];
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end
directories = dir(save_folder);
num_dir = numel(directories([directories(:).isdir]))-2;
save_folder = [save_folder, 'trial ', num2str(num_dir+1), '/'];
mkdir(save_folder);

if ~params.save_layout
    [l, max_xy, params.orientations] = mvrcQv2_layout(params);
else
    [l, max_xy, params.orientations] = load_layout(params);
end
p = l.init_builder;                                       % Create channel builders
gen_parameters( p );                                      % Generate small-scale fading
                                  % Generate channel coefficients
cn = merge( get_channels( p ) );
cn = reshape(cn, [l.no_rx, l.no_tx]);
nEl = l.tx_array(1, 1).no_elements / 3; % Number of elements per sector
nEl = {1:nEl, nEl + 1:2 * nEl, 2 * nEl + 1:3 * nEl}; % Element indices per sector
fprintf('Spliting channels between sectors...');
c(:, :) = split_tx(cn, nEl); % Split channels from each sector

used_time = toc;
fprintf("Time taken for simulation = %3.1f s", used_time);
l.visualize([],[],0);                                     % Show BS and MT positions on the map

%% Outputs
Write_Spectral_Tracks;
saveas(gcf, strcat(save_folder, 'Layout.png'))
write_json_config;
% save(strcat(save_folder, 'workspace.mat'), '-v7.3', 'p', 'cn');
% config file should have tx locations, rx start, heading, speed, end, the
% antenna descriptions, and scenario.

fprintf("Total time = %3.1f s", toc);
    
[ map,x_coords,y_coords] = l.power_map('3GPP_3D_UMa_NLOS', 'quick',5,-max_xy,max_xy,-max_xy,max_xy,1.5, params.Tx_P_dBm(1, 1));
% scenario FB_UMa_NLOS, type 'quick', sample distance, x,y min/max, rx
% height; type can be 'quick', 'sf', 'detailed', 'phase'

% P = 10*log10(sum( abs( cat(3,map{:}) ).^2 ,3));         % Total received power
P = 10*log10(sum(abs(cat(3, map{:})), 3:4));        % Simplified Total received power; Assumed W and converted to dBm

l.visualize([],[],0);
hold on;
imagesc( x_coords, y_coords, P);          % Plot the received power
axis([-max_xy max_xy -max_xy max_xy])                               % Plot size
%caxis( max(powermatrix.Tx1pwr,[],'all') + [-20 0] )                  % Color range
caxis( max(P(:)) + [-50 -5] )
% caxis([-75, -30]);
colmap = colormap;
colbar = colorbar;
colbar.Label.String = "Receive Power [dBm]";
% colormap( colmap*0.5 + 0.5 );                           % Adjust colors to be "lighter"
set(gca,'layer','top')                                    % Show grid on top of the map
hold on;
set(0,'DefaultFigurePaperSize',[14.5 7.3])                % Adjust paper size for plot                                  % Show BS and MT positions on the map

saveas(gcf, strcat(save_folder, 'Rough_RSRP_Map.png'))

end

