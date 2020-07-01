import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import json
import re


# -------------------------- Helper functions ----------------------------- #
def sum_dB(x, axes):
    """
    Assumes you have an ndarray that you wish to sum the power over some axes, but it is currently in dB
    """
    x = 10**((x-30)/10.0)
    x = np.sum(x, axes)
    x = 10*np.log10(x)+30
    return x


def plot_power(power, x_coordinates, y_coordinates, tx_locs):
    """
    Plots the powermap for a given tx_powers ndarray and its coordinates
    """
    power = np.squeeze(power)
    if len(power.shape) == 2:
        plt.title("Power map for One Sector and One Tx")
    # case where you only want to plot one transmitter or one sector
    elif len(power.shape) == 3:
        m = np.argmin(power.shape)
        power = sum_dB(power, m)
        if m == 0:
            plt.title("Power map for One Sector")
        else:
            plt.title("Power map for One Tx")
    # plot over transmitters and sectors
    elif len(power.shape) == 4:
        power = sum_dB(power, (0, -1))
        plt.title("Power map over all transmitters and sectors")

    plt.imshow(power, extent=[np.min(x_coordinates), np.max(x_coordinates), np.min(y_coordinates), np.max(y_coordinates)], origin='lower')
    plt.clim(np.max(power)-30, np.max(power) -5)
    c = plt.colorbar()
    plt.grid()
    c.set_label("Received Power [dBm]")
    plt.xlabel("X [m]")
    plt.ylabel("Y [m]")
    plt.scatter(tx_locs[:, 0], tx_locs[:, 1], c='red', s=25, marker='x')
    plt.show()


def get_powermatrix(file_path):
    """
    Returns the important data from the file at the location given. This is only for the powermatrix information.
    Specifically it returns the x and y coordinates, the transmitter power, the tx locations, and the power at each location
    """
    with open(file_path) as f:
        data = json.load(f)

    # get the x and y coordinates
    x_coor = np.array(data['x'], dtype=np.float32)
    y_coor = np.array(data['y'], dtype=np.float32)
    P_Tx = data['ptx'] # transmit power in watts
    try:
        N_tx = int(re.search(r'\d+', list(data.keys())[-1]).group())
    except ValueError:
        print("Unable to determine the number of transmitters, assuming only 1")
        N_tx = 1

    # gather the power into a single ndarray (transmitter, x, y, sector)
    rx_powers = np.zeros((N_tx, len(x_coor), len(y_coor), 3), dtype=np.float32)
    # transmitter locations (transmitter, [x, y, z])
    tx_locations = np.zeros((N_tx, 3))

    for i in range(1, N_tx+1):
        label = 'Tx{}'.format(i)
        rx_powers[i-1] = data[label+'pwr']
        tx_locations[i-1] = data[label+'loc']

    return x_coor, y_coor, P_Tx, rx_powers, tx_locations


def get_tracks(file_path):
    """
    Returns the information from the frequency response of the track data for each UE.
    """
    pass


def get_tx_loc_from_csv(filepath):
    """
    Gives the locations of the tranmistters from a csv file similar to the one given to use by Mavenir
    """
    import utm

    df = pd.read_csv(filepath)
    rows = len(df.index)
    lats = df['Lat']
    longs = df['Long']
    abs_pos = np.zeros((rows, 3))  # there are three sectors for each BS and one x, y, z coordinate so 1/3 of the rows are useless
    for i in range(rows):
        abs_pos[i, :2] = utm.from_latlon(lats[i], longs[i])[:2]
        abs_pos[i, 2] = int(re.search(r'\d+', df['Tower ht'][i]).group())

    # throw away repetitive values for every 3 rows
    abs_pos = abs_pos[0:-1:3, :]
    # choose a center point now by the one closest to the middle
    mid_point = np.mean(abs_pos[:, :2], axis=0)
    center_tx_id = np.argmin(np.linalg.norm(mid_point - abs_pos[:, :2], axis=1))
    center_tx_pos = abs_pos[center_tx_id]
    # get the relative locations for each transmitter from this point
    relative_pos = abs_pos - center_tx_pos
    relative_pos[:, 2] = abs_pos[:, 2]  # the heights should not be relative
    # round the positions because this may not be exact to less than 1m
    relative_pos = np.round(relative_pos)
    return relative_pos


def get_tx_sector_orientations(filepath):
    df = pd.read_csv(filepath)
    rows = len(df.index)
    azi = df['Azimuth']
    e_tilt = df['E-TILT']
    m_tilt = df['M-TILT']
    sector_info = np.zeros((rows, 2))
    sector_info[:, 0] = azi
    sector_info[:, 1] = e_tilt+m_tilt

    return sector_info


# -------------------------- Example of the functions ----------------------------- #
# Simulation Parameters
dir = 'tracks/DT-1/07-01-14-57/'
filename = 'powermatrix.json'

# print(res := get_tx_loc_from_csv('Mavenir_locs.csv'))

# # see the distances from the map i.e. radial distances to center point
# print(np.linalg.norm(res-res[4, :], axis=1))

# print(get_tx_sector_orientations('Mavenir_locs.csv'))

# x_cord, y_cord, P_tx, rx_pows, tx_locations = get_powermatrix(dir+filename)
# plot_power(rx_pows[:, :, :, :], x_cord, y_cord, tx_locations)
