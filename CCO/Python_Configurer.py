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
        'MRO': 0,
        'no_tx': 3,
        'downtilt': 5,
        'sample_distance': 10,
        'no_rx_min': 2000,
        'BS_drop': '0',
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


# store in a file
with open(desired_output_path+'config.json', 'w') as file_out:
    json.dump(config, file_out)
