function varargout = RandomizeUE(N, P_local, local_radius, tot_time, center_x, center_y, max_xy, P_turn)
%RandomizeUE generate N UE locations and velocities, with probability
%P_local to be within local_radius distance from the center x-y
%coordinates and 1-P_local are uniform over the entire 
% [(-may_xy, -maxy_xy),(max_xy, max_xy)]. Assumes all UEs are driving and 1.5m tall.
% P_turn is the probability to turn every t_unit seconds

t_unit = 1; % 5 second increments
min_local_radius = 10;
% OUTPUT
% all_locs is [N, 3] for x,y,z location
% all_vels is [N, 3, max(segments)] where max(segments) is based on the
% maximum number of different straight segments a UE takes, broken up by
% turns
if nargin < 4
    error("Provide the minimum N, P_local, local_radius, time");
end
if nargin < 5
    center_x = 0;
end
if nargin < 6
    center_y = 0;
end
if nargin < 7
    max_xy = 500;
end
if nargin < 8
    P_turn = 0.1;
end

no_local_UEs = sum(rand(N, 1) < P_local);
no_wide_UEs = N - no_local_UEs;

all_locs = zeros(N, 3);

local_UEs_radii = min_local_radius + (local_radius-10) .* rand(no_local_UEs, 1);
wide_UEs_radii = -max_xy + 2*max_xy .* rand(no_wide_UEs, 1);

thetas = 2*pi*rand(N, 1);

all_locs(:, 3) = 1.5; % 1.5m tall UEs

% Assign the local UEs
all_locs(1:no_local_UEs, 1) = local_UEs_radii .* cos(thetas(1:no_local_UEs)) + center_x;
all_locs(1:no_local_UEs, 2) = local_UEs_radii .* sin(thetas(1:no_local_UEs)) + center_y;

% Assign widely spaced UEs
all_locs(no_local_UEs+1:end, 1) = wide_UEs_radii .* cos(thetas(no_local_UEs+1:end));
all_locs(no_local_UEs+1:end, 2) = wide_UEs_radii .* sin(thetas(no_local_UEs+1:end));

init_headings = 2*pi*rand(N, 1);
% common walking speed is 1.4m/s with 0.15m/s standard deviation
speeds = 15 + 3*randn(N, 1);
distances = speeds .* tot_time;
no_segments = floor(tot_time / t_unit);

total_turns = zeros(N, 1);
for i=1:N
    total_turns(i) = sum(rand(no_segments, 1) < P_turn, 'all');
end
turns = rand(N, no_segments) < P_turn;

all_vels = zeros(N, 3, no_segments); % last dimension to handle turns
all_vels(:, 1, 1) = speeds .* cos(init_headings);
all_vels(:, 2, 1) = speeds .* cos(init_headings);

for i=1:N
    new_angle = init_headings(i);
    for j=1:no_segments
        if turns(i, j)
        % Turns are between 70-110 degrees +-
            turn_dir = deg2rad(sign(rand()-0.5) * (70 + 40*rand()));
            new_angle = new_angle + turn_dir;  
        end
        all_vels(i, 1, j) = speeds(i) * cos(new_angle);
        all_vels(i, 2, j) = speeds(i) * sin(new_angle);  
    end
end

varargout{1} = all_locs;
varargout{2} = all_vels;
if nargout > 2
    varargout{3} = speeds;
end
if nargout > 3
    varargout{4} = no_segments;
end
if nargout > 4
    varargout{5} = t_unit;
end
if nargout >5
    varargout{6} = turns;

end

