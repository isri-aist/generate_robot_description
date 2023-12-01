#!/bin/bash

this_dir=`cd $(dirname $0); pwd`
readonly this_dir
mesh_path=
convex_path="/tmp/convex"
tmp_path="/tmp"
sample_points=2000

exit_if_error()
{
  if [ $? -ne 0 ]
  then
    echo "-- FATAL ERROR: $1"
    exit 1
  fi
}

function generate_convexes()
{
  local mesh_path=$1
  echo `pwd`
  echo "mesh path: $mesh_path"
  # Generate convexes (convert to qhull's pointcloud and compute convex hull file)
  cd ${mesh_path}
  for mesh in `find . -name '*.STL' -o -name '*.stl' -o -name '*.dae' -o -name '*.DAE'`
  do
    #$this_dir/blender_remove_rotation.sh $mesh $mesh
    mesh_base_path=`dirname "${mesh}"`
    mesh_file_name=`basename -- "$mesh"`
    mesh_name="${mesh_file_name%%.*}"
    mesh_path="${mesh_base_path}/${mesh_name}"
    echo "-- Generating convex hull for ${mesh}"
    echo "-- Mesh path: ${mesh_path}"
    mkdir -p ${tmp_path}/qc/${mesh_base_path}
    mkdir -p ${convex_path}/${mesh_base_path}
    gen_cloud=${tmp_path}/qc/$mesh_path.qc
    gen_convex=${convex_path}/${mesh_path}-ch.txt
    echo "-- Generated cloud path is: ${gen_cloud}"
    echo "-- Generated convex path is: ${gen_convex}"
    mesh_sampling ${mesh} ${gen_cloud} --type xyz --samples ${sample_points}
    exit_if_error "Failed to sample pointcloud from mesh ${mesh} to ${gen_cloud}"
    qconvex TI ${gen_cloud} TO ${gen_convex} Qt o f
    exit_if_error "Failed to compute convex hull pointcloud from point cloud ${gen_cloud} to ${gen_convex}"
  done
}

generate_convexes $1
