#!/usr/bin/env zsh

SCRIPT_DIR="${0:a:h}"
# Record this directory for later reference
export BASHRC_DIR="$(dirname "$SCRIPT_DIR" )"
source "$SCRIPT_DIR/common.sh"