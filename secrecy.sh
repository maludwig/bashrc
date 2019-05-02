#!/bin/bash

HISTCONTROL=ignorespace:ignoredups

function unlock-secrets {
  if ! [[ -f $HOME/.secrets ]]; then
    msg-info "This is your first time setting up a secret hoard"
    PASS1=''
    while [[ -z $PASS1 ]]; do
      ask-password "What is a great secure password for encrypting your secrets?"
      PASS1="$ASK"
      ask-password "What was the password again?"
      PASS2="$ASK"
      if [[ "$PASS1" == "$PASS2" ]]; then
        msg-success "Passwords match, creating secret hoard"
        SECRET_PASSWORD="$PASS1"
      else
        msg-error "Passwords do not match"
        PASS1=''
      fi
    done
    echo '{}' | openssl enc -aes-256-cbc -k "$SECRET_PASSWORD" -out $HOME/.secrets
  fi
  while [[ "$SECRET_PASSWORD" == "" ]]; do
    ask-password "What is the secret password?"
    SECRET_PASSWORD="$ASK"
    if ALL_SECRETS=`openssl enc -d -aes-256-cbc -k "$SECRET_PASSWORD" -in $HOME/.secrets`; then
      msg-success "Secret hoard unlocked"
    else
      msg-error "Wrong password"
      SECRET_PASSWORD=''
    fi
  done
}

function dump-secrets {
  unlock-secrets
  if [ -f $HOME/.secrets ]; then
    ALL_SECRETS=`openssl enc -d -aes-256-cbc -k "$SECRET_PASSWORD" -in $HOME/.secrets 2>/dev/null`
    if [ "$?" == "0" ]; then
      echo "$ALL_SECRETS"
    else
      msg-error "Wrong password, try again" 1>&2
      SECRET_PASSWORD=''
      return 2
    fi
  else
    msg-error "No secrets found" 1>&2
    return 1
  fi
  ALL_SECRETS=""
}

PYTHON_PRINT_SECRET_CODE='
import json,sys
stdin_content=sys.stdin.read()
all_secrets=json.loads(stdin_content)
key=sys.argv[1]
print(all_secrets[key])
'

function print-secret {
  unlock-secrets
  if ALL_SECRETS=`dump-secrets`; then
    echo "$ALL_SECRETS" | python3 -c "$PYTHON_PRINT_SECRET_CODE" "$1" 2> /dev/null
    RETCODE="$?"
  else
    RETCODE=1
  fi
  ALL_SECRETS=""
  return $RETCODE
}

PYTHON_SET_SECRET_CODE='
import json,sys
stdin_content=sys.stdin.read()
all_secrets=json.loads(stdin_content)
key=sys.argv[1]
value=sys.argv[2]
all_secrets[key] = value
print(json.dumps(all_secrets))
'

function set-secret {
  unlock-secrets
  if ! [ -f $HOME/.secrets ]; then
    NEW_SECRETS="{ \"$1\": \"$2\" }" 
  else
    ALL_SECRETS=`openssl enc -d -aes-256-cbc -k "$SECRET_PASSWORD" -in $HOME/.secrets`
    NEW_SECRETS=`echo "$ALL_SECRETS" | python3 -c "$PYTHON_SET_SECRET_CODE" "$1" "$2"`
  fi
  echo "$NEW_SECRETS" | openssl enc -aes-256-cbc -k "$SECRET_PASSWORD" -out $HOME/.secrets
  ALL_SECRETS=""
}

function shell_quote {
    # run in a subshell to protect the caller's environment
    (
        sep=''
        for arg in "$@"; do
            sqesc=$(printf '%s\n' "${arg}" | sed -e "s/'/'\\\\''/g")
            printf '%s' "${sep}'${sqesc}'"
            sep=' '
        done
    )
}

function sudo-pass {
  local PASSWORD="$1"
  shift 1
  local PROGRAM=`shell_quote "$@"`
  local ASKPASS_SCRIPT=$'#!/bin/bash\necho '"'$PASSWORD'"
  local SCRIPT="
    echo \"$ASKPASS_SCRIPT\""' > $HOME/askpass.sh
    chmod 700 $HOME/askpass.sh
    SUDO_ASKPASS=$HOME/askpass.sh sudo -A '"$PROGRAM"'
    rm $HOME/askpass.sh
  '
  echo "$SCRIPT"
}

function ssh-password-sudo {
  REMOTE_PASSWORD="$1"
  REMOTE_HOST="$2"
  shift 2
  if [[ "$#" == "0" ]]; then
    REMOTE_PROGRAM='bash --rcfile $HOME/bashrc/main'
  else
    REMOTE_PROGRAM=`shell_quote "$@"`
  fi
  ASKPASS_SCRIPT=$'#!/bin/bash\necho '"'$REMOTE_PASSWORD'"

  X="
    echo \"$ASKPASS_SCRIPT\""' > $HOME/askpass.sh
    chmod 700 $HOME/askpass.sh
    SUDO_ASKPASS=$HOME/askpass.sh sudo -A '"$REMOTE_PROGRAM"'
    rm $HOME/askpass.sh
  '
  ssh -q -t "$REMOTE_HOST" -- "$X"
}

