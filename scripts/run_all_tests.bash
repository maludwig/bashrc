#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# Record this directory for later reference
export BASHRC_DIR="$(dirname "$SCRIPT_DIR" )"

source "$SCRIPT_DIR/common.sh" "$@"
