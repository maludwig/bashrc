
function _substitute_test {

  ACTUAL=`echo "$PRINTING_ASCII" | substitute "$NUMERIC_ASCII" "" | substitute "$LOWER_ASCII" "" | substitute "$UPPER_ASCII" ""`
  if [[ "$ACTUAL" != "$SYMBOL_ASCII" ]]; then
    return 1
  fi
  ACTUAL=`echo "$SYMBOL_ASCII" | substitute "$SYMBOL_ASCII" "$LOWER_ASCII" | substitute "$LOWER_ASCII" "$NUMERIC_ASCII" | substitute "$NUMERIC_ASCII" "$UPPER_ASCII"`
  if [[ "$ACTUAL" != "$UPPER_ASCII" ]]; then
    return 1
  fi

  EXPECTED='xxx'
  ACTUAL=`echo "$PRINTING_ASCII" | substitute "$PRINTING_ASCII" "xxx"`
  if [[ "$ACTUAL" != "$EXPECTED" ]]; then
    return 1
  fi

  EXPECTED="$PRINTING_ASCII"
  ACTUAL=`echo "xxx" | substitute "xxx" "$PRINTING_ASCII"`
  if [[ "$ACTUAL" != "$EXPECTED" ]]; then
    return 1
  fi
}

TESTS=(_substitute_test)

