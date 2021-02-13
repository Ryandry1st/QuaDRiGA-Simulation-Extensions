%postprocessing visualization
close all;
clear all;
clc
run_i = 'freespace';
file_name = 'powermatrixDT16.mat';
savedResultFile = [pwd,sprintf('/savedResults/%s/mat/',run_i),file_name];
if exist(savedResultFile, 'file')
    mvrcQv2_plotresults(savedResultFile);
end
%----------------------------


