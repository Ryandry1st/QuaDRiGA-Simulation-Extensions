clc;
clear all;
close all;

%set random seed
seed = 0;
%----------------------------

%initialize parameters
params = init_params(seed);
%----------------------------

tilts = 5;

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

%postprocessing visualization
file_name = 'powermatrixDT10.mat';
savedResultFile = [pwd, '/savedResults/mat/', file_name];
if exist(savedResultFile, 'file')
    mvrcQv2_postproc(savedResultFile);
end
%----------------------------