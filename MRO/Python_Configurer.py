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
        'no_UE' : 1,
        'seed' : 0,
        'carrier_frequency_hz': 28000000000.0,
        'sampling_frequency_hz': 1000,
        'samples': 10000,                                  # not currently used
        'bandwidth_Mhz': 10,                               # not currently used
        'resource_blocks': 50,                             # not currently used
        'simulation_duration_s': 10,
        'scenario' : 'Freespace',
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
            'location' : [0, 100, 20],
            'number_of_sectors': 1,
            'azimuth_rotations_degrees' : -90,
            'downtilts_degrees' : 15,
            'tx_p_dbm' : 5,
            'azimuth_beamdwidth_degrees': 67,
            'elevation_beamwidth_degrees': 7.5,
            'front_to_back_ratio': -30
            },
            {
            'name' : 'BS_2',
            'location' : [-50*np.sqrt(3), 0, 20],
            'number_of_sectors': 1,
            'azimuth_rotations_degrees' : 45,
            'downtilts_degrees' : 15,
            'tx_p_dbm' : 10,
            'azimuth_beamdwidth_degrees': 67,
            'elevation_beamwidth_degrees': 7.5,
            'front_to_back_ratio': -30
            },
        {
            'name' : 'BS_3',
            'location' : [50*np.sqrt(3), 0, 20],
            'number_of_sectors': 1,
            'azimuth_rotations_degrees' : 135,
            'downtilts_degrees' : 15,
            'tx_p_dbm' : 10,
            'azimuth_beamdwidth_degrees': 67,
            'elevation_beamwidth_degrees': 7.5,
            'front_to_back_ratio': -30
            },
        ]
}


# store in a file
with open(desired_output_path+'config.json', 'w') as file_out:
    json.dump(config, file_out)
