%% Calculate channels along tracks, power map over cell and generate outputs to explore AI/ML solutions
%Edit initialize.sim file to set simulation parameters, layouts etc.
%Requires MATLAB and QuaDriGA libraries as well as setup of RF scenarios
%specified in the intialize.sim file.
%Trajectories, segments, and scenarios are defined. Channel coefficients
%are created for each segment separately. The channel merger combines these
%output into a longer sequence. The output sequences are evaluated for
%different settings of the model.The channel model generates the
%coefficients separately for each segment. In order to get a
%time-continuous output, these coefficients have to be combined. This is a 
%feature which is originally described in the documentation of the WIM2
%channel model, but which was never implemented and is implemented
%here.This script sets up the simulation and creates such time-continuous
%CIRs. Currently this outputs received power assuming Geometric mean of
%pathloss along the tracks. This also allows for writing out of the impulse
%response power out of the cyclic prefix window (which would represent self
%interference) but calculation of this is currently not implemented and
%this term is set 100dB below rx power. This also allows for the channel
%to switch between NLOS and LOS along the path but this feature is disabled

%% Simulation parameter and layout set up done by editing the intialize_sim.m file
% edit initiatialize.sim file to set simulation parameters, layouts,
% frequencies, location of transmitters, step size, number of paths etc
close all
clear all

initialize_sim;
set(0,'defaultTextFontSize', 18)                        % Default Font Size
set(0,'defaultAxesFontSize', 18)                        % Default Font Size
set(0,'defaultAxesFontName','Times')                    % Default Font Type
set(0,'defaultTextFontName','Times')                    % Default Font Type
set(0,'defaultFigurePaperPositionMode','auto')          % Default Plot position
set(0,'DefaultFigurePaperType','<custom>')              % Default Paper Type
tic;
%% process paths if this is configure in the initialize.sim file
if process_paths == 1
    generate_street_tracks(l,track_length,samp_per_meter,40,70,30,200,scen); % generate the tracks along which channels will be computed
    interpolate_positions(l.rx_track, s.samples_per_meter);   % Interpolate for simulation requirements of samples/(lambda/2)
    calc_orientation(l.rx_track);                             % Align antenna direction with track
    
    % Now we create the channel coefficients. The fixing the random seed (check) guarantees repeatable results
    % (i.e. the taps will be at the same positions for both runs). Also note the significantly longer
    % computing time when drifting is enabled.
    
% 	[pairs, powers] = l.set_pairing('power', Rx_threshold_dBm, tx_powers);

    disp('Drifting enabled:');
    p = l.init_builder;                                       % Create channel builders
    gen_parameters( p );                                      % Generate small-scale fading
    c = get_channels( p );                                    % Generate channel coefficients
    cn = merge( c );
    write_track_data(cn, l.no_rx, num_interf, track_directory); % write out csv files, one per track, in track_directory
    set(0,'DefaultFigurePaperSize',[14.5 7.3])                % Adjust paper size for plot
    l.visualize([],[],0);                                     % Show BS and MT positions on the map
    if show_plot == 1
        plot_power;
    end
    if save_work ==1
        save(append(track_directory,'workspace_paths',datestr(now,'yy-mm-dd-HH-MM')),'p','cn','l','-v7.3') % this is in here in case we want to examine the data.
    end
end
%% process power map if this is configured in the initialize.sim file
if process_powermap == 1

    [ map,x_coords,y_coords] = l.power_map(scen{2},'detailed',grid_resolution,-max_xy,max_xy,-max_xy,max_xy,ue_height );
    % scenario FB_UMa_NLOS, type 'quick', sample distance, x,y min/max, rx
    % height; type can be 'quick', 'sf', 'detailed', 'phase'

    % P = 10*log10(sum( abs( cat(3,map{:}) ).^2 ,3));         % Total received power
    P = 10*log10(sum(abs(cat(3, map{:})).^2, 3:4))+30;        % Simplified Total received power; Assumed W and converted to dBm
   
    % create a struct where powers over the x,y grid are available for each tx on an x,y grid
    powermatrix.x = x_coords;
    powermatrix.y = y_coords;
    powermatrix.z = ue_height;
    for i = 1:l.no_tx
        powermatrix.(append('Tx',int2str(i),'pwr')) = 10*log10(squeeze(map{i}))+30; % Assumed W and converted to dBm
        powermatrix.(append('Tx',int2str(i),'loc')) = l.tx_position(:,i);
    end
    % write out json object to file
    jsonStr = jsonencode(powermatrix);
    fid = fopen(append(track_directory,'powermatrix',datestr(now,'yy-mm-dd-HH-MM')), 'w');
    if fid == -1, error('Cannot create JSON file'); end
    fwrite(fid, jsonStr, 'char');
    fclose(fid);
    % if configured, plot power map
    hold off;
    if show_plot ==1
        l.visualize([],[],0);  
        hold on;
        imagesc( x_coords, y_coords, P);          % Plot the received power
        axis([-max_xy max_xy -max_xy max_xy])                               % Plot size
        %caxis( max(powermatrix.Tx1pwr,[],'all') + [-20 0] )                  % Color range
        % caxis( max(P(:)) + [-30 -5] )
        caxis([-75, -40]);
        colmap = colormap;
        c = colorbar;
        c.Label.String = "Receive Power [dBm]";
        % colormap( colmap*0.5 + 0.5 );                           % Adjust colors to be "lighter"
        set(gca,'layer','top')                                    % Show grid on top of the map
        hold on;
        set(0,'DefaultFigurePaperSize',[14.5 7.3])                % Adjust paper size for plot                                  % Show BS and MT positions on the map
    end
    if save_work ==1
        save(append(track_directory,'workspace_map',datestr(now,'yy-mm-dd-HH-MM')),'map','x_coords','y_coords','-v7.3') % this is in here in case we want to examine the data.
    end
end

toc