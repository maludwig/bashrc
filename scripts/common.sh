
set -e

help_msg () {
  echo "
    common.sh
      Test shell functions
    Usage:
      # Normal tests
      ./common.sh

      # Include manual QA steps
      ./common.sh --qa
  "
}

PERFORMING_MANUAL_QA="no"
while (( $# > 0 )); do
  case "$1" in
  --qa)
    PERFORMING_MANUAL_QA="yes"
  ;;
  -h|--help)
    help_msg
    exit
  ;;
  *)
    msg-error "Unknown argument: $1"
    help_msg
    exit 1
  ;;
  esac
  shift
done

function cleanup {
  LAST_RETURN_CODE="$?"
  if [[ "$LAST_RETURN_CODE" == 0 ]]; then
    msg-success "-------------------------------"
    msg-success "ALL TESTS PASSED"
    msg-success "-------------------------------"
  else
    msg-error "-------------------------------"
    msg-error "TEST FAILURE ($LAST_RETURN_CODE)"
    msg-error "-------------------------------"
  fi
}
trap cleanup EXIT


function assert-path {
  if [ -d "$1" ]; then
    if ! echo ":${PATH}:" | grep -q ":${1}:"; then PATH="$PATH:$1" ; fi
  fi
  export PATH
}

assert-path "${HOME}/bin"
assert-path "/bin"
assert-path "/usr/bin"
assert-path "/usr/local/bin"

assert-path "/sbin"
assert-path "/usr/sbin"
assert-path "/usr/local/sbin"
assert-path "/opt/python2.7/bin"

assert-path "$BASHRC_DIR/bin"

if [ -n "$BASH_VERSION" ]; then
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
elif [ -n "$ZSH_VERSION" ]; then
  SCRIPT_DIR="${0:a:h}"
else
  echo "Unknown shell"
  exit 1
fi

OLDIFS="$IFS"
IFS=$'\n'
ALL_SOURCE_FILES=($(find "$SCRIPT_DIR/src" -type f -name '*.sh' | LC_COLLATE=C sort))
ALL_TEST_FILES=($(find "$SCRIPT_DIR/test" -type f -name '*.sh' | LC_COLLATE=C sort))
ALL_QA_FILES=($(find "$SCRIPT_DIR/qa" -type f -name '*.sh' | LC_COLLATE=C sort))
IFS="$OLDIFS"

for SOURCE_FILE in "${ALL_SOURCE_FILES[@]}"; do
  set -e
  echo "Loading source: $SOURCE_FILE"
  source "$SOURCE_FILE"
done

run_tests_in_file () {
  TEST_FILE="$1"

  set -e
  TESTS=()
  msg-info "### Loading test file: $TEST_FILE ###"
  source "$TEST_FILE"
  for TEST in "${TESTS[@]}"; do
    msg-info "  - Running: $TEST"
    if "$TEST"; then
      msg-success "  - Success: $TEST"
    else
      msg-success "  - Failure: $TEST ($?)"
      exit 1
    fi
  done
}

for TEST_FILE in "${ALL_TEST_FILES[@]}"; do
  run_tests_in_file "$TEST_FILE"
done
msg-dry "You are HERE"
if [[ "$PERFORMING_MANUAL_QA" == "yes" ]]; then
  msg-info "Running manual QA files:"
  for QA_FILE in "${ALL_QA_FILES[@]}"; do
    run_tests_in_file "$QA_FILE"
  done
else
  msg-info "Skipping manual QA files"
fi
