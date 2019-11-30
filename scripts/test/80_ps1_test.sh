

function _toggle_string_in_var_test {
  TESTVAR='asdf'
  toggle_string_in_var 'sd' TESTVAR
  if [[ "$TESTVAR" != "af" ]]; then
    return 1
  fi
  toggle_string_in_var 'sd' TESTVAR
  if [[ "$TESTVAR" != "sdaf" ]]; then
    return 2
  fi

  TESTVAR=$'asdf\nfdsa\nqwer'
  toggle_string_in_var 'sd' TESTVAR
  if [[ "$TESTVAR" != $'af\nfdsa\nqwer' ]]; then
    return 3
  fi

  TESTVAR='$(echo -ne "${LASTRETCODEMSG}")\033[0;32m\u@\033[0;35myyc-mludwig-lx:\033[0;32m\w\033[0m\n$'
  TOGGLESTR='$(echo -ne "${LASTRETCODEMSG}")\033[0;32m\u@\033[0;35myyc-mludwig-lx:'
  toggle_string_in_var "$TOGGLESTR" TESTVAR
  if [[ "$TESTVAR" != '\033[0;32m\w\033[0m\n$' ]]; then
    return 4
  fi
}

function _prompt_command_test {

  PROMPT_COMMAND=''
  assert_in_prompt_command 'echo hello $(date)'
  if [[ "$PROMPT_COMMAND" != ';echo hello $(date)' ]]; then
    return 1
  fi
  assert_in_prompt_command 'echo world $(date)'
  if [[ "$PROMPT_COMMAND" != ';echo hello $(date);echo world $(date)' ]]; then
    return 1
  fi
  assert_in_prompt_command 'echo hello $(date)'
  if [[ "$PROMPT_COMMAND" != ';echo hello $(date);echo world $(date)' ]]; then
    return 1
  fi

  toggle_in_prompt_command 'echo hello $(date)'
  if [[ "$PROMPT_COMMAND" != ';echo world $(date)' ]]; then
    return 1
  fi
  toggle_in_prompt_command 'echo hello $(date)'
  if [[ "$PROMPT_COMMAND" != ';echo world $(date);echo hello $(date)' ]]; then
    return 1
  fi
}

TESTS=(_toggle_string_in_var_test _prompt_command_test)
