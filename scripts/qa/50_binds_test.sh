
_binds_test () {
  msg-info '
    Open a terminal, and check if the history completion magic space works.

    Type:
      echo one two three
      !! four

    It should complete the line before you type "four"
  '
  ask-yes "Did it work?" && [[ "$ASK" == "y" ]]
}

TESTS=(_binds_test)
