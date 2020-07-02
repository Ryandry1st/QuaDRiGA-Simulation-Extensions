# FB_Quadriga
  This is a code repository for working on Quadriga simulations. To run the provided code, please ensure that you have Quadriga setup and MATLAB is able to find the Quadriga code. You can download Quadriga  <a href="https://quadriga-channel-model.de/">here</a>.
  
  Additionally, the following python requirements are necessary:
  <ul>
  <li> Python >= 3.5 </li>
  <li> Pandas </li>
  <li> Numpy </li>
  <li> Matplotlib </li>
  <li> utm </li>
  </ul>
  
 ## To use
  After you have installed the dependencies, open the initialize_sim.m file and make parameter selections for downtilt and transmit power. Then
  save it and open power_map_and_path.m in Matlab and run it to generate the simulation data.


  The average time to run a simulation is usually around 1-24 hours depending on your resolution, so plan accordingly. See the table for some estimate times.
  
  |   Block Size  | Grid Resolution | Number of UEs | Track Length | Runtime |
|:-------------:|:---------------:|:-------------:|:------------:|:-------:|
| 1.2km x 1.2km |        5m       |       1       |     500m     |   1.5hrs  |
|  1.4km x 1.4km|         5m      |       2       |     500m     |   2.5hrs  |

  </br></br></br>

## Goals
  Ultimately, we need to generate realistic coverage data for use with intelligent algorithms. This data can look like power maps and/or channel information and frequency response. 
  </br></br></br>

## Current Issues I am working on
<ul>
  <li> <s>The sectored antennas seem to be showing different radiation power depending on direction. See sector 1 in figs/difference_in_sectors.png.</s> This was fixed by changing the Rx antenna to dipole antenna. </li>
  <li> <s>Determine how to randomly place Rx_tracks while maintaining spacial consistency.</s> This was fixed by addining the randomize_UEs.m function, which uses a grid to assign scenarios to segments. </li>
  <li> Develop a compact data generation and distribution setup. </li>
  <li> Create system for generating powermaps with different scenarios, concatenating, and smoothing them. </li>
</ul>

  
