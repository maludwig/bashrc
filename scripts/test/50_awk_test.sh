TEST_WORDS='one two three four five six'


_awkn_test () {
  STDOUT_OUTPUT=`echo "$TEST_WORDS" | awk1`
  _assert_var_equals STDOUT_OUTPUT "one"
  STDOUT_OUTPUT=`echo "$TEST_WORDS" | awk2`
  _assert_var_equals STDOUT_OUTPUT "two"
  STDOUT_OUTPUT=`echo "$TEST_WORDS" | awk3`
  _assert_var_equals STDOUT_OUTPUT "three"
  STDOUT_OUTPUT=`echo "$TEST_WORDS" | awk4`
  _assert_var_equals STDOUT_OUTPUT "four"
  STDOUT_OUTPUT=`echo "$TEST_WORDS" | awk5`
  _assert_var_equals STDOUT_OUTPUT "five"
}

TESTS=(_awkn_test)
