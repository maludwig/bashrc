
function _assert_vars_equal {
  NAME_ACTUAL="$1"
  NAME_EXPECTED="$2"
  ACTUAL=()
  EXPECTED=()

  eval 'for X in "${'$NAME_ACTUAL'[@]}"; do ACTUAL+=("$X"); done'
  eval 'for X in "${'$NAME_EXPECTED'[@]}"; do EXPECTED+=("$X"); done'
  if [[ "${#ACTUAL[@]}" != "${#EXPECTED[@]}" ]]; then
    msg-error "$NAME_ACTUAL and $NAME_EXPECTED do not match"
    msg-error "$(declare -p $NAME_ACTUAL)"
    msg-error "$(declare -p $NAME_EXPECTED)"
    return 1
  else
    for IDX in `seq 0 "${#ACTUAL[@]}"`; do
      # echo "ACTUAL[$IDX]: ${ACTUAL[$IDX]}"
      # echo "EXPECTED[$IDX]: ${EXPECTED[$IDX]}"
      if [[ "${ACTUAL[$IDX]}" != "${EXPECTED[$IDX]}" ]]; then
        msg-error "$NAME_ACTUAL and $NAME_EXPECTED do not match at index $IDX"
        msg-error "$(declare -p $NAME_ACTUAL)"
        msg-error "$(declare -p $NAME_EXPECTED)"
        return 1
      fi
    done
  fi
}

FIRST=('one two' 'three four')
SECOND=('one two' 'three four')
_assert_vars_equal FIRST SECOND

function _assert_var_equals {
  NAME_ACTUAL="$1"
  shift
  EXPECTED_VALUE="$@"
  _assert_vars_equal "$NAME_ACTUAL" EXPECTED_VALUE
}

unset FIRST
FIRST=first
_assert_var_equals FIRST first
