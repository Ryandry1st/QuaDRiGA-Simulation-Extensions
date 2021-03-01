function varargout = load_layout(params)
%LOAD_LAYOUT, performs the loading and reseting of antennas for CCO or MRO

try
    load([pwd, '/savedLayouts/layout.mat']);
    
    if params.sim_style
        max_xy = x_max;
    end
    % reset tx antennas in case downtilt changed
    fprintf('Reseting tx antenna arrays...');
    % check if within 20%, no_tx are correct, distances correct
    if ~Compare_layout(l, params)
        % layout does not match, recalculate.
        warning("Layout mismatch, recalculating\n");
        error("Mismatch between layouts, recalculate\n")
    end
    fprintf('success.\n');
    params.orientations = old_orientations;
    params.orientations(:, 2) = params.downtilt;

    for i = 1:l.no_tx
        fprintf('%d(of %d)/', i, l.no_tx);
        index = params.no_sectors * (i - 1) + 1;
        for j = 1:params.no_sectors
            n = index + j - 1;
            theta_n = params.orientations(n, 2);
            switch params.tx_antenna_type
                case '3gpp-macro'
                    tx_array_cpy(j) = qd_arrayant('3gpp-macro', params.tx_antenna_3gpp_macro.phi_3dB, params.tx_antenna_3gpp_macro.theta_3dB, params.tx_antenna_3gpp_macro.rear_gain, theta_n);
                case '3gpp-3d'
                    tx_array_cpy(j) = qd_arrayant('3gpp-3d', params.tx_antenna_3gpp_3d.M, params.tx_antenna_3gpp_3d.N, params.tx_antenna_3gpp_3d.center_freq, params.tx_antenna_3gpp_3d.pol, theta_n, params.tx_antenna_3gpp_3d.spacing);
            end
        end
        tx_array_i = copy(tx_array_cpy(1));
        no_el = tx_array_i.no_elements;
        for j = 2:params.no_sectors
            phi = params.orientations(index+j-1, 1);
            for m = 1:no_el
                tx_array_i.copy_element(m, (j - 1)*no_el+m);
                tx_array_i.rotate_pattern(phi, 'z', (j - 1)*no_el+m);
            end
        end
        phi_1 = params.orientations(index, 1);
        for m = 1:no_el
            tx_array_i.rotate_pattern(phi_1, 'z', m);
        end
        l.tx_array(i) = tx_array_i;
    end
    fprintf('done.\n');
catch
    warning('Failure. Recalculating.\n');
    if ~exist([pwd, '/savedLayouts'], 'dir')
        mkdir(pwd, '/savedLayouts');
    end
    if params.sim_style
        [l, x_min, x_max, y_min, y_max, x_coords, y_coords, n_x_coords, n_y_coords, params.orientations] = mvrcQv2_layout(params);
        max_xy = x_max;
    else
        [l, max_xy, params.orientations] = mvrcQv2_layout(params);
    end
    params.save_load_channels = 0;
end

varargout {1} = l;
varargout {2} = max_xy;

if params.sim_style
    varargout {3} = x_min; varargout {4} = x_max; varargout {5} = y_min;
    varargout {6} = y_max; varargout {7} = x_coords; varargout {8} = y_coords;
    varargout {9} = n_x_coords; varargout {10} = n_y_coords; varargout {11} = params.orientations;
else
    varargout{3} = params.orientations;
end 

end

