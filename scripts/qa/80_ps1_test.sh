
_ps1_test () {
  msg-info '
    Open a terminal, and check if the PS1 functions work.

    Type:

      ps1_add_fn "date -u" GREEN "=" "="
      ps1_add_fn "date" BLUE ":" ":"
      ps1_remove_fn "date -u"
      ps1_remove_fn "date"

    It should show the dates in the correct colors on your PS1 line

  '
  ask-yes "Did it work?" && [[ "$ASK" == "y" ]]
}

TESTS=(_ps1_test)
