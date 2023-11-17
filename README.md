# Scripts for generating robot_description from VRML models

This package provides scripts to convert robots defined in VRML to a robot_description package containing:

- `vrml/`: the generated VRML files
- `collada/`: collada description of this robot
- `urdf/`: urdf description of this robot
- `meshes/`: dae meshes for all links
- `convex/`: convex hulls (generated from pointclouds sampled from the dae meshes)
- `rsdf/`: Special urdf-like format describing surfaces attached to links on the robot
- `legacy_description/`: Put in this folder any existing robot description files that can't be generated easily from VRML. They will be copied as-is to the generated robot_description package

## Dependencies

- `openhrp-export-collada` from [openhrp3](https://github.com/fkanehiro/openhrp3)
- `collada_to_urdf` from `ros-<distro>-collada-urdf`
- [mesh_sampling](https://github.com/arntanguy/mesh_sampling)
- [blender](https://www.blender.org/)
- qhull-bin

## Usage

This package is intended to be used as a submodule of the repository containing the VRML robot model for your robot with the following structure:

```
your_robot/
  generate_robot_description/ # this package as a submodule
  generate_config.sh          # configuration file for the generation (see below)
  model/
    *.wrl
  build/model/ #optional: generated vrml files (for various robot variants)
    *.wrl
```

You are expected to provide a `generate_config.sh` file that defines configuration options for the script as variables. It is sourced before the script execution.

```sh
# Configuration options
# To be overridden in the robot package using it in generate_config.sh
readonly this_dir=`cd $(dirname $0); pwd`
readonly robot_dir=`cd $this_dir/..; pwd`
robot_name="hrp5_p"
name="${robot_name}_description"
description="Robot description files for the ${robot_name} robot"
version="0.1.0"
maintainer_name="Arnaud TANGUY"
maintainer_email="arn.tanguy@gmail.com"
robot_repository="https://github.com/isri-aist/hrp5p"
robot_description_repository="https://github.com/isri-aist/hrp5_p_description"

sample_points=10000                   # Number of points to sample on each mesh (used for convex hull generation)
urdf_mesh_prefix="package://${name}"  # Prefix for the mesh paths in the urdf
openhrp_export_collada_options=""     # Extra options for openhrp-export-collada (-a ...)
collada_urdf_options="-G -A"          # Extra options for collada_urdf
tmp_path="/tmp/generate_${name}"      # tmp_path were the files are generated
gen_path="/tmp/${name}"               # path were the robot_description package gets generated
build_dir="$robot_dir/build"          # path to the build directory
models="HRP5Pmain.wrl"                # VRML models to convert to URDF (space-separated)
```

### Generation of the robot_description package

To run the conversion, simply run

```sh
cd generate_robot_description
./generate_robot_description.sh
```

This will generate a robot_description package in `gen_path`.

### Updating the remote repository

To udapte the remote repository the `update_repository.sh` script. It will clone the remote repository, synchronize the new files using rsync, commit and push the changes. This script is intented to be used by continous integration tools.

```sh
cd generate_robot_description
./update_repository.sh
```
