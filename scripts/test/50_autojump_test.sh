_autojump_test () {
  if ! [[ -f "$AUTOJUMP_SH" ]]; then
    return 1
  fi
  if ! [[ `which autojump` == "$BASHRC_DIR/modules/autojump/bin/autojump" ]]; then
    msg-error "
      Autojump found here: '$(which autojump)'
      Expected: '$BASHRC_DIR/modules/autojump/bin/autojump'
    "
    return 2
  fi
  mkdir -p /tmp/autojump_test/asdf/fdsa/b/qqq
  cd /tmp/autojump_test/
  if commands_exist autojump_add_to_database; then
    if autojump_add_to_database; then
      sleep 0.5
    else
      msg-error "Failed to add path to autojump database"
      return 3
    fi
  elif commands_exist autojump_chpwd; then
    if autojump_chpwd; then
      sleep 0.5
    else
      msg-error "Failed to add path to autojump database"
      return 4
    fi
  fi
  AUTOJUMP_DB=`autojump -s | grep -E '^data:' | sed -E $'s/^data:[\t ]+//'`
  if ! (cat "$AUTOJUMP_DB" | grep -q /tmp/autojump_test); then
    msg-error "
      Could not find '/tmp/autojump_test' in '$AUTOJUMP_DB'
    "
    return 5
  fi
  autojump --add /tmp/autojump_test/asdf > /dev/null
  if ! (autojump --stat | grep -q /tmp/autojump_test/asdf); then
    return 6
  fi
}
TESTS=(_autojump_test)
