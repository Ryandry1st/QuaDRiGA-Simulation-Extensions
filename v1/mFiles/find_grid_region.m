function [LOS] = find_grid_region(point, grid)
% This function takes a point with position (x, y) and probability 
% grid of (xx, yy, LOS/NLOS) and returns which region [x1:x2], [y1:y2] and
% whether it is in LOS=1 or NLOS=0
% grid.LOS should be 2D x,y index and 1 is LOS=1 or
% NLOS=0

if ~isstruct(grid)
    disp("Grid must be a struct object with xx, yy, and los definitions")
%     x_region = [0, 0];
%     y_region = [0, 0];
    LOS = 2;
    return;
else
    x_grid = find(grid.xx <= point(1), 1, 'last');
    y_grid = find(grid.yy <= point(2), 1, 'last');
    x_grid = [x_grid x_grid+1];
    y_grid = [y_grid y_grid+1];
%     x_region = grid.xx(x_grid);
%     y_region = grid.yy(y_grid);
    LOS = grid.los(x_grid(1), y_grid(1));
end


end

