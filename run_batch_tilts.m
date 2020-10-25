clc;
clear all;
close all;

tilts = 10:1:10;

for j = 1:length(tilts)
    
    fprintf('-------------------------------\n')
    fprintf('%i/%i:Running tilt = %d ...\n',j,length(tilts),tilts(j))
    power_map_and_path_tilt(tilts(j));
    fprintf('%i/%i:Finished tilt = %d\n',j,length(tilts),tilts(j))
    fprintf('-------------------------------\n')
    
end
