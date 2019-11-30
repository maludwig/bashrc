#!/usr/bin/env -i bash

set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCKER_DIR="$SCRIPT_DIR/docker"


# Record this directory for later reference
export BASHRC_DIR="$(dirname "$SCRIPT_DIR" )"

source "$SCRIPT_DIR/src/10_basics.sh"

cd "$DOCKER_DIR"
for DISTRO in *; do
  if [[ -d "$DISTRO" ]]; then
    docker build -t maludwig/$DISTRO:latest -f "$DISTRO/Dockerfile" .
    docker run --rm -it -v "$BASHRC_DIR:/bashrc" maludwig/$DISTRO:latest
  fi
done
