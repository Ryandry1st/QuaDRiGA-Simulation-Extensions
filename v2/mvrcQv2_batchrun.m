clc;
clear all;
close all;

%set random seed
seed = 0:2:10;
%----------------------------

%initialize parameters
params = mvrcQv2_init(seed);
%----------------------------

tilts = 10;

for n = 1:length(tilts)

    %change params variables here
    params.downtilt = tilts(n);
    %----------------------------

    %main run
    fprintf('----------------------------------------------\n')
    fprintf('BATCHRUN(%i/%i):Running tilt = %d ...\n', n, length(tilts), tilts(n))

    mvrcQv2_main(params);

    fprintf('BATCHRUN(%i/%i):Finished tilt = %d\n', n, length(tilts), tilts(n))
    fprintf('----------------------------------------------\n')
    %----------------------------

end