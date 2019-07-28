# Monte Carlo Localization - Simulator

In this repository you'll find a simulation of a robot localization algorithm based on a *Particle Filter*. The simulator comes with a GUI that allows for exploring the performance of the algorithm under different parameter settings. The project is inspired by the course *Applied Estimation* at *KTH Royal Institute of Technology, Stockholm*.

<p align="center"> 
<img height="400px" src="/images/simulator_gui.png">
</p>

## Implementation Details

The motivation behind the development of this simulator is to create an intuitive understanding of the Particle Filter and how it is applied in the context of robot localization. This is facilitated by allowing for adapting filter parameters during the localization process and being able to directly observe the effect on the algorithm's performance. Furthermore, by providing characteristically different datasets, a range of localization scenarios can be simulated.

### Simulation Data

The robot localization is performed on simulated sensor data. The data includes distance and bearing measurements from a laser range finder as well as odometry information in the form of wheel-encoders. The layout of the environment is defined by the location of observable landmarks.

### Simulation Settings

In order to explore the full capabilities of the Particle Filter, different simulation modes exist along with a wide range of parameters which can be adapted during the simulation.

#### Simulation Mode
* **Tracking:** The Particle Filter is initialized to the position of the robot at the beginning of the simulation and the task is to accurately track the trajectory of the robot.
* **Global Localization:** The Particle Filter is unaware of the robot's initial position and is tasked with locating the robot in the given environment. Therefore, the initial set of particles is randomly scattered across the entire area.

#### Simulation Parameters
* **Number of Particles:** The number of particles can be varied between 10 and 10.000 particles. While tracking problems can already work with a comparably small number of particles, global localization generally requires a large number of particles in order to ensure the presence of particles in all areas of relevant likelihood.
* **Sampling Strategy:** In order to track all relevant hypotheses and ensure the effective contribution of all particles, resampling the set of particles at each iteration is a crucial step. Two different options are available that differ with regard to how the new set of particles is selected. Furthermore, the option to not resample the particles at all is provided for illustrative purposes.
* **Uncertainties:** The underlying models of the sensor and the robot motion are based on the assumption of normally distributed noise with zero mean. The standard deviation of the distributions can be adapted to the circumstances during the simulation. For example, a global localization problem usually requires larger uncertainties in the sensor model in order to allow for a multimodal particle distribution that can track several hypotheses.
* **Data Association:** Data Association is concerned with assigning the available laser readings to the corresponding landmark. This step is performed by computing the likelihood of every landmark for all available measurements based on the underlying sensor model and selecting the maximum likelihood association. By disabling the data association, ground truth information about the correct landmark is used instead of calculating the likelihoods. Thus, the performance of the Particle Filter can be assessed under perfect sensory conditions.
* **Outlier Detection:** In case of noisy measurements or false observations, it can be beneficial to disregard certain measurements in the update step. This technique is referred to as outlier detection. The threshold for the detection is based on the average likelihood of a measurement accross all particles. The threshold can be varied between 0 (outlier detection disabled) and 30.

## How-To Use the Simulator

The simulator can be opened by running: ```mcl_gui.mlapp```
In order to start a simulation, select a dataset from the drop-down menu at the top of the application.
By selecting a dataset, the simulation parameters are automatically set to default values that work well for the given problem. In case the problem is changed (e.g. tracking to global localization), it is recommended to adapt the parameters. 
With all simulation parameters set to the desired values, the simulation can now be started. Widgets for parameters that cannot be changed anymore during the simulation will be disabled with the start of the simulation, all other parameters can still be changed while the simulation is running.
After the full simulation, error statistics will be displayed below the figure on the right that shows a zoomed-in plot of the ground truth position and the current estimate. However, if you wish to stop the simulation before that, the "Stop"-Button can be used. This takes you back to the initial screen and a new simulation can be started.

## Datasets

The simulator comes with two datasets specifically designed for testing robot localization algorithms. In this Section, I would like to give a brief overview of the datasets' characteristics and sketch a few possiblly insightful simulation scenarions along with some illustrations.

### Dataset 1

The first dataset consists of four perfectly symmetric landmarks. The dataset can be used for both simulation modes, global localization and tracking. The default settings of the dataset are set to tracking with a set of 1000 particles. These settings have been observed to work well for the tracking problem. However, if the simulation mode is set to global localization, it is recommended to increase the uncertainty of the sensor model.
Below, two screenshots taken from a simulation are displayed. The left image shows a tracking scenario, while the right image shows a screenshot taken from a global localization problem. In the left image we can observe that a relatively small number of particles suffices to accurately track the robot trajectory due to a number of accurate measurements. The blue trajectory shows the available odometry information computed from the wheel-encoders.
In the right image we observe a global localization scenario. Due to the perfectly symmetric environment, the algorithm has no way of knowing where exactly the robot is located. However, all four relevant hypotheses are accurately tracked with a approximately equal number of particles per hypothesis. Without additional observations that break the symmetry of the environment, this is the optimal localization performance.

<p align="center"> 
<img height="200px" src="/images/dataset_1_illustration.png">
</p>

### Dataset 2

The second dataset is highly similar to the first one and comes with the same default settings. However, one additional fifth landmark exists that breaks the symmetry of the environment. Thus, contrary to the first dataset, the global localization problem can turn into a tracking problem the moment the robot observes the fifth measurement that allows the robot to uniquely identify its position. The process of the global localization problem is displayed in the figure below. In the left image we can observe that we start with an initial set of five valid hypotheses since the robot only observes a single landmark in the beginning that, as far as the algorithm knows, could be any of the five present landmarks. This situation changes the moment the robot gets two valid measurements at the same time. This situation can be observed in the middle image and is analogous to the scenario of four valid hypotheses discussed for the first dataset. Theses hypotheses are tracked accurately until the robot comes within range of the fifth landmark. The moment the first measurement corresponding to the symmetry-breaking landmark is processed, the robot's location can be uniquely identified and all particles are resampled to the robot's location from which the robot can be tracked accurately for the rest of the simulation.

<p align="center"> 
<img height="200px" src="/images/dataset_2_illustration.png">
</p>
