
NON_PRINTING_ASCII=$'\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\x20'
NUMERIC_ASCII="0123456789"
LOWER_ASCII="abcdefghijklmnopqrstuvwxyz"
UPPER_ASCII="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
SYMBOL_ASCII=' !"#$%&'"'"'()*+,-./:;<=>?@[\]^_`{|}~'
PRINTING_ASCII=' !"#$%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'
ALL_ASCII="$NON_PRINTING_ASCII""$PRINTING_ASCII"

function substitute {
  if [[ "$#" == "2" ]] || [[ "$#" == "3" ]]; then
    HAYSTACK="$(/bin/cat -)"
    NEEDLE="$1"
    NEEDLESUB="$2"
    REGEX_FLAGS="$3"
  else
    echo "Usage:   echo <HAYSTACK> | substitute <NEEDLE> <NEEDLESUB> [FLAGS]"
    echo "Example:   echo 'hello w' | substitute 'w' 'world'"
    echo "Example:   echo 'hello w' | substitute 'O' 'xxxxx' 'g'"
  fi
  CLEAN_SED_STRING="$(/bin/echo "$NEEDLE" | sed 's:[]\[^$.*/&]:\\&:g')"
  CLEAN_SED_SUBSTRING="$(/bin/echo "$NEEDLESUB" | sed 's:[]\[^$.*/&]:\\&:g')"
  /bin/echo "$HAYSTACK" | sed "s/$CLEAN_SED_STRING/$CLEAN_SED_SUBSTRING/$REGEX_FLAGS"
}
