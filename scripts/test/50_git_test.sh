
_is_git_repo_test () {
  OLD_PWD="$PWD"
  TEMP_DIR="$(mktemp -d)"
  cd "$TEMP_DIR"
  ! is_git_repo
  git init
  is_git_repo
  cd "$OLD_PWD"
  echo rm -r "$TEMP_DIR/.git"
}

_git_branch_name_test () {
  OLD_PWD="$PWD"
  TEMP_DIR="$(mktemp -d)"
  cd "$TEMP_DIR"
  [[ "$(git_branch_name)" == "" ]]
  git init
  git config user.email "you@example.com"
  git config user.name "Your Name"
  [[ "$(git_branch_name)" == "<new>" ]]
  git checkout master
  echo "hi" > hi.txt
  git add hi.txt
  git commit -m "first"
  [[ "$(git_branch_name)" == *"master"* ]]

  cd "$OLD_PWD"
  echo rm -r "$TEMP_DIR/.git"
}

TESTS=(_is_git_repo_test _git_branch_name_test)
