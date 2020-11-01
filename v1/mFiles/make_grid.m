function [grid] = make_grid(max_xy, block_size, prob_nlos)
% Generate a grid map over the region with some areas as LOS and some as
% NLOS. This can be used to assign the regions to the tracks then. Takes
% the maximum xy distance, the size of the grid blocks, and the probability
% of getting an NLOS region and returns the grid.

OVERLAP = 0;
no_blocks_xy = ceil(2*max_xy/(block_size-OVERLAP)+0.0001);       % number of blocks in each x/y direction

% matrix of 1 or 0 for each block describing LOS or NLOS
grid.los = randsrc(no_blocks_xy, no_blocks_xy, [0, 1; prob_nlos, 1-prob_nlos]);

%% Visualize the map and define regions
figure;
los_map = image(255*grid.los);
title("LOS (yellow) and NLOS Map (blue)")
xlabel("X block number");
ylabel("Y block number");

% Need to be able to decide if a position is in an NLOS area
grid.xx = -max_xy:2*max_xy/no_blocks_xy:max_xy-0.001;
grid.yy = grid.xx;
end

