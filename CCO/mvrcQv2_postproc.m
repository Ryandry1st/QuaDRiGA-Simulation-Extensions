%postprocessing visualization
close all;clear all;clc

run_i = 'temp';
file_name = 'powermatrixDT2';

file_name_mat = [file_name,'.mat'];
savedResultFile = [pwd,sprintf('/savedResults/%s/mat/',run_i),file_name_mat];
if exist(savedResultFile, 'file')
    rsrp_fig = mvrcQv2_plotresults(savedResultFile);
    %----------------------------
    if ~exist([pwd,sprintf('/savedResults/%s/fig',run_i)], 'dir')
        mkdir([pwd,sprintf('/savedResults/%s/fig',run_i)]);
    end
    saveas(rsrp_fig,[pwd,sprintf('/savedResults/%s/fig/',run_i),file_name,'.png'])
end