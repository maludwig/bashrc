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
	if [ "$SECRET_PASSWORD" == "" ]; then
		ask "What is the secret password?"
		SECRET_PASSWORD="$ASK"
	fi
	if [ -f $HOME/.secrets ]; then
		ALL_SECRETS=`openssl enc -d -aes-256-cbc -k "$SECRET_PASSWORD" -in $HOME/.secrets`
		echo "$ALL_SECRETS" | python3 -c "$PYTHON_PRINT_SECRET_CODE" "$1" 2> /dev/null
		RETCODE="$?"
	else
		echo-err "No secrets found"
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

function ssh-sudo {
	REMOTE_HOST="$1"
	shift
	SUDO_PASS=`print-secret "sudo-${REMOTE_HOST}"`
	if [ "$?" == "0" ]; then
		cat <<- EOF
		ssh -tt "$REMOTE_HOST" -- "echo '${SUDO_PASS}' | sudo -S $@"
		EOF
		ssh -tt "$REMOTE_HOST" -- "echo '${SUDO_PASS}' | sudo -S $@"
	else
		echo-err "sudo-${REMOTE_HOST} secret not set"
		ask-password "What is the password to become root?"
		set-secret "sudo-${REMOTE_HOST}" "$ASK"
		ASK=""
		echo-err "Ok, try again"
	fi
}
