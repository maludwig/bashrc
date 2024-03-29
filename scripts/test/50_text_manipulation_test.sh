
function _upper_test {
  ACTUAL=`echo $'Hello World\nSecond.Line!' | upper`
  if [[ "$ACTUAL" != $'HELLO WORLD\nSECOND.LINE!' ]]; then
    echo "Expected 'HELLO WORLD\nSECOND.LINE!', got '$ACTUAL'"
    return 1
  fi
}

function _lower_test {
  ACTUAL=`echo $'Hello World\nSecond.Line!' | lower`
  if [[ "$ACTUAL" != $'hello world\nsecond.line!' ]]; then
    echo "Expected 'HELLO WORLD\nSECOND.LINE!', got '$ACTUAL'"
    return 1
  fi
}

TESTS=(_upper_test _lower_test)
