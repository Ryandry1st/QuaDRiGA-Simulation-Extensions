function [map, x_coords, y_coords, p_builder] = power_map_const(h_layout, scenario, usage, sample_distance, ...
    x_min, x_max, y_min, y_max, rx_height, tx_power, i_freq)
%POWER_MAP Calculates a power-map for the given layout.
%
% Calling object:
%   Single object
%
% Description:
%    This function calculates receive power values in [W] on a square lattice at a height of
%    'rx_height' above the ground for the given layout. This helps to predict the performance for a
%    given setup.
%
% Input:
%   scenario
%   The scenario for which the map shall be created. There are four options:
%      * A string describing the scenario. A list of supported scenarios can be obtained by calling
%        'qd_builder.supported_scenarios'.
%      * A cell array of strings describing the scenario for each transmitter in the layout.
%      * A 'qd_builder' object. This method is useful if you need to edit the parameters first. For
%        example: call 'p = qd_builder('UMal')' to load the parameters. Then edit 'p.scenpar' or
%        'p.plpar' to adjust the settings.
%      * Aa array of 'qd_builder' objects describing the scenario for each transmitter in the
%        layout.
%
%
%   usage
%   A string specifying the detail level. The following options are implemented:
%      * 'quick' - Uses the antenna patterns, the LOS path, and the path gain from the scenario
%      * 'sf' - Uses the antenna patterns, the LOS path, the path gain from the scenario, and a
%         shadow fading map
%      * 'detailed' - Runs a full simulation for each pixel of the map (very slow)
%      * 'phase' - Same as quick, but the output contains the complex-valued amplitude instead of
%        the power
%
%
%   sample_distance
%   Distance between sample points in [m] (default = 10 m)
%
%   x_min
%   x-coordinate in [m] of the top left corner
%
%   x_max
%   x-coordinate in [m] of the bottom right corner
%
%   y_min
%   y-coordinate in [m] of the bottom right corner
%
%   y_max
%   y-coordinate in [m] of the top left corner
%
%   rx_height
%   Height of the receiver points in [m] (default = 1.5 m)
%
%   tx_power
%   A vector of tx-powers in [dBm] for each transmitter in the layout. This power is applied to
%   each transmit antenna in the tx-array antenna. By default (if tx_power is not given), 0 dBm are
%   assumed.
%
% Output:
%   map
%   A cell array containing the power map for each tx array in the layout. The power maps are given
%   in [W] and have the dimensions [ n_y_coords , n_x_coords , n_rx_elements , n_tx_elements ].
%
%   x_coords
%   Vector with the x-coordinates of the map in [m]
%
%   y_coords
%   Vector with the y-coordinates of the map in [m]
%
%
% QuaDRiGa Copyright (C) 2011-2019
% Fraunhofer-Gesellschaft zur Foerderung der angewandten Forschung e.V. acting on behalf of its
% Fraunhofer Heinrich Hertz Institute, Einsteinufer 37, 10587 Berlin, Germany
% All rights reserved.
%
% e-mail: quadriga@hhi.fraunhofer.de
%
% This file is part of QuaDRiGa.
%
% The Quadriga software is provided by Fraunhofer on behalf of the copyright holders and
% contributors "AS IS" and WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, including but not limited to
% the implied warranties of merchantability and fitness for a particular purpose.
%
% You can redistribute it and/or modify QuaDRiGa under the terms of the Software License for
% The QuaDRiGa Channel Model. You should have received a copy of the Software License for The
% QuaDRiGa Channel Model along with QuaDRiGa. If not, see <http://quadriga-channel-model.de/>.

if numel(h_layout) > 1
    error('QuaDRiGa:qd_layout:power_map', 'power_map not definded for object arrays.');
else
    h_layout = h_layout(1, 1); % workaround for octave
end

% Set the usage mode
if exist('usage', 'var') && ~isempty(usage)
    if strcmp(usage, 'sf') || ...
            strcmp(usage, 'detailed') || ...
            strcmp(usage, 'quick') || ...
            strcmp(usage, 'phase')
        % OK
    else
        error('Usage scenario not supported.')
    end
else
    usage = 'quick';
end

if ~exist('sample_distance', 'var') || isempty(sample_distance)
    sample_distance = 10;
end

% Check if tx-power is given
if ~exist('tx_power', 'var') || isempty(tx_power)
    tx_power = zeros(1, h_layout.no_tx);
