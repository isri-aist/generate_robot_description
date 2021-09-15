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

cd $robot_dir
branch=`git rev-parse --abbrev-ref HEAD`

git ls-remote --exit-code --heads $remote_uri $branch > /dev/null

if [ $? == "0" ]; then  # branch exists in remote_uri
    pull_branch="$branch"
fi

if [ $branch != "master" ] && [ $branch != "main" ]; then
    push_branch="$branch"
fi

echo "Cloning from ${remote_uri} (branch ${pull_branch}) to ${robot_desc_path}"
# Clone robot_description repository
git clone --recursive --single-branch --branch ${pull_branch} "${remote_uri}" ${robot_desc_path}
exit_if_error "Failed to clone robot_description repository ${robot_description_repository}"

# Synchronize files
rsync -av --delete-after --exclude 'build' --exclude 'calib' --exclude '.git' $gen_path/ ${robot_desc_path}
exit_if_error "Failed to sync generated files with robot_description repository ${robot_desc_path}"

# Get parent commit details
cd $robot_dir
ref_commit="`git rev-parse HEAD`"
ref_commit_short="`git rev-parse --short HEAD`"
ref_commit_msg="`git rev-list --format=%B --max-count=1 $ref_commit`"

# Commit and push the changes
cd ${robot_desc_path}
git config --local user.name "${maintainer_name} (Automated CI update)"
git config --local user.email "${maintainer_email}"
git remote set-url --push origin "${remote_uri}"
git checkout -b ${push_branch}
git add -A
git commit -m \
"Generated from $ref_commit_short

Source repository: ${repo_uri}
Source commit: ${repo_uri}/commit/${ref_commit}
Commit details:
$ref_commit_msg"

git push -u origin ${push_branch}
exit_if_error "Failed to push to remote robot_description repository ${robot_description_repository}"
