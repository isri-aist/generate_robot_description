# Description files for @ROBOT_NAME@. 

This package was automatically generated from @ROBOT_REPOSITORY@. Please **do not modify**.

## Installation

### ROS environment

On an environment with ROS and catkin properly setup

```sh
cd <catkin_data_ws>/src
git clone @ROBOT_DESCRIPTION_REPOSITORY@ 
cd ..
catkin build
```

If your catkin environment is sourced `source <catkin_data_ws>/devel/setup.bash`, the robot model will be available to all ROS tools, and `mc_rtc` robot module. 

### ROS-free environement

If you are on an environment without ROS and catkin, you can still install the robot model such that it is found by the non-ROS packages.

```sh
cd src
git clone git@gite.lirmm.fr:mc-hrp5/hrp5_p_description.git 
cd hrp5_p_description
mkdir build
cd build
cmake ..
sudo make install
```
