#!/bin/bash

set -e

TEST_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

git clone https://github.com/maludwig/bashrc "$HOME/bashrc"
"$HOME/bashrc/install"
if [[ -f "$HOME/bashrc.extensions/main" ]]; then
  echo "$HOME/bashrc.extensions/main exists"
else
  echo "ERROR: $HOME/bashrc.extensions/main does not exist"
  exit 1
fi

"$HOME/bashrc.extensions/scripts/run_all_tests.bash"
"$HOME/bashrc.extensions/scripts/run_all_tests.zsh"

if [[ `whoami` != "root" ]]; then
  sudo -H "$TEST_SCRIPT_DIR/test_script.sh"
  echo "Successful"
fi

