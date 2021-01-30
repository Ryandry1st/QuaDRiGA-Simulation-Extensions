import numpy as np
import json
import sys
import os
from pathlib import Path
import re

# json_file = sys.argv[1]
json_file = 'savedResults/json/powermatrixDT7.json'
print(json_file)

filepath = re.match(r'(.*[json]+/)(.*)(\.json)+', json_file).group(1)
file_name = re.match(r'(.*[json]+/)(.*)(\.json)+', json_file).group(2)
# filepath=(Path(__file__).parent.absolute())
# filepath=(Path().absolute())
fn_npz = filepath[:-5]+'npz/' + file_name + '.npz'
print(fn_npz)

# fn_json = str(filepath)+"/savedResults/json/"+json_file+".json"
# fn_npz = str(filepath)+"/savedResults/npz/"+json_file+".npz"


with open(json_file, "r") as f:
    pmap = json.load(f)
for k, vals in pmap.items():
    pmap[k] = np.array(vals)
np.savez_compressed(fn_npz, **pmap)
