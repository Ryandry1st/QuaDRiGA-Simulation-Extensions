import numpy as np
import json
import sys
from pathlib import Path

json_file = sys.argv[1]
print(json_file)
#filepath=(Path(__file__).parent.absolute())
#filepath=(Path().absolute())

#fn_json = str(filepath)+"/savedResults/json/"+json_file+".json"
#fn_npz = str(filepath)+"/savedResults/npz/"+json_file+".npz"
# instead, given the json file, write the same but as npz

fn_npz = str(json_file)[:-4] + 'npz'
with open(json_file, "r") as f:
    pmap = json.load(f)
for k, vals in pmap.items():
    pmap[k] = np.array(vals)
np.savez_compressed(fn_npz, **pmap)