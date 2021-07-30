list_open_ports () {
  sudo lsof -i tcp -sTCP:LISTEN -nP | grep -Eo 'TCP \*:[0-9]*' | cut -d: -f2 | sort -un
}

is_ipv4_address () {
  echo "$1" | grep -qE '^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$'
}

is_ipv6_address () {
  echo "$1" | grep -qE '^[0-9a-f]*:[0-9a-f]*:?[0-9a-f]*:?[0-9a-f]*:?[0-9a-f]*:?[0-9a-f]*:?[0-9a-f]*:[0-9a-f]*$'
}

is_ip_address () {
  is_ipv4_address "$1" || is_ipv6_address "$1"
}

list_local_ips ()
{
  if commands_exist ip; then
    IFCFG_LINES=`ip a | grep 'inet'`
  elif commands_exist ifconfig; then
    IFCFG_LINES=""
    for IFACE in $(ifconfig -lu); do
      IFACE_CONFIG="$(ifconfig $IFACE)"
      if echo "$IFACE_CONFIG" | grep -q "status: active" || echo "$IFACE_CONFIG" | grep -q "LOOPBACK"; then
        if echo "$IFACE_CONFIG" | grep -q 'inet '; then
          IFCFG_LINES="${IFCFG_LINES}"$'\n'"$(echo "$IFACE_CONFIG" | grep 'inet')"
        fi
      fi
    done
  else
    echo-err "Could not find 'ifconfig' or 'ip'"
    return 1
  fi
  echo "$IFCFG_LINES" | grep 'inet ' | sed -E 's/^.*inet( | addr:)([0-9.]*)([/][0-9][0-9]* | ).*/\2/' | grep -v '127.0.0.1'
  echo "$IFCFG_LINES" | grep 'inet6 ' | grep -o -E '[0-9a-f]*:[0-9a-f]*:?[0-9a-f]*:?[0-9a-f]*:?[0-9a-f]*:?[0-9a-f]*:?[0-9a-f]*:[0-9a-f]*'
}

testport () {
  REMOTE_HOST="$1"
  REMOTE_PORT="$2"
  ALL_LOCAL_IPS=(`list_local_ips`)
  RETURN_VALUE=1
  HOST_FORMAT="hostname"
  if is_ipv4_address "$REMOTE_HOST"; then
    HOST_FORMAT="ipv4"
  elif is_ipv6_address "$REMOTE_HOST"; then
    HOST_FORMAT="ipv6"
  fi
  for LOCAL_IP in "${ALL_LOCAL_IPS[@]}"; do
    if is_ip_address "$LOCAL_IP"; then
      if [[ "$HOST_FORMAT" == "hostname" ]]; then
        GOOD_LOCAL_IP='y'
      elif [[ "$HOST_FORMAT" == "ipv4" ]] && is_ipv4_address "$LOCAL_IP"; then
        GOOD_LOCAL_IP='y'
      elif [[ "$HOST_FORMAT" == "ipv6" ]] && is_ipv6_address "$LOCAL_IP"; then
        GOOD_LOCAL_IP='y'
      else
        GOOD_LOCAL_IP='n'
      fi
      if [[ "$GOOD_LOCAL_IP" == "y" ]]; then
        if commands_exist telnet &> /dev/null; then
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
        elif commands_exist nc &> /dev/null; then
          if is_ipv4_address "$LOCAL_IP"; then
            IP_VER_FLAG="-4"
          else
            IP_VER_FLAG="-6"
          fi
          echo nc "$IP_VER_FLAG" -w 2 -s "$LOCAL_IP" -z "$REMOTE_HOST" "$REMOTE_PORT"
          if CONNECTION_RESULT=`timeout 2 nc "$IP_VER_FLAG" -w 2 -s "$LOCAL_IP" -z "$REMOTE_HOST" "$REMOTE_PORT" 2>&1`; then
            msg-success "Connected to $REMOTE_HOST on port $REMOTE_PORT with $LOCAL_IP"
            RETURN_VALUE=0
          else
            msg-error "Could not connect to $REMOTE_HOST on port $REMOTE_PORT with $LOCAL_IP"
            msg-error "$CONNECTION_RESULT"
          fi
        else
          msg-error "No commands found to test ports, install 'telnet' or 'nc'"
          return 2
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
