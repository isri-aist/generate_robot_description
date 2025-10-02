## Generation paths 
tmp_dir="/tmp"
export tmp_path="$tmp_dir/generate_${robot_desc_name}"      # tmp_path were the files are generated
export gen_path="$tmp_dir/${robot_desc_name}"               # path were the robot_description package gets generated
export build_dir="$robot_dir/build"                     # path to the build directory

## For CI
# Ci will pull/push the robot description package to update it
# You need the appropriate token in github secrets and your user-account.
#
# Github: https://${maintainer_username}:${REPO_TOKEN}@github.com/${robot_description_repository}
# Gitlab: https://oauth2:${REPO_TOKEN}@gite.lirmm.fr/${robot_description_repository}
export remote_uri="https://${maintainer_username}:${REPO_TOKEN}@github.com/${robot_description_repository}"
export repo_uri="https://github.com/$robot_repository"
export main_push_branch="" # Push to same branch name as the current main/master branch by default. If using older existing repositories, use "master" instead
