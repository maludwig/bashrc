#!/usr/bin/env -i -P /usr/local/bin:/bin bash --norc --noprofile
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  echo "Bash version is too low, use Bash version 4 or higher"
  echo "$BASH_VERSION"
  exit 1
fi

# Record this directory for later reference
export BASHRC_DIR="$(dirname "$SCRIPT_DIR" )"

source "$SCRIPT_DIR/common.sh" "$@"
