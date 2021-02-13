function [equality] = Compare_layout(h_layout, params)
% Determine if a layout and a set of params can refer to the same setting.
% If not, the layout should be recalculated in the main loop.

equality = 1;

% Compare no_rx
if norm(h_layout.no_rx - params.no_rx_min) > params.no_rx_min / 5 
    equality = 0;
    return;
end
% compare number of tx
if h_layout.no_tx ~= params.no_tx
    equality = 0;
    return;
end
% compare minimum rx position
if min(h_layout.rx_position(1, :)) ~= params.x_min
    equality = 0;
    return;
end
% compare scenario (name)
if ~strcmp(h_layout.name, params.scen)
    equality = 0;
    return;
end
% compare carrier frequency
if h_layout.simpar.center_frequency ~= params.s.center_frequency
    equality = 0;
    return;
    
end

