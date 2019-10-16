# Requires substitute

function toggle_string_in_var {
  INNER_STRING="$1"
  VARIABLE_NAME="$2"
  if ! eval echo '"${'"${VARIABLE_NAME}"'}"' | grep -q -F "$INNER_STRING"; then
    eval "$VARIABLE_NAME="'"$INNER_STRING"$'"$VARIABLE_NAME"
  else
  
    CLEAN_SED_STRING="$(echo "$INNER_STRING" | sed 's:[]\[^$.*/]:\\&:g')"
    eval "$VARIABLE_NAME="'"$(echo "${'$VARIABLE_NAME'}" | substitute "$INNER_STRING" "")"'
  fi
}

# NOTE: Do not put functions in here that produce output on stdout, use ps1_add_fn instead
#   You can put functions in here that cannot run in a subshell
function assert_in_prompt_command {
  if ! echo "$PROMPT_COMMAND" | grep -q -F "$1"; then
    PROMPT_COMMAND="$1;$PROMPT_COMMAND"
  fi
}
function toggle_in_prompt_command {
  if ! echo "$PROMPT_COMMAND" | grep -q -F "$1"; then
    PROMPT_COMMAND="$1;$PROMPT_COMMAND"
  else
    PROMPT_COMMAND="$(echo "$PROMPT_COMMAND" | substitute "$1;" "")"
  fi
}

# NOTE: Put functions in here that produce output on stdout, if they cannot run in a subshell
#   then you should use assert_in_prompt_command
function ps1_add_fn {
    local FN_NAME="$1"
    local COLOR_NAME="${2:-DEFAULT}"
    local PREFIX='['
    local SUFFIX='] '
    if [[ $# > 2 ]]; then
        PREFIX="$3"
        if [[ $# > 3 ]]; then
            SUFFIX="$4"
        fi
    fi
    # echo "Adding $FN_NAME to PS1 with color: $COLOR_NAME"
    NEW_PROMPT='$(echo -ne "\001${C'"${COLOR_NAME}"'}\002'"${PREFIX}"'$('$FN_NAME')'"${SUFFIX}"'${PDEFAULT}")'
    PS1="$NEW_PROMPT""$PS1"
}

function ps1_toggle_fn {
    local FN_NAME="$1"
    local COLOR_NAME="${2:-DEFAULT}"
    local PREFIX='['
    local SUFFIX='] '
    if [[ $# > 2 ]]; then
        PREFIX="$3"
        if [[ $# > 3 ]]; then
            SUFFIX="$4"
        fi
    fi
    NEW_PROMPT='$(echo -ne "\001${C'"${COLOR_NAME}"'}\002'"${PREFIX}"'$('$FN_NAME')'"${SUFFIX}"'${PDEFAULT}")'
    if ! echo "$PS1" | grep -q -F "$NEW_PROMPT"; then
      PS1="$NEW_PROMPT""$PS1"
    else
      PS1="$(echo "$PS1" | substitute "$NEW_PROMPT;" "")"
      PS1="$(echo "$PS1" | sed -F "s/$NEW_PROMPT;//")"
    fi
}

function _record_command_start {
  # Only record the first one
  if [[ "${_START_SECONDS}" == "" ]]; then
    _START_SECONDS=`date +%s`
  fi
}
function show_command_runtime {
  if [[ "${_START_SECONDS}" != "" ]]; then
    _END_SECONDS=`date +%s`
    _TOTAL_SECONDS=$[_END_SECONDS - _START_SECONDS]
    echo "${_TOTAL_SECONDS}s"
    _END_SECONDS=''
    _TOTAL_SECONDS=''
    _START_SECONDS=''
  fi
}

function toggle_command_timing {
  echo
}

LASTRETCODEMSG=''
function _last_ret_code {
  LASTRETCODE=$?
  if [[ $LASTRETCODE == 0 ]]; then
    LASTRETCODEMSG="\001${CGREEN}\002[✔]\001${CDEFAULT}\002 "
  else
    LASTRETCODEMSG="\001${CRED}\002[X]($LASTRETCODE)\001${CDEFAULT}\002 "
  fi
}

function toggle_return_code_prompt {
  toggle_in_prompt_command '_last_ret_code'
  ps1_toggle_fn 'echo -ne "${LASTRETCODEMSG}"' GREEN '' ''
}