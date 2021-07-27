
# This common set of functions can be included in many scripts
# All of the functions below should work in zsh and bash

#30 = black
#31 = red
#32 = green
#33 = yellow
#34 = blue
#35 = pink
#36 = cyan
#37 = white

if [ -n "$BASH_VERSION" ]; then
  CBLACK="\033[0;30m"
  CRED="\033[0;31m"
  CGREEN="\033[0;32m"
  CYELLOW="\033[0;33m"
  CBLUE="\033[0;34m"
  CPINK="\033[0;35m"
  CCYAN="\033[0;36m"
  CWHITE="\033[0;37m"
  CDEFAULT="\033[0m"

  PBLACK="\001\033[0;30m\002"
  PRED="\001\033[0;31m\002"
  PGREEN="\001\033[0;32m\002"
  PYELLOW="\001\033[0;33m\002"
  PBLUE="\001\033[0;34m\002"
  PPINK="\001\033[0;35m\002"
  PCYAN="\001\033[0;36m\002"
  PWHITE="\001\033[0;37m\002"
  PDEFAULT="\001\033[0m\002"
elif [ -n "$ZSH_VERSION" ]; then
  autoload -U colors && colors
  CBLACK="$fg[black]"
  CRED="$fg[red]"
  CGREEN="$fg[green]"
  CYELLOW="$fg[yellow]"
  CBLUE="$fg[blue]"
  CPINK="$fg[magenta]"
  CCYAN="$fg[cyan]"
  CWHITE="$fg[white]"
  CDEFAULT="$reset_color"

  PBLACK="$CBLACK"
  PRED="$CRED"
  PGREEN="$CGREEN"
  PYELLOW="$CYELLOW"
  PBLUE="$CBLUE"
  PPINK="$CPINK"
  PCYAN="$CCYAN"
  PWHITE="$CWHITE"
  PDEFAULT="$CDEFAULT"
fi

if [[ "$USER" = "root" ]]; then
  CUSER="${CRED}"
else
  CUSER="${CGREEN}"
fi

if [ -n "$BASH_VERSION" ]; then
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
elif [ -n "$ZSH_VERSION" ]; then
  SCRIPT_DIR="${0:a:h}"
else
  echo "Unknown shell"
  exit 1
fi

function echo-err { echo "$@" 1>&2; }

function date-today { date -u +%F; }
function date-today-local { date +%F; }
function date-second { echo "$(date -u +%F_%H-%M-%S)Z"; }
function date-second-local { date +%F_%H-%M-%S; }
function date-8601 { date -u +%Y-%m-%dT%H:%M:%S%z; }
function date-8601-local { date +%Y-%m-%dT%H:%M:%S%z; }
function log-8601 { echo "[ $(date-8601) ] $@"; }
function log-8601-local { echo "[ $(date-8601-local) ] $@"; }
function log-err-8601 { echo-err "[ $(date-8601) ] $@"; }
function log-err-8601-local { echo-err "[ $(date-8601-local) ] $@"; }

function ask { echo -ne "${CYELLOW} $1: ${CDEFAULT}"; read ASK; export ASK; }
function ask-default { echo -ne "${CYELLOW} $1 [$2]: ${CDEFAULT}"; read ASK; export ASK=${ASK:-$2}; }
function ask-yes { echo -ne "${CYELLOW} $1 [Y/n]: ${CDEFAULT}"; read ASK; ASK="$(echo $ASK | tr '[:upper:]' '[:lower:]' | head -c 1)"; export ASK=${ASK:-y}; }
function ask-no { echo -ne "${CYELLOW} $1 [y/N]: ${CDEFAULT}"; read ASK; ASK="$(echo $ASK | tr '[:upper:]' '[:lower:]' | head -c 1)"; export ASK=${ASK:-n}; }
function ask-enter { echo -e "${CYELLOW} $1: [Press enter to continue]${CDEFAULT}" ; read; }
function ask-password { echo -ne "${CYELLOW} $1: ${CDEFAULT}" ; read -s ASK; echo; }

function msg-error { echo -e "${CRED}${@}${CDEFAULT}"; }
function msg-info { echo -e "${CCYAN}${@}${CDEFAULT}"; }
function msg-success { echo -e "${CGREEN}${@}${CDEFAULT}"; }
function msg-dry { echo -e "${CPINK}${@}${CDEFAULT}"; }

