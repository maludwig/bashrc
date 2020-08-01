_is_ip_address_test () {
  if is_ip_address "hello"; then
    return 1
  elif is_ip_address "1.2"; then
    return 2
  elif is_ip_address "1:2"; then
    return 3
  elif ! is_ip_address "192.168.0.1"; then
    return 5
  elif ! is_ip_address "10.0.0.1"; then
    return 6
  elif is_ip_address "z1234:5678:90ab:cdef:1234:5678:90ab:cdef"; then
    return 7
  elif ! is_ip_address "1234:5678:90ab:cdef:1234:5678:90ab:cdef"; then
    return 7
  else
    return 0
  fi
}

_is_ipv4_address_test () {
  if is_ipv4_address "hello"; then
    return 1
  elif is_ipv4_address "1.2"; then
    return 2
  elif is_ipv4_address "1:2"; then
    return 3
  elif ! is_ipv4_address "192.168.0.1"; then
    return 5
  elif ! is_ipv4_address "10.0.0.1"; then
    return 6
  elif is_ipv4_address "z1234:5678:90ab:cdef:1234:5678:90ab:cdef"; then
    return 7
  elif is_ipv4_address "1234:5678:90ab:cdef:1234:5678:90ab:cdef"; then
    return 7
  else
    return 0
  fi
}

_is_ipv6_address_test () {
  if is_ipv6_address "hello"; then
    return 1
  elif is_ipv6_address "1.2"; then
    return 2
  elif is_ipv6_address "1:2"; then
    return 3
  elif is_ipv6_address "192.168.0.1"; then
    return 5
  elif is_ipv6_address "10.0.0.1"; then
    return 6
  elif ! is_ipv6_address "::"; then
    return 7
  elif ! is_ipv6_address "::1"; then
    return 8
  elif is_ipv6_address "z1234:5678:90ab:cdef:1234:5678:90ab:cdef"; then
    return 9
  elif ! is_ipv6_address "1234:5678:90ab:cdef:1234:5678:90ab:cdef"; then
    return 10
  else
    return 0
  fi
}

_testport_ivp4_test () {
  testport github.com 443
}

_testport_ipv6_test () {
  testport google.com 443
}

_testport_fail_test () {
  ! testport goodskjmfdskjfnsdkjfsdnkfjsdnfkdsjngle.com 22
}

_list_open_ports_test () {
  for OPEN_PORT in `list_open_ports`; do
    if (( OPEN_PORT < 1000 )); then
      testport localhost "$OPEN_PORT"
      testport 127.0.0.1 "$OPEN_PORT"
      testport ::1 "$OPEN_PORT"
    fi
  done
}

TESTS=(_is_ip_address_test _is_ipv4_address_test _is_ipv6_address_test _testport_ivp4_test _testport_ipv6_test _testport_fail_test _list_open_ports_test)
