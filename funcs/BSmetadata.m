% Write out the BS metadata into a shorter file for parsing
metadata = {};

for i=1:l.no_tx
    metadata.BS(i).ID = i;
    metadata.BS(i).loc = round(l.tx_position(:, i));
    metadata.BS(i).azimuth = params.orientations((i-1)*l.tx_array(1, i).no_elements+1:i*l.tx_array(1, i).no_elements, 2);
    metadata.BS(i).elevation = params.orientations((i-1)*l.tx_array(1, i).no_elements+1:i*l.tx_array(1, i).no_elements, 1);
    metadata.BS(i).tx_pwr = round(sector_pwr((i-1)*l.tx_array(1, i).no_elements+1:i*l.tx_array(1, i).no_elements), 4, 'significant');
end

jsonStr = jsonencode(metadata);
fid = fopen(append(params.save_folder_r,'metadata.json'), 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid, jsonStr, 'char');
fclose(fid);