clc;
clear all;
close all;

addpath(genpath([pwd,'/QuaDriGa_2020.11.03_v2.4.0']));

%set random seed
seed = 0;
%----------------------------

%initialize parameters
params = mvrcQv2_init(seed);
%----------------------------

tilts = [2,4,6,8,10,12,14,16];

big_tic = tic;

parfor n = 1:length(tilts)

    small_tic = tic;

    %main run
    fprintf('----------------------------------------------\n')
    fprintf('BATCHRUN(%i/%i):Running tilt = %d ...\n', n, numel(tilts), tilts(n))

    mvrcQv2_main(params,tilts(n));

    fprintf('BATCHRUN(%i/%i):Finished tilt = %d\n', n, numel(tilts), tilts(n))
    fprintf('----------------------------------------------\n')
    %----------------------------

    fprintf('[tilt=%.0f] runtime: %.1f sec (%1.1f min)\n',tilts(n), toc(small_tic), toc(small_tic)/60);

end

fprintf('----------------------------------------------\n')
fprintf('TOTAL SIMULATION RUNTIME: %1.1f hours\n', toc(big_tic)/3600);
fprintf('----------------------------------------------\n')