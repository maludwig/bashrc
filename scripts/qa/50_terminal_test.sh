
_terminal_test () {
  msg-info '
    Terminal tests
  '
  set_terminal_title 'Hello World'
  ask-yes "Does the terminal window title currently say 'Hello World'?" && [[ "$ASK" == "y" ]]
}

TESTS=(_terminal_test)