elseif numel(tx_power) == 1 && isreal(tx_power)
    tx_power = ones(1, h_layout.no_tx) * tx_power;
elseif any(size(tx_power) ~= [1, h_layout.no_tx])
    error(['??? Number of columns in "tx_power" must match the number', ...
        ' of transmitters in the layout.'])
elseif isnumeric(tx_power) && isreal(tx_power)
    % OK
else
    error('??? "tx_power" has wrong format.')
end

% Check if rx_height is given
if ~exist('rx_height', 'var') || isempty(rx_height)
    rx_height = 1.5;
end

% Check if i_freq is given
if ~exist('i_freq', 'var') || isempty(i_freq)
    i_freq = 1;
end

try
    fprintf('\tLoading old builder object...');
    if ismac
        load('tracks/builder_obj.mat');
    else
        load('tracks\builder_obj.mat');
    end
    fprintf('Success.\n');
catch
    fprintf('Could not find a builder object at tracks/builder_obj.mat -> making a new builder...\n')
    [map, x_coords, y_coords, p_builder] = h_layout.power_map(scenario, usage, sample_distance, x_min, x_max, y_min, y_max, rx_height, tx_power, i_freq);
    save('tracks/builder_obj.mat', '-v7.3', 'p_builder');
    return
end

if nargin <= 4
    x_min = min(h_layout.tx_position(1, :));
    y_max = max(h_layout.tx_position(2, :));
    x_max = max(h_layout.tx_position(1, :));
    y_min = min(h_layout.tx_position(2, :));

    extend = max([0.33 * (x_max - x_min), 0.33 * (y_max - y_min), 200]);

    x_min = floor((x_min - extend)/sample_distance) * sample_distance;
    x_max = ceil((x_max + extend)/sample_distance) * sample_distance;
    y_max = ceil((y_max + extend)/sample_distance) * sample_distance;
    y_min = floor((y_min - extend)/sample_distance) * sample_distance;
end


% Get the sample grid in x and y direction
x_coords = x_min:sample_distance:x_max;
y_coords = y_max:-sample_distance:y_min;

n_x_coords = numel(x_coords);
n_y_coords = numel(y_coords);
n_coords = n_x_coords * n_y_coords;

n_bs = h_layout.no_tx;

for i_bs = 1:n_bs
    p_builder(1, i_bs).tx_array(1, :) = h_layout.tx_array(1, i_bs);
end


if strcmp(usage, 'sf')
    % Calculate parameter maps
    init_sos(p_builder);
    usage = 'quick';
end

map = cell(1, n_bs);

switch usage
    case 'quick'
        for i_bs = 1:n_bs
            %h_channel = channel_builder.get_los_channels(h_builder(1,i_bs));
            coeff = get_los_channels(p_builder(1, i_bs), 'single', 'coeff');

            pow = permute(abs(coeff).^2, [3, 1, 2]);
            pow = reshape(pow, n_x_coords, n_y_coords, size(coeff, 1), size(coeff, 2));
            pow = permute(pow, [2, 1, 3, 4]);

            % Add tx_power
            pow = pow .* 10.^(0.1 * tx_power(i_bs));

            map{i_bs} = pow;

        end

    case 'phase'
        for i_bs = 1:n_bs
            coeff = get_los_channels(p_builder(1, i_bs), 'single', 'coeff');

            cf = permute(coeff, [3, 1, 2]);
            cf = reshape(cf , n_x_coords , n_y_coords , size(coeff, 1), size(coeff, 2));
            cf = permute(cf, [2, 1, 3, 4]);

            % Add tx_power
            cf = cf .* sqrt(10.^(0.1 * tx_power(i_bs)));

            map{i_bs} = cf;
        end

    case 'detailed'
        % Calculate the maps
        for i_bs = 1:n_bs
            % Calculate channels
            h_channel = get_channels(p_builder(1, i_bs));

            pow = zeros(n_coords, h_channel(1, 1).no_rxant, h_channel(1, 1).no_txant);
            for n = 1:n_coords
                tmp = abs(h_channel(1, n).coeff(:, :, :, 1)).^2;
                pow(n, :, :) = sum(tmp, 3);
            end
            pow = reshape(pow, n_x_coords, n_y_coords, h_channel(1).no_rxant, h_channel(1).no_txant);
            pow = permute(pow, [2, 1, 3, 4]);

            % Add tx_power
            pow = pow .* 10.^(0.1 * tx_power(i_bs));

            map{i_bs} = pow;
        end
end

end
