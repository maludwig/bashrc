#!/bin/bash

function dump-secrets {
  if [ "$SECRET_PASSWORD" == "" ]; then
    ask "What is the secret password?"
    SECRET_PASSWORD="$ASK"
  fi
  if [ -f $HOME/.secrets ]; then
    ALL_SECRETS=`openssl enc -d -aes-256-cbc -k "$SECRET_PASSWORD" -in $HOME/.secrets`
    echo "$ALL_SECRETS"
  else
    echo-err "No secrets found"
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
  if [ "$SECRET_PASSWORD" == "" ]; then
    ask "What is the secret password?"
    SECRET_PASSWORD="$ASK"
  fi
  if [ -f $HOME/.secrets ]; then
    ALL_SECRETS=`openssl enc -d -aes-256-cbc -k "$SECRET_PASSWORD" -in $HOME/.secrets`
    echo "$ALL_SECRETS" | python3 -c "$PYTHON_PRINT_SECRET_CODE" "$1"
  else
    echo-err "No secrets found"
  fi
  ALL_SECRETS=""
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
  if [ "$SECRET_PASSWORD" == "" ]; then
    ask "What is the secret password?"
    SECRET_PASSWORD="$ASK"
  fi
  if ! [ -f $HOME/.secrets ]; then
    NEW_SECRETS="{ \"$1\": \"$2\" }" 
  else
    ALL_SECRETS=`openssl enc -d -aes-256-cbc -k "$SECRET_PASSWORD" -in $HOME/.secrets`
    NEW_SECRETS=`echo "$ALL_SECRETS" | python3 -c "$PYTHON_SET_SECRET_CODE" "$1" "$2"`
  fi
  echo "$NEW_SECRETS" | openssl enc -aes-256-cbc -k "$SECRET_PASSWORD" -out $HOME/.secrets
  ALL_SECRETS=""
}
