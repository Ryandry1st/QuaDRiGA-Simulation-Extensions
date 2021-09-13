# FB_Quadriga
  This is a code repository for working on Quadriga simulations. The repository includes a download of Quadriga, so the necessary steps are simply to define your configuration within the configurer. *See FB_Quadriga User Guide.pdf*
  
  
  Additionally, the following python requirements are necessary:
  <ul>
  <li> Python >= 3.5 </li>
  <li> Pandas </li>
  <li> Numpy </li>
  <li> Matplotlib </li>
  <li> utm </li>
  </ul>
  
 ## To use
 Review FB_Quadriga User Guide.pdf to see how the initialization, simulation definition, and tools are used.

Please cite our paper if you use this code.

R. M. Dreifuerst, S. Daulton, Y. Qian, P. Varkey, M. Balandat, S. Kasturia,A. Tomar, A. Yazdan, V. Ponnampalam, and R. W. Heath, “Optimizing coverage  and  capacity  in  cellular  networks  using  machine  learning,”  in ICASSP 2021 - 2021 IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP), 2021, pp. 8138–8142.

@INPROCEEDINGS{9414155,
  author={Dreifuerst, Ryan M. and Daulton, Samuel and Qian, Yuchen and Varkey, Paul and Balandat, Maximilian and Kasturia, Sanjay and Tomar, Anoop and Yazdan, Ali and Ponnampalam, Vish and Heath, Robert W.},
  booktitle={ICASSP 2021 - 2021 IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP)}, 
  title={Optimizing Coverage and Capacity in Cellular Networks using Machine Learning}, 
  year={2021},
  volume={},
  number={},
  pages={8138-8142},
  doi={10.1109/ICASSP39728.2021.9414155}}

  </br></br></br>

## Goals
  Ultimately, we need to generate realistic coverage data for use with intelligent algorithms. This data can look like power maps and/or channel information and frequency responses. Two common applications are: Coverage/capacity algorithms and handover algorithms. Each can be generated using different configurations and multiple seeds to build a training dataset.
  </br></br></br>
