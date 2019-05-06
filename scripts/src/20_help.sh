
# function gen_help {
#   if [ -n "$ZSH_VERSION" ]; then emulate sh; fi
#   declare -A POSITIONAL_USAGES=()
#   declare -A NAMED_OPTIONAL_USAGES=()
#   for ARG_USAGE in "${USAGE[@]}"; do
#     FIRST_CHAR="$( echo "$ARG_USAGE" | head -c 1)"
#     case "$FIRST_CHAR" in
#     '<')
#       POSITIONAL_USAGES+=("$ARG_USAGE")
#     ;;
#     '[')
#       POSITIONAL_USAGES+=("$ARG_USAGE")
#     ;;
#     '-')
#       NAMED_OPTIONAL_USAGES+=("$ARG_USAGE")
#     ;;
#     esac
#   done
#   for ONE_ARG in "$@"; do
#     FIRST_CHAR="$( echo "$ONE_ARG" | head -c 1)"
#     if [[ "$FIRST_CHAR" == "-" ]]; then
#       # Named optional
#     else
#       # Positional
#       if [[ "${#POSITIONAL_USAGES[@]}" < 1 ]]; then
#         msg-error "Too many arguments at: $ONE_ARG"
#       fi
#       ARG_USAGE="${POSITIONAL_USAGES[0]}"
#       POSITIONAL_USAGES="${POSITIONAL_USAGES[@]:1}"
#       ARG_NAME="$( echo $ARG_USAGE | sed -E 's/^(<|[-]+|\[)([a-z-]+)[^:]*: ?(.*)/\2/' | tr '-' '_' | tr '[[:lower:]]' '[[:upper:]]')"
#       ARG_HELP="$( echo $ARG_USAGE | sed -E 's/^(<|[-]+|\[)([a-z-]+)[^:]*: ?(.*)/\3/')"
#     fi
#   done
#   for ARG_USAGE in "${USAGE[@]}"; do
#     ARG_NAME="$( echo $ARG_USAGE | sed -E 's/^(<|[-]+|\[)([a-z-]+)[^:]*: ?(.*)/\2/' | tr '-' '_' | tr '[[:lower:]]' '[[:upper:]]')"
#     ARG_HELP="$( echo $ARG_USAGE | sed -E 's/^(<|[-]+|\[)([a-z-]+)[^:]*: ?(.*)/\3/')"
#     FIRST_CHAR="$( echo "$ARG_USAGE" | head -c 1)"
#     echo "
#       ARG_USAGE=$ARG_USAGE
#       ARG_NAME=$ARG_NAME
#       ARG_HELP=$ARG_HELP
#       FIRST_CHAR=$FIRST_CHAR
#     "
#     case "$FIRST_CHAR" in
#     '<')
#       echo "Positional arg: $ARG_NAME - $ARG_HELP"
#       eval "$ARG_NAME='$1'"
#     ;;
#     '[')
#       echo "Optional positional arg: $ARG_NAME - $ARG_HELP"
#       eval "$ARG_NAME='$1'"
#     ;;
#     '-')
#       echo "Optional named arg: $ARG_NAME - $ARG_HELP"
#       shift
#       eval "$ARG_NAME='$1'"
#     ;;
#     esac
#     shift
#   done
#   if [ -n "$ZSH_VERSION" ]; then emulate zsh; fi
# }
# gen_help thething 'the ghost' --host yyc-prod-pentaho01.solium.com zfile.txt

# function trything {
#   if [ -n "$ZSH_VERSION" ]; then emulate sh; fi
#   USAGE_COPY=(
#     '<thing>: The thing'
#     '<ghost>: The Kapser'
#     '--host: Override host'
#     '[file]: Another file'
#   )
#   gen_help
#   echo "$ZSH_VERSION"
#   if [ -n "$ZSH_VERSION" ]; then emulate zsh; fi
# }

