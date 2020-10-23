import numpy as np
from pathlib import Path
import json
import sys

json_file = "/"+sys.argv[1]

filepath=(Path(__file__).parent.absolute())

fn_json = str(filepath)+"/opt_data/json/"+json_file+".json"
fn_npz = str(filepath)+"/opt_data/npz/"+json_file+".npz"

with open(fn_json, "r") as f:
    pmap = json.load(f)
for k, vals in pmap.items():
    pmap[k] = np.array(vals)
np.savez_compressed(fn_npz, **pmap)