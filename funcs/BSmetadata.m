% Write out the BS metadata into a shorter file for parsing
metadata = {};

for i=1:l.no_tx
    metadata.BS(i).ID = i;
    metadata.BS(i).loc = round(l.tx_position(:, i));
    metadata.BS(i).azimuth = params.orientations((i-1)*params.no_sectors+1:i*params.no_sectors, 2);
    metadata.BS(i).elevation = params.orientations((i-1)*params.no_sectors+1:i*params.no_sectors, 1);
    metadata.BS(i).tx_pwr = round(sector_pwr((i-1)*params.no_sectors+1:i*params.no_sectors));
end

if ~isOctave
    jsonStr = jsonencode(metadata);
    fid = fopen(append(params.save_folder_r,'metadata.json'), 'w');
    if fid == -1, error('Cannot create JSON file'); end
    fwrite(fid, jsonStr, 'char');
    fclose(fid);
else
    savejson('', metadata, 'FileName', [params.save_folder_r,'metadata.json']);
end