# Written by Po-Han Huang <pohanh@fb.com> for Maveric
# Mar. 9, 2021

import argparse
import json
import random

hysteresis_list = [x * .5 for x in range(31)]
a3_offset_list = list(range(-30, 31))
ttt_list = [0, 40, 64, 80, 100, 128, 160, 256, 320, 480, 512, 640, 1024, 1280, 2560, 5120]

def bootstrap(
    input_file: str,
    output_file: str,
) -> None:
    with open(input_file, "r") as rp:
        data = json.load(rp)
    bs_entries = []
    for bs in data['BS']:
        bs_entry = {
            "name": bs['name'],
            "number_of_sectors": 3,
            "hysteresis_db": random.choices(hysteresis_list, k = 3),
            "a3_offset_db": random.choices(a3_offset_list, k = 3),
            "time_to_trigger_ms": random.choices(ttt_list, k = 3)
        }
        bs_entries.append(bs_entry)
    output = {
        "NS3":{
            "use_rlc_um": 1,
            "qout_db": -5,
            "qin_db": -3.9,
            "handover_type": "A3Rsrp",
            "number_qout_eval_sf": 200,
            "number_qin_eval_sf": 100,
            "t310": 1000,
            "n310": 6,
            "n311": 2,
            "x2_delay_ms": 0
        },
        "BS": bs_entries
    }
    with open(output_file, "w") as wp:
        json.dump(output, wp, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Get the filenames.')
    parser.add_argument('--output_file', type = str, help='the name for the output file')
    parser.add_argument('--input_file', type = str, help='the name for the input file')
    args = parser.parse_args()
    bootstrap(args.input_file, args.output_file)
