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
  OS_TYPE=`get_os_type`
  if [[ "$OS_TYPE" == "Windows" ]]; then
    TEMP_DIR_ROOT="$HOME/AppData/Local/Temp"
  else
    TEMP_DIR_ROOT="/tmp"
  fi

  TEST_TEMP_DIR="$TEMP_DIR_ROOT/autojump_test_$(date +%s)/asdf/fdsa/b/qqq"
  mkdir -p "$TEST_TEMP_DIR"
  cd "$TEST_TEMP_DIR"
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
  if ! (autojump --stat | grep -q "$TEST_TEMP_DIR"); then
    autojump --stat
    msg-error "
      Could not find '$TEST_TEMP_DIR' in 'autojump --stat' output
    "
    return 5
  fi
  autojump --add /tmp/autojump_test/asdf > /dev/null
  if ! (autojump --stat | grep -q /tmp/autojump_test/asdf); then
    return 6
  fi
}
TESTS=(_autojump_test)
