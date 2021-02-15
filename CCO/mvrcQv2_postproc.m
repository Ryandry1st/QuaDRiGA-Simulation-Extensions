%postprocessing visualization
close all;
clear all;
clc

run_i = 'hex_tx1_rx20164_3gpp3duma_seed0';
%run_i = 'Freespace';

tilt = [2,4,6,8,10,12,14,16]

for t = 1:length(tilt)
    tilt(t)
    file_name = ['powermatrixDT',num2str(tilt(t))];
    file_name_mat = [file_name,'.mat'];
    savedResultFile = [pwd,sprintf('/savedResults/%s/mat/',run_i),file_name_mat];
    if exist(savedResultFile, 'file')
        [rsrp_fig,gf_fig,cellid_fig] = mvrcQv2_plotresults(savedResultFile);
        %----------------------------
        if ~exist([pwd,sprintf('/savedResults/%s/fig',run_i)], 'dir')
            mkdir([pwd,sprintf('/savedResults/%s/fig',run_i)]);
        end
        saveas(rsrp_fig,[pwd,sprintf('/savedResults/%s/fig/',run_i),file_name,'_rsrp.png'])
        saveas(gf_fig,[pwd,sprintf('/savedResults/%s/fig/',run_i),file_name,'_gf.png'])
        saveas(cellid_fig,[pwd,sprintf('/savedResults/%s/fig/',run_i),file_name,'_cellid.png'])
        
    end
end