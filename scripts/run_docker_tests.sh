#!/usr/bin/env -i bash

set -e

FILTER_IMAGES="$1"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCKER_DIR="$SCRIPT_DIR/docker"


# Record this directory for later reference
export BASHRC_DIR="$(dirname "$SCRIPT_DIR" )"

source "$SCRIPT_DIR/src/10_basics.sh"

cd "$DOCKER_DIR"
for DISTRO in *; do
  if [[ -d "$DISTRO" ]]; then
    if [[ "$FILTER_IMAGES" == "" ]] || [[ "$FILTER_IMAGES" == "$DISTRO" ]]; then
      DISTRO_DIR="$PWD/$DISTRO"
      docker build -t maludwig/$DISTRO:latest -f "$DISTRO_DIR/Dockerfile" "$BASHRC_DIR"
      if docker run --rm -it -v "$BASHRC_DIR:/bashrc" maludwig/$DISTRO:latest; then
        msg-success "
          Success with $DISTRO, try:
            docker run --rm -it --entrypoint bash maludwig/$DISTRO:latest
        "
      else
        msg-error "
          Failure with $DISTRO, try:
            docker run --rm -it --entrypoint bash maludwig/$DISTRO:latest
        "
      fi
    else
      echo "Skipping $DISTRO"
    fi
  fi
done
