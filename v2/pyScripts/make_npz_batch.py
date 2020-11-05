"""Construct power map data from multiple power maps (npz format).

        power_maps_path is filepath (local or mounted), e.g.
        "/mnt/shared/yuchenq/power_maps/*.npz".

        Power maps are loaded into the downtilts_maps dictionary,
        keyed on downtilts.

        npz files are generated from original JSON files. Here is the sample code:
            powermaps_dir = Path("/mnt/shared/yuchenq/power_maps")
            for fn in powermaps_dir.iterdir():
                npfn = fn.name.replace(".json", ".npz")
                with open(fn, "r") as f:
                    pmap = json.load(f)
                for k, vals in pmap.items():
                    pmap[k] = np.array(vals)
                np.savez_compressed(powermaps_dir.joinpath(npfn), **pmap)
        """
import numpy as np
from pathlib import Path
import json

quadriga_dir = str(Path(__file__).resolve().parent)
powermaps_dir = Path(quadriga_dir+"/tracks/DT15/09-24-14-00")
for fn in powermaps_dir.iterdir():
    npfn = fn.name.replace(".json", ".npz")
    with open(fn, "r") as f:
        pmap = json.load(f)
    for k, vals in pmap.items():
        pmap[k] = np.array(vals)
    np.savez_compressed(powermaps_dir.joinpath(npfn), **pmap)

