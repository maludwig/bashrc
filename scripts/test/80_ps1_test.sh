

function _toggle_string_in_var_test {
TESTVAR='asdf'
toggle_string_in_var 'sd' TESTVAR
if [[ "$TESTVAR" != "af" ]]; then
  return 1
fi
toggle_string_in_var 'sd' TESTVAR
if [[ "$TESTVAR" != "sdaf" ]]; then
  return 1
fi

TESTVAR=$'asdf\nfdsa\nqwer'
toggle_string_in_var 'sd' TESTVAR
if [[ "$TESTVAR" != $'af\nfdsa\nqwer' ]]; then
  return 1
fi

TESTVAR='$(echo -ne "${LASTRETCODEMSG}")\033[0;32m\u@\033[0;35myyc-mludwig-lx:\033[0;32m\w\033[0m\n$'
TOGGLESTR='$(echo -ne "${LASTRETCODEMSG}")\033[0;32m\u@\033[0;35myyc-mludwig-lx:'
toggle_string_in_var "$TOGGLESTR" TESTVAR
echo ":$TESTVAR:"
if [[ "$TESTVAR" != '\033[0;32m\w\033[0m\n$' ]]; then
  return 1
fi

# toggle_string_in_var "$TOGGLESTR" TESTVAR
# if [[ "$TESTVAR" != '$(echo -ne "${LASTRETCODEMSG}")\033[0;32m\u@\033[0;35myyc-mludwig-lx:\033[0;32m\w\033[0m\n$' ]]; then
#   return 1
# fi
}
TESTS=(_toggle_string_in_var_test)

PROMPT_COMMAND=''
assert_in_prompt_command 'echo hello $(date)'
msg-info "$PROMPT_COMMAND"
if [[ "$PROMPT_COMMAND" != 'echo hello $(date);' ]]; then
  return 1
fi
assert_in_prompt_command 'echo world $(date)'
msg-info "$PROMPT_COMMAND"
if [[ "$PROMPT_COMMAND" != 'echo world $(date);echo hello $(date);' ]]; then
  return 1
fi
assert_in_prompt_command 'echo hello $(date)'
msg-info "$PROMPT_COMMAND"
if [[ "$PROMPT_COMMAND" != 'echo world $(date);echo hello $(date);' ]]; then
  return 1
fi

toggle_in_prompt_command 'echo hello $(date)'
msg-info "$PROMPT_COMMAND"
if [[ "$PROMPT_COMMAND" != 'echo world $(date);' ]]; then
  return 1
fi
toggle_in_prompt_command 'echo hello $(date)'
msg-info "$PROMPT_COMMAND"
if [[ "$PROMPT_COMMAND" != 'echo hello $(date);echo world $(date);' ]]; then
  return 1
fi

# # NOTE: Do not put functions in here that produce output on stdout, use ps1_add_fn instead
# #   You can put functions in here that cannot run in a subshell
# function assert_in_prompt_command {
#   if ! echo "$PROMPT_COMMAND" | grep -q -F "$1"; then
#     PROMPT_COMMAND="$1;$PROMPT_COMMAND"
#   fi
# }
# function toggle_in_prompt_command {
#   if ! echo "$PROMPT_COMMAND" | grep -q -F "$1"; then
#     PROMPT_COMMAND="$1;$PROMPT_COMMAND"
#   else
#     PROMPT_COMMAND="$(echo "$PROMPT_COMMAND" | sed -F "s/$1;//")"
#   fi
# }

# # NOTE: Put functions in here that produce output on stdout, use ps1_add_fn instead
# function ps1_add_fn {
#     FN_NAME="$1"
#     COLOR_NAME="${2:-DEFAULT}"
#     PREFIX='['
#     SUFFIX='] '
#     if [[ $# > 2 ]]; then
#         PREFIX="$3"
#         if [[ $# > 3 ]]; then
#             SUFFIX="$4"
#         fi
#     fi
#     echo "Adding $FN_NAME to PS1 with color: $COLOR_NAME"
#     NEW_PROMPT='$(echo -ne "\001${C'"${COLOR_NAME}"'}\002'"${PREFIX}"'$('$FN_NAME')'"${SUFFIX}"'${PDEFAULT}")'
#     PS1="$NEW_PROMPT""$PS1"
# }

# function ps1_toggle_fn {
#     FN_NAME="$1"
#     COLOR_NAME="${2:-DEFAULT}"
#     PREFIX='['
#     SUFFIX='] '
#     if [[ $# > 2 ]]; then
#         PREFIX="$3"
#         if [[ $# > 3 ]]; then
#             SUFFIX="$4"
#         fi
#     fi
#     NEW_PROMPT='$(echo -ne "\001${C'"${COLOR_NAME}"'}\002'"${PREFIX}"'$('$FN_NAME')'"${SUFFIX}"'${PDEFAULT}")'
#     if ! echo "$PS1" | grep -q -F "$NEW_PROMPT"; then
#       PS1="$NEW_PROMPT;$PS1"
#     else
#       PS1="$(echo "$PS1" | sed -F "s/$NEW_PROMPT;//")"
#     fi
# }

# function _record_command_start {
#   # Only record the first one
#   if [[ "${_START_SECONDS}" == "" ]]; then
#     _START_SECONDS=`date +%s`
#   fi
# }
# function show_command_runtime {
#   if [[ "${_START_SECONDS}" != "" ]]; then
#     _END_SECONDS=`date +%s`
#     _TOTAL_SECONDS=$[_END_SECONDS - _START_SECONDS]
#     echo "${_TOTAL_SECONDS}s"
#     _END_SECONDS=''
#     _TOTAL_SECONDS=''
#     _START_SECONDS=''
#   fi
# }

# function toggle_command_timing {
#   echo
# }

# LASTRETCODEMSG=''
# function _last_ret_code {
#   LASTRETCODE=$?
#   if [[ $LASTRETCODE == 0 ]]; then
#     LASTRETCODEMSG="\001${CGREEN}\002[✔]\001${CDEFAULT}\002 "
#   else
#     LASTRETCODEMSG="\001${CRED}\002[X]($LASTRETCODE)\001${CDEFAULT}\002 "
#   fi
# }

# function toggle_return_code_prompt {
#   if [[ "$RETCODEPROMPT" == "" ]]; then
#     RETCODEPROMPT=1
#     OLD_PROMPT_COMMAND="$PROMPT_COMMAND"
#     OLD_PS1="$PS1"
#     PS1='$(echo -ne "${LASTRETCODEMSG}")'"$PS1"
#     PROMPT_COMMAND='_last_ret_code;'"$PROMPT_COMMAND"
#   else
#     RETCODEPROMPT=
#     LASTRETCODEMSG=''
#     PS1="$OLD_PS1"
#     PROMPT_COMMAND="$OLD_PROMPT_COMMAND"
#   fi
# }
