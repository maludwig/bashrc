
is_ip_address () {
  echo "$1" | grep -qE '^([0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*|[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*)$'
}

list_local_ips () {
  ifconfig | grep 'inet ' | grep -v '127.0.0.1' | sed -E 's/^.*inet( | addr:)([0-9.]*) .*/\2/'
  ifconfig | grep 'inet6 ' | grep -o -E '[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*:[0-9a-f]*'
}

testport () {
  REMOTE_HOST="$1"
  REMOTE_PORT="$2"
  ALL_LOCAL_IPS=(`list_local_ips`)
  RETURN_VALUE=1
  for LOCAL_IP in "${ALL_LOCAL_IPS[@]}"; do
    if is_ip_address "$LOCAL_IP"; then
      if command -v telnet &> /dev/null; then
        # telnet has two versions with differention ways to specify a bind/source address
        if echo "" | timeout 2 telnet -b "$LOCAL_IP" "$REMOTE_HOST" "$REMOTE_PORT" 2>/dev/null | grep -q Connected; then
          msg-success "Connected to $REMOTE_HOST on port $REMOTE_PORT with $LOCAL_IP"
          RETURN_VALUE=0
        elif echo "" | timeout 2 telnet -s "$LOCAL_IP" "$REMOTE_HOST" "$REMOTE_PORT" 2>/dev/null | grep -q Connected; then
          msg-success "Connected to $REMOTE_HOST on port $REMOTE_PORT with $LOCAL_IP"
          RETURN_VALUE=0
        else
          msg-error "Could not connect to $REMOTE_HOST on port $REMOTE_PORT with $LOCAL_IP"
        fi
      elif command -v nc &> /dev/null; then
        echo nc -w 2 -s "$LOCAL_IP" -z "$REMOTE_HOST" "$REMOTE_PORT"
        CONNECTION_RESULT=`timeout 2 nc -w 2 -s "$LOCAL_IP" -z "$REMOTE_HOST" "$REMOTE_PORT" 2>&1`
        if echo "$CONNECTION_RESULT" | grep -q Connection; then
          msg-success "Connected to $REMOTE_HOST on port $REMOTE_PORT with $LOCAL_IP"
          RETURN_VALUE=0
        else
          msg-error "Could not connect to $REMOTE_HOST on port $REMOTE_PORT with $LOCAL_IP"
        fi
      fi
    else
      msg-error "
        $LOCAL_IP is not a valid IP address, this is a bug in the testport function
        You can use:
          declare -f testport
        to see the function definition.
      "
    fi
  done
  return $RETURN_VALUE
}
