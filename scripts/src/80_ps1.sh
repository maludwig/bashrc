# Requires substitute
#    CLEAN_SED_STRING="$(echo "$INNER_STRING" | sed 's:[]\[^$.*/]:\\&:g')"


if [ -n "$ZSH_VERSION" ]; then
  setopt PROMPT_SUBST
fi

function toggle_string_in_var {
  INNER_STRING="$1"
  VARIABLE_NAME="$2"
  VARIABLE_VALUE="$(eval /bin/echo '"${'"${VARIABLE_NAME}"'}"')"
  if ! /bin/echo "$VARIABLE_VALUE" | grep -q -F "$INNER_STRING"; then
    NEW_VALUE="${INNER_STRING}${VARIABLE_VALUE}"
  else
    NEW_VALUE="$(/bin/echo "$VARIABLE_VALUE" | substitute "$INNER_STRING" "")"
  fi
  eval "$VARIABLE_NAME='$NEW_VALUE'"
}

# NOTE: Do not put functions in here that produce output on stdout, use ps1_add_fn instead
#   You can put functions in here that cannot run in a subshell
function assert_in_prompt_command {
  if ! echo "$PROMPT_COMMAND" | grep -q -F "$1"; then
    PROMPT_COMMAND="$(echo "$PROMPT_COMMAND;$1" | substitute ";;" ";")"
  fi
}
function toggle_in_prompt_command {
  if ! echo "$PROMPT_COMMAND" | grep -q -F "$1"; then
    PROMPT_COMMAND="$PROMPT_COMMAND;$1"
  else
    PROMPT_COMMAND="$(echo "$PROMPT_COMMAND" | substitute ";$1" "" | substitute ";;" ";")"
  fi
}

# NOTE: Put functions in here that produce output on stdout, if they cannot run in a subshell
#   then you should use assert_in_prompt_command

declare -g -a PS1_COMMANDS
declare -g -A PS1_COLORS
declare -g -A PS1_PREFIXES
declare -g -A PS1_SUFFIXES
# declare -p PS1_COLORS PS1_PREFIXES PS1_SUFFIXES PS1_COMMANDS
function ps1_msg {
  local PS1_COMMAND
  local COLOR
  local PREFIX
  local SUFFIX
  local PS1_CONTENT=""
  for PS1_COMMAND in "${PS1_COMMANDS[@]}"; do
    COLOR="${PS1_COLORS[$PS1_COMMAND]}"
    PREFIX="${PS1_PREFIXES[$PS1_COMMAND]}"
    SUFFIX="${PS1_SUFFIXES[$PS1_COMMAND]}"
    PS1_CONTENT="${PS1_CONTENT}${COLOR}${PREFIX}$($PS1_COMMAND)${SUFFIX}"
  done
  echo -ne "${PS1_CONTENT}${PDEFAULT}"
}

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
  PS1_COMMANDS+=("$FN_NAME")
  COLOR_REF=P"$COLOR_NAME"
  PS1_COLORS["$FN_NAME"]="${!COLOR_REF}"
  PS1_PREFIXES["$FN_NAME"]="$PREFIX"
  PS1_SUFFIXES["$FN_NAME"]="$SUFFIX"
  if ! [[ "$PS1" == *'$(ps1_msg)'* ]]; then
    PS1='$(ps1_msg)$PS1'
  fi
}

function ps1_remove_fn {
  local FN_NAME="$1"
  for i in "${!PS1_COMMANDS[@]}"; do
    if [[ "${PS1_COMMANDS[i]}" == "$FN_NAME" ]]; then
      unset 'PS1_COMMANDS[i]'
    fi
  done
  unset PS1_COLORS["$FN_NAME"]
  unset PS1_PREFIXES["$FN_NAME"]
  unset PS1_SUFFIXES["$FN_NAME"]
}

zsh_ps1_fn () {
  local FN_NAME="$1"
  local COLOR_NAME="$2"
  local PREFIX="$3"
  local SUFFIX="$4"
}

function ps1_toggle_fn {
  local FN_NAME="$1"
  local COLOR_NAME="$2"
  local PREFIX="$3"
  local SUFFIX="$4"
  if contains "$FN_NAME" in PS1_COMMANDS; then
    ps1_remove_fn "$FN_NAME"
  else
    ps1_add_fn "$FN_NAME" "$COLOR_NAME" "$PREFIX" "$SUFFIX"
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
  if [[ "$PROMPT_COMMAND" == "_last_ret_code;"* ]]; then
    if [[ $LASTRETCODE == 0 ]]; then
      LASTRETCODEMSG="${PGREEN}[✔]${PDEFAULT} "
    else
      LASTRETCODEMSG="${PRED}[X]($LASTRETCODE)${PDEFAULT} "
    fi
  else
    PROMPT_COMMAND="_last_ret_code;$(echo "$PROMPT_COMMAND" | substitute "_last_ret_code;" "")"
  fi
}

function last_ret_code_msg {
  echo -ne "${LASTRETCODEMSG}"
}

function toggle_return_code_prompt {
  if ! echo "$PROMPT_COMMAND" | grep -q -F "_last_ret_code;"; then
    PROMPT_COMMAND="_last_ret_code;$PROMPT_COMMAND"
  else
    PROMPT_COMMAND="$(echo "$PROMPT_COMMAND" | substitute "_last_ret_code;" "")"
  fi
  PROMPT_COMMAND="$(echo "$PROMPT_COMMAND" | substitute ";;" ";")"
  ps1_toggle_fn last_ret_code_msg GREEN '' ''
}

# echo "Setting PS1:
# $PS1
# "
# PS1='$(ps1_msg)'"$PS1"
# echo "$PS1"
# echo "Done"

# declare -p PS1_COLORS PS1_PREFIXES PS1_SUFFIXES PS1_COMMANDS
