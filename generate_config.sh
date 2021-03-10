export this_dir=`cd $(dirname $0); pwd`
export robot_dir=`cd $this_dir/..; pwd`
readonly this_dir
readonly robot_dir
export robot_name="robot_name"
export robot_desc_name="${robot_name}_description"
export description="Robot description files for the ${robot_name} robot"
export version="0.1.0"
export maintainer_name="Arnaud TANGUY"
export maintainer_email="arn.tanguy@gmail.com"
export maintainer_username="arntanguy"  # Used to clone/push to the robot_description_repository
export robot_repository="isri-aist/hrp5p" # Github repository name containing the VRML files
export robot_description_repository="arntanguy/hrp5_p_description" # Github repository name where the generated files will be pushed
export urdf_mesh_prefix="package://${robot_desc_name}"  # Prefix for the mesh paths in the urdf

# for visualization
export robot_module_name="HRP5P"             # Name of the robot module
export base_link_frame="base_link"

## Generation options
export models="HRP5Pmain.wrl"                # VRML models to convert to URDF (space-separated)
export sample_points=2000                   # Number of points to sample on each mesh (used for convex hull generation)
export openhrp_export_collada_options=""     # Extra options for openhrp-export-collada (-a ...)
export collada_urdf_options="-G -A"          # Extra options for collada_urdf

## Generation paths 
export tmp_path="/tmp/generate_${robot_desc_name}"      # tmp_path were the files are generated
export gen_path="/tmp/${robot_desc_name}"               # path were the robot_description package gets generated
export build_dir="$robot_dir/build"                     # path to the build directory

## For CI
# Ci will pull/push the robot description package to update it
# You need the appropriate token in github secrets and your user-account.
#
# Github: https://${maintainer_username}:${REPO_TOKEN}@github.com/${robot_description_repository}
# Gitlab: https://oauth2:${REPO_TOKEN}@gite.lirmm.fr/${robot_description_repository}
export remote_uri="https://${maintainer_username}:${REPO_TOKEN}@github.com/${robot_description_repository}"
export repo_uri="https://github.com/$robot_repository"
export pull_branch="main"
export push_branch="main"

## Robot-specific configuration (overrides the above variables)
if [ -f $robot_dir/generate_config.sh ]
then
  echo "-- Sourcing robot-specific configuration $robot_dir/generate_config.sh"
  . $robot_dir/generate_config.sh
else
  echo "-- WARNING: no robot-specific configuration $robot_dir/generate_config.sh"
fi
