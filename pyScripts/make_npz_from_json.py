import numpy as np
import json
import sys
from pathlib import Path

json_file = "/"+sys.argv[1]

#filepath=(Path(__file__).parent.absolute())
filepath=(Path().absolute())

fn_json = str(filepath)+"/savedResults/json/"+json_file+".json"
fn_npz = str(filepath)+"/savedResults/npz/"+json_file+".npz"

with open(fn_json, "r") as f:
    pmap = json.load(f)
for k, vals in pmap.items():
    pmap[k] = np.array(vals)
np.savez_compressed(fn_npz, **pmap)