function op_login {
  if ! [ -x "$HOME/bin/op" ]; then
    msg-error "You must install the 1Password CLI to $HOME/bin/"
    msg-error "https://support.1password.com/command-line/"
    return 1
  else
    if [ -f "$HOME/.op/config" ]; then
      SHORTHAND=`cat "$HOME/.op/config" | jq '.accounts[0].shorthand' | tr -d '"'`
      eval $(op signin "$SHORTHAND")
    else
      ask-default "What is your 1Password login host?" "my.1password.com"
      OP_HOST="$ASK"
      ask "What is your email (ex. $USER@your-company.com) ?"
      OP_EMAIL="$ASK"
      ask-default "What is your 1Password account master key?" "AA-BBBBBB-CCCCCC-DDDDDD-EEEEEE-FFFFF-GGGG"
      OP_ACCOUNT_KEY="$ASK"
      eval $(op signin "$OP_HOST" "$OP_EMAIL" "$OP_ACCOUNT_KEY")
    fi
  fi
}

function op_ensure_login {
  if ! env | grep -q OP_SESSION; then
    op_login
  fi
}

function op_get_root_password {
  URL="$1"
  op_ensure_login
  SHORTNAME=`echo "$URL" | cut -d'.' -f1`
  ALL_ROOT_ITEMS=`op list items | jq '[.[] | select(.overview.ainfo == "root")]'`
  Q="[.[] | select(.overview.url == \"$URL\")]"
  URL_ITEM=`echo "$ALL_ROOT_ITEMS" | jq "$Q"`
  if [ "$URL_ITEM" == '[]' ]; then
    # msg-dry "Finding by title"
    Q="[.[] | select(.overview.title | contains(\"$SHORTNAME\"))]"
    # echo "$Q"
    URL_ITEM=`echo "$ALL_ROOT_ITEMS" | jq "$Q"`
  fi
  if [ "$URL_ITEM" == '[]' ]; then
    # msg-dry "Finding by URL"
    Q="[.[] | select(.overview.URLs) | select(.overview.URLs | contains([{"u":\"$URL\"}]))]"
    # echo "$Q"
    URL_ITEM=`echo "$ALL_ROOT_ITEMS" | jq "$Q"`
  fi
  if [ "$URL_ITEM" == '[]' ]; then
    # msg-dry "Finding by URL SHORTNAME"
    Q="[.[] | select(.overview.URLs) | select(.overview.URLs | contains([{"u":\"$SHORTNAME\"}]))]"
    # echo "$Q"
    URL_ITEM=`echo "$ALL_ROOT_ITEMS" | jq "$Q"`
  fi
  # msg-info "$URL_ITEM"
  ITEM_ID=`echo "$URL_ITEM" | jq '.[0].uuid' | tr -d '"'`
  # msg-info "$ITEM_ID"
  ITEM_DETAILS=`op get item "$ITEM_ID"`
  # msg-info "$ITEM_DETAILS"
  SUDO_PASS=`echo "$ITEM_DETAILS" | jq '.details.fields[] | select(.name == "password") | .value' | tr -d '"'`
  # Fail if the SUDO_PASS is empty
  [ "$SUDO_PASS" != "" ]
}

function get-sudo-secret {
  REMOTE_HOST="$1"
  unlock-secrets
  SUDO_PASS=`print-secret "sudo-${REMOTE_HOST}"`
  if [[ "$?" != "0" ]]; then
    SUDO_PASS=''
    echo-err "sudo-${REMOTE_HOST} secret not set"
    if [[ "$(type -t op_get_root_password)" == "function" ]]; then
      echo-err "Querying 1Password"
      op_get_root_password "${REMOTE_HOST}"
    fi
    if [[ "$?" != "0" ]] || [[ "$SUDO_PASS" == "" ]]; then
      ask-password "What is the password to become root?"
      SUDO_PASS="$ASK"
    fi
    set-secret "sudo-${REMOTE_HOST}" "$SUDO_PASS"
    ASK=""
  fi
}

function ssh-sudo {
  REMOTE_HOST="$1"
  shift
  get-sudo-secret "$REMOTE_HOST"
  ssh-password-sudo "$SUDO_PASS" "$REMOTE_HOST"  "$@"
}

alias rsync-sudo &>/dev/null && unalias rsync-sudo

function rsync-sudo {
  local REMOTE_HOST
  for ARG in "$@"; do
    if [[ "$ARG" =~ .*:.* ]]; then
      REMOTE_HOST=`echo "$ARG" | cut -d: -f1`
    fi
  done
  echo $REMOTE_HOST
  get-sudo-secret "$REMOTE_HOST"
  rsync --no-owner --no-group -e "$HOME/bin/ssh-password-sudo.sh '$SUDO_PASS'" --progress "$@"
}

if [[ "$shell" == "bash" ]]; then
  complete -F _ssh ssh-sudo
  complete -F _ssh ssh-password-sudo
  complete -F _ssh get-sudo-secret

  complete -F _ssh op_get_root_password
  complete -F _ssh get-sudo-secret
  complete -F _ssh get-sudo-secret
  complete -F _ssh get-sudo-secret
  
  complete -F _rsync rsync-sudo
fi
