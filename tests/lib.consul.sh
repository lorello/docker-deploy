#!/bin/bash

. /usr/local/lib/bash/lib.consul.sh

T_isUpOk() {
  return $(consul::isup)
}

T_isUpFail() {
  CONSUL_HTTP_ADDR=localhost:50000
  if $(consul::isup); then
    $T_fail "Consul isup should fail here"
    return
  fi
  CONSUL_HTTP_ADDR=
}


T_get(){
  if consul::get 'nonexistent/value'
    $T_fail "Found non existent value"
    return
  fi
  consul kv put tests/var 5
  value=$(consul::get 'tests/var')
  if [[ $value != 5 ]]; then
    $T_fail "Not found existent value 'tests/var', should be 5"
    return
  fi
}
