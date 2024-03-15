#!/bin/bash

######################################################################
## This script updates the robot_description repository from the
## latest generated model by the generate_robot_description.sh script
######################################################################

# Add echo for every command that is executed
set -x

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

exit_with_error()
{
  echo "-- FATAL ERROR: $1"
  exit 1
}

# Clone the remote
robot_desc_path="$tmp_path/$robot_desc_name"
if [ -d robot_desc_path ]
then
  echo "ERROR: the robot_description repository has already been cloned in $tmp_path/$robot_desc_name"
  exit 1
fi

cd $robot_dir

# Check if GITHUB_BRANCH_NAME env variable exists
if [ ! -z "${GITHUB_BRANCH_NAME}" ]; then
  echo "Using GITHUB_BRANCH_NAME=${GITHUB_BRANCH_NAME}";
  pull_branch=${GITHUB_BRANCH_NAME}
else
  # Check whether we are in detached head state
  if [ "`git rev-parse --symbolic-full-name HEAD`" == "HEAD" ]; then
    exit_with_error "cannot determine branch name from a detached head state"
  else
    # We are not in detached head state, get current branch name, and check if it exists on the remote
    branch=`git rev-parse --abbrev-ref HEAD`
    GIT_TRACE=1 GIT_TRACE_CURL=1 git ls-remote --exit-code --heads $remote_uri $branch > /dev/null
    if [ $? == "0" ]; then  # branch exists in remote_uri
        pull_branch="$branch"
    elif [ $? == "128" ]; then
      exit_with_error "Repository $remote_uri not found!"
    fi
  fi
fi

# Special case if there is a master branch in the repository
# If the master branch already exists in the robot_description repository, we push to this branch
# Otherwise, we push to main
if [ "$pull_branch" == "master" ]; then
  # Check if it exists on the remote
  GIT_TRACE=1 GIT_TRACE_CURL=1 git ls-remote --exit-code --heads $remote_uri $pull_branch > /dev/null
  if [ $? == "0" ]; then  # branch master exists in remote_uri
    echo "Branch $pull_branch exists in $remote_uri, pushing to this branch"
    push_branch="$pull_branch"
  else
    echo "Branch $pull_branch does not exist in $remote_uri, pushing to main instead"
    pull_branch="main"
    push_branch="main"
  fi
else
  push_branch="$pull_branch"
fi

echo "==========================="
echo "Pull branch: ${pull_branch}"
echo "Push branch: ${push_branch}"
echo "==========================="

echo "Cloning from ${remote_uri} (branch ${pull_branch}) to ${robot_desc_path}"
# Clone robot_description repository
git clone --recursive --single-branch --branch ${pull_branch} "${remote_uri}" ${robot_desc_path}
exit_if_error "Failed to clone robot_description repository ${robot_description_repository}"

# Synchronize files
rsync -av --delete-after --exclude 'build' --exclude 'calib' --exclude '.git' --exclude '.github' $gen_path/ ${robot_desc_path}
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

echo "Pushing into branch ${push_branch} of ${remote_uri}"
git push -u origin ${push_branch}
exit_if_error "Failed to push to remote robot_description repository ${robot_description_repository}"
