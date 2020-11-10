clc;
clear all;
close all;

rng('default');
rng(0);

tilts = 0;

for j = 1:length(tilts)

    fprintf('-------------------------------\n')
    fprintf('%i/%i:Running tilt = %d ...\n', j, length(tilts), tilts(j))
    power_map_and_path_tilt(tilts(j));
    fprintf('%i/%i:Finished tilt = %d\n', j, length(tilts), tilts(j))
    fprintf('-------------------------------\n')

end