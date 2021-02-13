%postprocessing visualization
close all;
clear all;
clc
run_i = 9;
file_name = 'powermatrixDT-60.mat';
savedResultFile = [pwd,sprintf('/savedResults/r%i/mat/',run_i),file_name];
if exist(savedResultFile, 'file')
    mvrcQv2_plotresults(savedResultFile);
end
%----------------------------


