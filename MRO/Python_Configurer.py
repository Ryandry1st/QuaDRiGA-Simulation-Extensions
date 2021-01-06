import numpy as np
import json

desired_output_path = ''

# DEFINE THESE VALUES

# Be sure to copy and replicate for the number of UEs and BSs desired.

# Other values will be added to define parameters such as antenna beamwidths, front to back ratio, etc.
# If not specified, defaults will be used [67 deg azimuth beamwidth, 7.5 deg elevation beamdwidth, -30dB FBR]
# and can be changed in the MATLAB init_sim script.

config = {
    'sim_num': '0.5',
    'no_UE' : 1,
    
    'UE_1_initial_position': [100, -200, 1.5],
    'UE_1_velocity': [-8.4849, 8.4849, 0],
    
    'UE_2_initial_position': [600, 400, 1.5],
    'UE_2_velocity': [0, -24.9988, 0],
    
    'no_BS': 1,
    
    'BS_1_location': [-500, 500, 30],
    'BS_1_number_of_sectors': 3,
    'BS_1_azimuth_rotations_degrees': [135, -135, 0],
    'BS_1_downtilts_degrees': [5, 1, 5],
    'BS_1_Tx_P_dBm': [20, 20, 20],                     
    'BS_1_azimuth_beamwidth_degrees': 67,              # not currently used
    'BS_1_elevation_beamwidth_degrees': 7.5,           # not currently used
    'BS_1_front_to_back_ratio': -30,                   # not currently used
    
    'BS_2_location': [900, -300, 20],
    'BS_2_number_of_sectors': 3,
    'BS_2_azimuth_rotations_degrees': [45, -45, 180],
    'BS_2_downtilts_degrees': [7, 10, 10],
    'BS_2_Tx_P_dBm': [20, 20, 20],
    'BS_2_azimuth_beamwidth_degrees': 67,              # not currently used
    'BS_2_elevation_beamwidth_degrees': 7.5,           # not currently used
    'BS_2_front_to_back_ratio': -30,                   # not currently used
    
    'BS_3_location': [0, 0, 25],
    'BS_3_number_of_sectors': 3,
    'BS_3_azimuth_rotations_degrees': [0, 135, -135],
    'BS_3_downtilts_degrees': [25, 45, 45],
    'BS_3_Tx_P_dBm': [20, 20, 20],
    'BS_3_azimuth_beamwidth_degrees': 67,              # not currently used
    'BS_3_elevation_beamwidth_degrees': 7.5,           # not currently used
    'BS_3_front_to_back_ratio': -30,                   # not currently used

    
    'Carrier_Frequency_Hz': 28000000000.0,
    'Sampling_Frequency_Hz': 1000,
    'Samples': 40000,                                  # not currently used
    'Bandwidth_MHz': 10,                               # not currently used
    'Resource_Blocks': 50,                             # not currently used
    'Simulation_Duration_s': 40
}


# store in a file
with open(desired_output_path+'config.json', 'w') as file_out:
    json.dump(config, file_out)
