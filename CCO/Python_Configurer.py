import numpy as np
import json

desired_output_path = ''

# DEFINE THESE VALUES

# Be sure to copy and replicate for the number of UEs and BSs desired.

# Other values will be added to define parameters such as antenna beamwidths, front to back ratio, etc.
# If not specified, defaults will be used [67 deg azimuth beamwidth, 7.5 deg elevation beamdwidth, -30dB FBR]
# and can be changed in the MATLAB init_sim script.

config = {
    'simulation': {
        'sim_num': '0.5',                                 # should be a string
        'seed': 0,
        'carrier_frequency_Mhz': 28000.0,
        'sampling_frequency_hz': 1000,
        'samples': 10000,                                  # not currently used
        'bandwidth_Mhz': 10,                               # not currently used
        'resource_blocks': 50,                             # not currently used
        'simulation_duration_s': 10,
        'scenario': '3GPP_3D_UMi_LOS', # 3GPP_3D_UMi_LOS, Freespace
        'CCO_0_MRO_1': 0,   # set to 1 for MRO or 0 for CCO
        'no_tx': 3,
        'sample_distance': 10,
        'no_rx_min': 500,  
        'BS_drop': '0',     # set to 'csv', 'rnd', 'hex', to generate new BS locations
        'batch_tilts': [7], # make this blank to keep defined BS tilts
        'parallel': 0,
        },
    'UE': [
        {
            'name': 'UE_1',
            'initial_position': [0, 100, 1.5],
            'velocity': [-0.15, -10, 0],
        },
        {
            'name': 'UE_2',
            'initial_position': [0, 100, 1.5],
            'velocity': [-0.15, -10, 0],
        }
        ],
    'BS': [
                {
            'name' : 'BS_1',
            'location' : [-500, 500, 30],
            'number_of_sectors': 3,
            'azimuth_rotations_degrees' : [135, -135, 0],
            'downtilts_degrees' : [5, 2, 5],
            'tx_p_dbm' : 36.9897,
            'azimuth_beamwidth_degrees': 67,
            'elevation_beamwidth_degrees': 7.5,
            'front_to_back_ratio': -30
            },
            {
            'name' : 'BS_2',
            'location' : [900, -300, 20],
            'number_of_sectors': 3,
            'azimuth_rotations_degrees' : [45, -45, 180],
            'downtilts_degrees' : [7, 10, 10],
            'tx_p_dbm' : 36.9897,
            'azimuth_beamwidth_degrees': 67,
            'elevation_beamwidth_degrees': 7.5,
            'front_to_back_ratio': -30
            },
        {
            'name' : 'BS_3',
            'location' : [0, 0, 25],
            'number_of_sectors': 3,
            'azimuth_rotations_degrees' : [0, 135, -135],
            'downtilts_degrees' : [25, 45, 45],
            'tx_p_dbm' : 36.9897,
            'azimuth_beamwidth_degrees': 67,
            'elevation_beamwidth_degrees': 7.5,
            'front_to_back_ratio': -30
            },
        ]
}

print(f"Preparing simulation number {config['simulation']['sim_num']}")

print(f"... Setting path loss model to {config['simulation']['scenario']}");

if len(config['simulation']['batch_tilts']) == 0:
    print("... using the BS tilts you defined.")
elif len(config['simulation']['batch_tilts']) == 1:
    print(f"...Setting all BS tilts to {config['simulation']['batch_tilts']}");
else:
    print(f"...You tried to set multiple tilts, but this is not available yet, falling back to just {config['simulation']['batch_tilts'][0]} degrees.")

if config['simulation']['BS_drop'] == 'hex' or config['simulation']['BS_drop'] == 'rnd' or config['simulation']['BS_drop'] == 'csv':
    print(f"...Using a new BS layout for {config['simulation']['no_tx']} locations")
else:
    print("...Using the BS locations you defined")

if config['simulation']['CCO_0_MRO_1'] == 0 and config['simulation']['no_rx_min'] < 1000:
    print(f"...Did you mean to do CCO? You have chosen very few no_rx_min={config['simulation']['no_rx_min']}.'")

# store in a file
with open(desired_output_path+'config.json', 'w') as file_out:
    json.dump(config, file_out)
