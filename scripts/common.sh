
set -e

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

if [ -n "$BASH_VERSION" ]; then
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
elif [ -n "$ZSH_VERSION" ]; then
  SCRIPT_DIR="${0:a:h}"
else
  echo "Unknown shell"
  exit 1
fi

PERFORMING_MANUAL_QA="yes"
PERFORMING_MANUAL_QA="no"

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

for TEST_FILE in "${ALL_TEST_FILES[@]}"; do
  set -e
  TESTS=()
  echo "Loading test: $TEST_FILE"
  source "$TEST_FILE"
  for TEST in "${TESTS[@]}"; do
    msg-info "Running: $TEST"
    if "$TEST"; then
      msg-success "Success: $TEST"
    else
      msg-error "Failure: $TEST"
      exit 1
    fi
  done
done

if [[ "$PERFORMING_MANUAL_QA" == "yes" ]]; then
  for QA_FILE in "${ALL_QA_FILES[@]}"; do
    set -e
    echo "Loading manual QA file: $QA_FILE"
    source "$QA_FILE"
  done
fi