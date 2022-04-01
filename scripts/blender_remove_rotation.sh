#! /bin/sh

local_dir=`dirname $0`

if [ $# -lt 2 ]
then
  echo "Usage: `basename $0` in_file output_file"
  exit 1
fi

in_file=$1
out_file=$2

if [ ! -f "$in_file" ]
then
  echo "'$in_file' is not a valid file."
  exit 2
fi

blender "$local_dir/empty.blend" --background --python "$local_dir/blender_remove_rotation.py" -- "$in_file" "$out_file"
