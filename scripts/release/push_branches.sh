#!/usr/bin/env bash

SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
source "$SCRIPT_DIR/common/helper_functions.sh"

# Define functions
function push_branch() {
  repository="$1"
  git_command="git --work-tree=$repository --git-dir=$repository/.git"

  # Get branch name
  branch_name=$($git_command rev-parse --abbrev-ref HEAD)

  # Verify branch name
  if (! is_rc_branch_name "$branch_name") && (! is_experiment_branch_name "$branch_name"); then
    echo -e "\e[32mNot a valid branch name, skipping.\e[m"
    return
  fi

  # Show confirmation
  $git_command show --no-patch --no-notes --pretty=format:'%h %s%n%ad %aN%d' "$branch_name"
  printf "\e[31m"
  read -rp "Are you sure to push origin/$branch_name? [y/N] " answer
  printf "\e[m"

  # Push if the answer is "yes"
  case $answer in
    [yY]* )
      echo -e "\e[32mRun 'git push origin $branch_name'.\e[m"
      $git_command push origin "$branch_name"
      ;;
    * )
      echo -e "\e[32mSkipped.\e[m"
      return
      ;;
  esac
}

# Move to workspace root
cd "$(get_workspace_root)" || exit 1

# Push branches
for repository in $(get_meta_repository) $(get_reference_repositories) $(get_product_repositories); do
  echo -e "\e[36mProcessing '$(readlink -f "$repository")'.\e[m"
  push_branch "$repository"
done
