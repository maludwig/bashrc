
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
  date-today | grep -qE '^20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]$'
}

_date-today-local_test () {
  date-today-local | grep -qE '^20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]$'
}

_date-second_test () {
  date-second | grep -qE '^20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]_[0-9][0-9]-[0-9][0-9]-[0-9][0-9]Z$'
}

_date-second-local_test () {
  date-second-local | grep -qE '^20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]_[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$'
}
         
_date-8601_test () {
  date-8601 | grep -qE '^20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9][-+]0000$'
}
         
_date-8601-local_test () {
  date-8601 | grep -qE '^20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9][-+][0-9][0-9][0-9][0-9]$'
}

_commands_exist_test () {
  if commands_exist echo; then
    if commands_exist rsync git; then
      if commands_exist msdjnksdjnf; then
        msg-error "commands_exist found a command that does not exist"
      else
        return 0
      fi
    else
      msg-error "commands_exist could not find multiple commands"
    fi
  else
    msg-error "commands_exist could not find echo"
  fi
  return 1
}

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

_each_test_output () {
  echo "${ARRAY_NAME}[${KEY}]=$VALUE"
}

_each_basic_test () {
  declare -A Y=()
  msg-info "BLANK"
  EACH_OUTPUT=`each KEY,VALUE in Y run _each_test_output`
  echo "$EACH_OUTPUT"
  [[ "$EACH_OUTPUT" == "" ]] || return 1
  msg-info "ONELEME"
  Y[a]=1
  EACH_OUTPUT=`each KEY,VALUE in Y run _each_test_output`
  echo "$EACH_OUTPUT"
  declare -p Y
  [[ "$EACH_OUTPUT" == 'Y[a]=1' ]] || return 2
  
  msg-info "MEZZ"
  K='a b c'
  Y[$K]="1 2 3"
  EACH_OUTPUT=`each KEY,VALUE in Y run _each_test_output | sort`
  echo "$EACH_OUTPUT"
  declare -p Y
  [[ "$EACH_OUTPUT" == $'Y[a b c]=1 2 3\nY[a]=1' ]] || return 3
  
  return 0
}

_contains_associative_test () {
  declare -A Y=()
  ! contains blah in Y
  Y[blah]=bleh
  contains blah in Y
  ! contains xx in Y
  K='a b c'
  ! contains "$K" in Y
  Y[$K]='1 2 3'
  declare -p Y
  contains "$K" in Y
}

_contains_indexed_test () {
  declare -a Y=()
  ! contains blah in Y
  Y+=(blah)
  contains blah in Y
  ! contains xx in Y
  K='a b c'
  ! contains "$K" in Y
  Y+=("$K")
  contains "$K" in Y
}

TESTS=(
  _SCRIPT_DIR_test _echo-err_test 
  _date-today_test _date-today-local_test _date-second_test _date-second-local_test _date-8601_test _date-8601-local_test
  _commands_exist_test _each_basic_test _contains_associative_test _contains_indexed_test
)