function each-line { for var in "$@"; do echo "$var"; done; }

function trim-leading { echo "$1" | sed -e 's/^[[:space:]]*//'; }
function trim-trailing { echo "$1" | sed -e 's/[[:space:]]*$//'; }
function trim { trim-leading `trim-trailing "$1"`; }

commands_exist () { 
  while [[ "$1" != "" ]]; do
    if ! command -v "$1" &> /dev/null; then
      return 1
    else
      shift
    fi
  done
}

get_os_type () {
    UNAME_S="$(uname -s)"
    case "${UNAME_S}" in
        Linux*)     echo Linux;;
        Darwin*)    echo Mac;;
        CYGWIN*)    echo Windows;;
        MINGW*)     echo Windows;;
        *)          echo "UNKNOWN:${unameOut}"
    esac
}

is_indexed_array () {
  VARIABLE_NAME="$1"
  if DECLARATION=`declare -p $VARIABLE_NAME 2>&1`; then
    echo "$DECLARATION" | cut -d= -f1 | grep -qE '^(declare|typeset).*( -a )'"$VARIABLE_NAME"
  else
    return 1
  fi  
}

is_associative_array () {
  VARIABLE_NAME="$1"
  if DECLARATION=`declare -p $VARIABLE_NAME 2>&1`; then
    echo "$DECLARATION" | cut -d= -f1 | grep -qE '^(declare|typeset).*( -A )'"$VARIABLE_NAME"
  else
    return 1
  fi  
}

is_array () {
  is_indexed_array "$1" || is_associative_array "$1"
}

each () {
  local HELP_MSG="
    Usage:
      each (KEY|VALUE|KEY,VALUE) in ASSOCIATIVE_ARRAY_NAME run FUNCTION_NAME
      each VALUE in INDEXED_ARRAY_NAME run FUNCTION_NAME
  "
  KEY_OR_VALUE="$1"
  ARRAY_NAME="$3"
  FUNCTION_NAME="$5"
  if [[ "$2" != 'in' ]] || [[ "$4" != 'run' ]]; then
    msg-error "$HELP_MSG"
    return 1
  elif [[ "$KEY_OR_VALUE" != "KEY" ]] && [[ "$KEY_OR_VALUE" != "VALUE" ]] && [[ "$KEY_OR_VALUE" != "KEY,VALUE" ]]; then
    msg-error "$HELP_MSG"
    return 1
  fi
  if is_indexed_array "$ARRAY_NAME"; then
    eval 'for VALUE in "${'"$ARRAY_NAME"'[@]}"; do '"$FUNCTION_NAME"' "$VALUE"; done'
  elif is_associative_array "$ARRAY_NAME"; then
    if [ -n "$BASH_VERSION" ]; then
      eval 'for KEY in "${!'$ARRAY_NAME'[@]}"; do VALUE="${'$ARRAY_NAME'[$KEY]}";'"$FUNCTION_NAME"' "$KEY" "$VALUE"; done'
    elif [ -n "$ZSH_VERSION" ]; then
      eval 'for KEY VALUE in "${(kv)'"$ARRAY_NAME"'[@]}"; do '"$FUNCTION_NAME"' "$KEY" "$VALUE"; done'
    fi
  else
    msg-error "$HELP_MSG"
    return 1
  fi
}

contains () {
  if [ "$2" != 'in' ]; then
    msg-error "
    Usage:
      contains {key} in {associative_array}
      contains {value} in {indexed_array}
    "
    return 1
  fi
  NEEDLE="$1"
  HAYSTACK="$3"
  if is_indexed_array "$HAYSTACK"; then
    eval 'for ITEM in "${'"$HAYSTACK"'[@]}"; do if [[ "$ITEM" == "'"$NEEDLE"'" ]]; then return 0; fi; done'
  elif is_associative_array "$HAYSTACK"; then
    if [ -n "$BASH_VERSION" ]; then
      eval 'for KEY in "${!'$HAYSTACK'[@]}"; do if [[ "$KEY" == "'"$NEEDLE"'" ]]; then return 0; fi; done'
    elif [ -n "$ZSH_VERSION" ]; then
      eval 'for KEY VALUE in "${(kv)'"$HAYSTACK"'[@]}"; do if [[ "$KEY" == "'"$NEEDLE"'" ]]; then return 0; fi; done'
    fi
  fi
  return 1
}
