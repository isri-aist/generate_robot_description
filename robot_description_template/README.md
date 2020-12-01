# Description files for @ROBOT_NAME@. 

This package was automatically generated from [@ROBOT_REPOSITORY@](https://github.com/@ROBOT_REPOSITORY@). Please **do not modify manually**.

It contains the following directories:
- `collada/`: collada description of this robot
- `urdf/`: urdf description of this robot
- `meshes/`: dae meshes for all links
- `convex/`: convex hulls (generated from pointclouds sampled from the dae meshes)
- `rsdf/`: Special urdf-like format describing surfaces attached to links on the robot
- `vrml/`: VRML model

## Installation

### ROS environment

On an environment with ROS and catkin properly setup (on ubuntu, you need the `catkin-python-tools` package)

```sh
cd <catkin_data_ws>/src
git clone https://github.com/@ROBOT_DESCRIPTION_REPOSITORY@ 
cd ..
catkin build
```

If your catkin environment is sourced `source <catkin_data_ws>/devel/setup.bash`, the robot model will be available to all ROS tools, and `mc_rtc` robot module. 

### ROS-free environement

If you are on an environment without ROS and catkin, you can still install the robot model such that it is found by the non-ROS packages.

```sh
cd src
git clone https://github.com/@ROBOT_DESCRIPTION_REPOSITORY@
cd @ROBOT_DESCRIPTION_NAME@
mkdir build
cd build
cmake ..
sudo make install
```
