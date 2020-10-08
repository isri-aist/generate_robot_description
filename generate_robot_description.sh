#!/bin/bash

######################################################################
## Conversion tool from VRML model to a robot_description package   ##
## Generates: urdf, dae meshes, convex hulls                        ##
######################################################################

# Load default configuration variables
echo "-- Sourcing configuration generate_config.sh"
. generate_config.sh

echo "Running generate_robot_description.sh script from directory `pwd`"

exit_if_error()
{
  if [ $? -ne 0 ]
  then
    echo "-- FATAL ERROR: $1"
    exit 1
  fi
}

# Path for the generated robot files
mkdir -p ${tmp_path}/qc
mkdir -p ${gen_path}
cp -r ${this_dir}/robot_description_template/* $gen_path
mkdir -p ${gen_path}/cmake
mkdir -p ${gen_path}/collada
mkdir -p ${gen_path}/convex
mkdir -p ${gen_path}/meshes
mkdir -p ${gen_path}/rsdf
mkdir -p ${gen_path}/urdf
mkdir -p ${gen_path}/vrml

# Copy generated vrml files
cp ${build_dir}/model/*.wrl ${gen_path}/vrml
cp `ls ${robot_dir}/model/*.wrl | grep -v '.in.wrl$'` ${gen_path}/vrml

# generate robot model (VRML, collada, urdf and dae meshes)
function generate_urdf()
{
  vrml_model="$1"
  vrml_model_name="${vrml_model%.*}"
  gen_collada_path=${gen_path}/collada/${vrml_model_name}.dae
  gen_urdf_path=${gen_path}/urdf/${vrml_model_name}.urdf
  openhrp-export-collada -i ${gen_path}/vrml/${vrml_model} -o ${gen_collada_path} ${openhrp_export_collada_options}
  exit_if_error "Failed to convert VRML model to collada ($vrml_model})"
  rosrun collada_urdf collada_to_urdf ${gen_collada_path} --output_file ${gen_urdf_path} --mesh_output_dir ${gen_path}/meshes --mesh_prefix "${urdf_mesh_prefix}/meshes" ${collada_urdf_options}
  exit_if_error "Failed to convert collada to urdf (${gen_collada_path})"
}

for vrml_model in $models
do
  echo "-- Generating ${vrml_model}"
  generate_urdf $vrml_model
done

# Generate convexes (convert to qhull's pointcloud and compute convex hull file)
for mesh in ${gen_path}/meshes/*.dae
do
  mesh_name=`basename -- "$mesh"`
  mesh_name="${mesh_name%.*}"
  echo "-- Generating convex hull for ${mesh}"
  gen_cloud=${tmp_path}/qc/$mesh_name.qc
  gen_convex=${gen_path}/convex/${mesh_name}-ch.txt
  mesh_sampling ${mesh} ${gen_cloud} --type xyz --samples ${sample_points}
  exit_if_error "Failed to sample pointcloud from mesh ${mesh} to ${gen_cloud}"
  qconvex TI ${gen_cloud} TO ${gen_convex} Qt o f
  exit_if_error "Failed to compute convex hull pointcloud from point cloud ${gen_cloud} to ${gen_convex}"
done

# Copy surface definitions if they exist
if [ -d $robot_dir/rsdf ]
then
  echo "-- Adding surface definitions from $robot_dir/rsdf"
  cp $robot_dir/rsdf/*.rsdf $gen_path/rsdf
else
  echo "Warning: no rsdf surface definition in $this_dir"
fi

# Replace template variables
echo "-- Configuring template variables"
function replace_template_variables()
{
  echo "-- Replacing variables in $1"
  sed -i -e"s#@ROBOT_NAME@#${robot_name}#g" $1
  sed -i -e"s#@ROBOT_DESCRIPTION_NAME@#${robot_desc_name}#g" $1 
  sed -i -e"s#@ROBOT_DESCRIPTION_DESCRIPTION@#${description}#g" $1
  sed -i -e"s#@ROBOT_DESCRIPTION_VERSION@#${version}#g" $1 
  sed -i -e"s#@ROBOT_DESCRIPTION_MAINTAINER_NAME@#${maintainter_name}#g" $1
  sed -i -e"s#@ROBOT_DESCRIPTION_MAINTAINER_EMAIL@#${maintainter_email}#g" $1
  sed -i -e"s#@ROBOT_REPOSITORY@#${robot_repository}#g" $1
  sed -i -e"s#@ROBOT_DESCRIPTION_REPOSITORY@#${robot_repository}#g" $1
}
replace_template_variables ${gen_path}/package.xml
replace_template_variables ${gen_path}/CMakeLists.txt
replace_template_variables ${gen_path}/README.md

echo
echo "Successfully generated ${robot_desc_name} package in ${gen_path}"
echo "You should now compile and install it"
