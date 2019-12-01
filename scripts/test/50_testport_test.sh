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

_testport_ivp4_test () {
  testport github.com 443
}

_testport_ipv6_test () {
  testport google.com 443
}

_testport_fail_test () {
  ! testport goodskjmfdskjfnsdkjfsdnkfjsdnfkdsjngle.com 22
}

TESTS=(_is_ip_address_test _testport_ivp4_test _testport_ipv6_test _testport_fail_test)
