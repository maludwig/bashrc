#!/bin/bash

set -e

DOCKER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTS_DIR="$(dirname "$DOCKER_DIR")"
BASHRC_DIR="$(dirname "$SCRIPTS_DIR")"

env -i "$SCRIPTS_DIR/run_all_tests.bash"
env -i "$SCRIPTS_DIR/run_all_tests.zsh"

"$BASHRC_DIR/install"
if [[ -f "$HOME/bashrc.extensions/main" ]]; then
  echo "$HOME/bashrc.extensions/main exists"
else
  echo "ERROR: $HOME/bashrc.extensions/main does not exist"
  exit 1
fi

env -i "$HOME/bashrc.extensions/scripts/run_all_tests.bash"
env -i "$HOME/bashrc.extensions/scripts/run_all_tests.zsh"

if [[ `whoami` != "root" ]]; then
  sudo -H "$DOCKER_DIR/test_script.sh"
  echo "Successful"
fi

