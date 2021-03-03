function mvrcQv2_batchrun(params)

tilts = params.info.simulation.batch_tilts;

param_copies = {};
for n=1:numel(tilts)
   param_copies{n} = params;
   param_copies{n}.downtilt = tilts(n);
   param_copies{n}.orientations(:, 2) = tilts(n);
end


parfor n = 1:numel(tilts)

    big_tic = tic;
    
    %----------------------------

    %main run
    fprintf('----------------------------------------------\n')
    fprintf('BATCHRUN(%i/%i):Running tilt = %d ...\n', n, numel(tilts), tilts(n))

    if params.sim_style
        mvrcQv2_CCO(param_copies{n});
    else
        mvrcQv2_MRO(param_copies{n});
    end

    fprintf('BATCHRUN(%i/%i):Finished tilt = %d\n', n, numel(tilts), tilts(n))
    fprintf('----------------------------------------------\n')
    %----------------------------

    fprintf('[tilt=%.0f] runtime: %.1f sec (%1.1f min)\n',tilts(n), toc(big_tic), toc(big_tic)/60);

end

