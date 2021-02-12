%postprocessing visualization
run_i = 24;
file_name = 'powermatrixDT6.mat';
savedResultFile = [pwd,sprintf('/savedResults/r%i/mat/',run_i),file_name];
if exist(savedResultFile, 'file')
    mvrcQv2_plotresults(savedResultFile);
end
%----------------------------


