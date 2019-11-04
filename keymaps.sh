#!/bin/bash

# Reference: http://www.gnu.org/software/bash/manual/html_node/Function-Index.html#Function-Index

declare -A BINDS=()
function getbinding { 
  if [[ -z "${BINDS[$1]}" ]]; then
    BINDS[$1]=`bind -p | grep -E '^".*": '$1'$' | head -n 1 | sed -E 's/^"(.*)": '$1'$/\1/'`
  fi
  echo "${BINDS[$1]}"
}

shopt -s autocd

# Do not use this. It turns out there is a readline builtin 'history-search-backward'
function get_commands_starting_with {
  MATCHCMD=
  MATCHINGCMDS="$(fc -l 1 | grep -F "$1")"
  OLDIFS="$IFS"

  STARTMATCHES=()
  IFS=$'\n'
  for ONE in $MATCHINGCMDS; do
    if echo "$ONE" | cut -d' ' -f 2- | cut -c 1-"${#1}" | grep -q -F "$1"; then
      STARTMATCHES=("${STARTMATCHES[@]}" "$ONE")
    fi
  done
  IFS="$OLDIFS"
  MATCHCOUNT="${#STARTMATCHES[@]}"
  if [[ $MATCHCOUNT == 0 ]]; then
    msg-error "No matches for '$1'"
    exit 10
  elif [[ $MATCHCOUNT == 1 ]]; then
    MATCHNUM="$(echo "${STARTMATCHES[0]}" | cut -f 1)"
  else
    for MATCH in "${STARTMATCHES[@]}"; do
      msg-info "- $MATCH"
      MATCHNUM="$(echo "$MATCH"|cut -f 1)"
    done
    ask-default "Which to run?" "$MATCHNUM"
    MATCHNUM="$ASK"
  fi
}
# get_commands_starting_with 'echo uno'

