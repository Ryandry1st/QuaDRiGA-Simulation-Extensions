function power_map_and_path_tilt(tilt)
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

%% INIT
init_params;

FB_ratio = 10^(FB_RATIO_DB/10);

if nargin>0
    downtilt = tilt;
end

if del_builder
    if exist([pwd,'/tracks/builder_obj.mat'], 'file')
        delete([pwd,'/tracks/builder_obj.mat']);
    end
end

max_xy = floor((grid_resolution*sqrt(nGrid)-1)/2);

Tx_P = 10^(0.1*Tx_P_dBm)/1000;

set_cell_layouts;

tx_powers = ones(1, l.no_tx) * Tx_P_dBm;                  % assumes same power for all tx, can be changed

%% number of receiver & specification of antenna type; length and resolution of UE track
l.no_rx = 1;                                              % Number of UEs and tracks - one track per UE
l.rx_array = qd_arrayant('omni');                         % Omni antennas at Rx
l.rx_array.center_frequency = FC;
samp_per_meter = 0.25;                                    % samples per meter for track interpolation
track_length = 500;                                       % track length in meters; currently same for all l.no_rx UEs

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

    disp('Drifting enabled:');
    p = l.init_builder;                                       % Create channel builders
    gen_parameters( p );                                      % Generate small-scale fading
    c = get_channels( p );                                    % Generate channel coefficients
    cn = merge( c );
    write_track_data(cn, l.no_rx, N_SECTORS, num_interf, track_directory); % write out csv files, one per track, in track_directory
    set(0,'DefaultFigurePaperSize',[14.5 7.3])                % Adjust paper size for plot
    l.visualize([],[],0);                                     % Show BS and MT positions on the map
    if show_plot == 1
        plot_power;
    end
    if save_work ==1
        save(append(track_directory,'workspace_paths'),'p','cn','l','-v7.3') % this is in here in case we want to examine the data.
    end
end
%% process power map if this is configured in the initialize.sim file
if process_powermap == 1
    
    [ map,x_coords,y_coords, ~] = power_map_const(l, scen{2}, usage, grid_resolution,-max_xy,max_xy,-max_xy,max_xy,ue_height, tx_powers);
    % scenario FB_UMa_NLOS, type 'quick', sample distance, x,y min/max, rx
    % height; type can be 'quick', 'sf', 'detailed', 'phase'
   
    P = 10*log10(sum(abs(cat(3, map{:})).^2, 3:4))+30;        % Simplified Total received power; Assumed W and converted to dBm
    
    % create a struct where powers over the x,y grid are available for each tx on an x,y grid
    powermatrix.x = x_coords;
    powermatrix.y = y_coords;
    powermatrix.z = ue_height;
    powermatrix.ptx = Tx_P; % power in watts
    powermatrix.downtilt = squeeze(orientations(:, 2));
    for i = 1:l.no_tx
        powermatrix.(append('Tx',int2str(i),'pwr')) = 10*log10(squeeze(map{i}).^2)+30; % Assumed W and converted to dBm
        powermatrix.(append('Tx',int2str(i),'loc')) = l.tx_position(:,i);
    end
    
    % write out json object to file
    if save_work == 1
        jsonStr = jsonencode(powermatrix);
        fid = fopen(append(track_directory,'powermatrix.json'), 'w');
        if fid == -1, error('Cannot create JSON file'); end
        fwrite(fid, jsonStr, 'char');
        fclose(fid);
        if save_npz == 1
            commandStr = strcat(python_path, [' make_npz_from_json.py ', 'powermatrix.json']);
            system(commandStr);
        end
        
    end
    
    if save_opt == 1
        if ~exist([pwd,'/opt_data/json'], 'dir')
            mkdir([pwd,'/opt_data/json']);
        end
        if ~exist([pwd,'/opt_data/npz'], 'dir')
            mkdir([pwd,'/opt_data/npz']);
        end
        file_name = append('powermatrixDT', num2str(round(downtilt)));
        jsonStr = jsonencode(powermatrix);
        fid = fopen(['opt_data/json/', file_name,'.json'], 'w');
        if fid == -1, error('Cannot create JSON file'); end
        fwrite(fid, jsonStr, 'char');
        fclose(fid);
        commandStr = strcat(python_path, [' make_npz_from_json.py ', file_name]);
        fprintf('\t Attempting to create NPZ file...')
        status = system(commandStr);
        if ~(status==0), error('Cannot create NPZ file'); end
        fprintf('Success. \n')
    end
    
    
    if show_plot ==1
        %l.visualize([],[],0);
        
        figure(downtilt);clf
        subplot(121)
        for b=1:no_BS
            plot3( l.tx_position(1,b),l.tx_position(2,b),l.tx_position(3,b),...
                '.r','Linewidth',3,'Markersize',16 );hold on;
        end
        xlabel('x (m)');ylabel('y (m)');
        grid on;box on;view(0, 90);axis square
        
        imagesc('XData',x_coords,'YData',y_coords,'CData',P)
        axis([-max_xy max_xy -max_xy max_xy])                               % Plot size
        caxis([-140, -45]);
        c = colorbar;
        c.Location = 'northoutside';
        c.Label.String = "DL RX PWR (dBm)";
        pwr = P(:);
        pwr_sort = sort(pwr);
        pwr_min = pwr_sort(1);
        pwr_max = pwr_sort(end);
        
        xx = linspace(pwr_min,pwr_max,50);
        for i = 1:length(xx)
            yy(i)= sum(pwr_sort<xx(i));
        end
        subplot(122);plot(xx,100*yy/length(pwr),'-r','linewidth',3);grid on;xlabel('DL RX PWR (dBm)');ylabel('CDF (%)');axis square
        title(sprintf('[min,max,avg] = [%0.1f, %0.1f, %0.1f] (dBm)',pwr_min,pwr_max,mean(pwr)))
    end
    
    if save_work ==1
        save(append(track_directory,'workspace_map'),'map','x_coords','y_coords','-v7.3') % this is in here in case we want to examine the data.
    end
    
end

fprintf('\t[Sim runtime = %1.0f min]\n',toc/60)

return