%postprocessing visualization
file_name = 'powermatrixDT10.mat';

savedResultFile = [pwd, '/savedResults/mat/', file_name];
if exist(savedResultFile, 'file')
    mvrcQv2_plotresults(savedResultFile);
end
%----------------------------

