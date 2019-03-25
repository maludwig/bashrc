
_SCRIPT_DIR_test () {
  if ! [[ -d "$SCRIPT_DIR" ]]; then
    msg-error "SCRIPT_DIR: $SCRIPT_DIR is not a directory"
  fi
}

_echo-err_test () {
  STDOUT_OUTPUT=`echo-err hello`
  STDERR_OUTPUT=`echo-err hello 2>&1`
  _assert_var_equals STDOUT_OUTPUT ""
  _assert_var_equals STDERR_OUTPUT "hello"
}

_date-today_test () {
  STDOUT_OUTPUT=`date-today`
  date-today | grep -qE '^20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]$'
}

# function date-today { echo $(date +%F); }
# function date-second { echo $(date +%F_%H-%M-%S); }
# function date-8601 { date -u +%Y-%m-%dT%H:%M:%S%z; }
# function date-8601-local { date +%Y-%m-%dT%H:%M:%S%z; }
# function log-8601 { echo "[ $(date-8601) ] $@"; }
# function log-8601-local { echo "[ $(date-8601-local) ] $@"; }
# function log-err-8601 { echo-err "[ $(date-8601) ] $@"; }
# function log-err-8601-local { echo-err "[ $(date-8601-local) ] $@"; }

# function ask { echo -ne "${CYELLOW} $1: ${CDEFAULT}"; read ASK; export ASK; }
# function ask-default { echo -ne "${CYELLOW} $1 [$2]: ${CDEFAULT}"; read ASK; export ASK=${ASK:-$2}; }
# function ask-yes { echo -ne "${CYELLOW} $1 [Y/n]: ${CDEFAULT}"; read ASK; ASK="$(echo $ASK | tr '[:upper:]' '[:lower:]' | head -c 1)"; export ASK=${ASK:-y}; }
# function ask-no { echo -ne "${CYELLOW} $1 [y/N]: ${CDEFAULT}"; read ASK; ASK="$(echo $ASK | tr '[:upper:]' '[:lower:]' | head -c 1)"; export ASK=${ASK:-n}; }
# function ask-enter { echo -e "${CYELLOW} $1: [Press enter to continue]${CDEFAULT}" ; read; }
# function ask-password { echo -ne "${CYELLOW} $1: ${CDEFAULT}" ; read -s ASK; echo; }

# function msg-error { echo -e "${CRED}${@}${CDEFAULT}"; }
# function msg-info { echo -e "${CCYAN}${@}${CDEFAULT}"; }
# function msg-success { echo -e "${CGREEN}${@}${CDEFAULT}"; }
# function msg-dry { echo -e "${CPINK}${@}${CDEFAULT}"; }

# function each-line { for var in "$@"; do echo "$var"; done; }

# function trim-leading { echo "$1" | sed -e 's/^[[:space:]]*//'; }
# function trim-trailing { echo "$1" | sed -e 's/[[:space:]]*$//'; }
# function trim { trim-leading `trim-trailing "$1"`; }

TESTS=(_SCRIPT_DIR_test _echo-err_test _date-today_test)

