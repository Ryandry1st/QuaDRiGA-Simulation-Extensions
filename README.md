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
  
  The average time to run a simulation is usually around 30 minutes to 24 hours depending on your resolution, so plan accordingly.
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

  
