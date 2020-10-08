#!/bin/bash

######################################################################
## This script updates the robot_description repository from the
## latest generated model by the generate_robot_description.sh script
######################################################################

# Robot specific configuration (overrides the default configuration options above)
. generate_config.sh

exit_if_error()
{
  if [ $? -ne 0 ]
  then
    echo "-- FATAL ERROR: $1"
    exit 1
  fi
}

# Clone the remote
robot_desc_path="$tmp_path/$robot_desc_name"
if [ -d robot_desc_path ]
then
  echo "ERROR: the robot_description repository has already been cloned in $tmp_path/$robot_desc_name"
  exit 1
fi

# Clone robot_description repository
git clone --recursive https://${maintainer_username}:${REPO_TOKEN}@github.com/${robot_description_repository} ${robot_desc_path}
exit_if_error "Failed to clone robot_description repository ${robot_description_repository}"

# Synchronize files
rsync -av --delete-after --exclude 'build' --exclude '.git' $gen_path/ ${robot_desc_path}
exit_if_error "Failed to sync generated files with robot_description repository ${robot_desc_path}"

# Get parent commit details
cd $robot_dir
ref_commit="`git rev-parse HEAD`"
ref_commit_short="`git rev-parse --short HEAD`"
ref_commit_msg="`git rev-list --format=%B --max-count=1 $ref_commit`"

# Commit and push the changes
cd ${robot_desc_path}
git config --local user.name "Arnaud TANGUY (Automated CI update)"
git config --local user.email "arn.tanguy@gmail.com"
git remote set-url --push origin https://${maintainer_username}:${REPO_TOKEN}@github.com/${robot_description_repository}
git add -A
git commit -m \
"Generated from $ref_commit_short

Source repository: $robot_repository
Source commit: $robot_repository/commit/${ref_commit}
Source commit: $ref_commit_msg"
git push origin main
exit_if_error "Failed to push to remote robot_description repository ${robot_description_repository}"
