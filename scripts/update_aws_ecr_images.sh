#!/bin/bash

set -e

ECR_URL="$1"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCKER_DIR="$SCRIPT_DIR/docker"


# Record this directory for later reference
export BASHRC_DIR="$(dirname "$SCRIPT_DIR" )"

source "$SCRIPT_DIR/src/10_basics.sh"

cd "$DOCKER_DIR"
for DISTRO in *; do
  if [[ -d "$DISTRO" ]]; then
    msg-info "Building $DISTRO..."
    docker build -t bashrc_$DISTRO:latest -f "$DISTRO/Dockerfile" .
    docker tag bashrc_$DISTRO:latest ${ECR_URL}/bashrc_$DISTRO:latest
    docker push ${ECR_URL}/bashrc_$DISTRO:latest
    ask-enter
  fi
done
