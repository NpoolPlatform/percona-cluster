#!/bin/bash

my_hostname=`hostname`
my_ip=`hostname -i`
export CONSUL_HTTP_ADDR=${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT}

function register_service() {
  while true; do
    my_id=pmm.${ENV_CLUSTER_NAMESPACE}.svc.cluster.local
    my_name=pmm-npool-top
    consul services deregister -id=$my_id
    consul services register -address=$my_ip -port=443 -name=$my_name -id=$my_id
    if [ ! $? -eq 0 ]; then
      echo "Fail to register $my_name with address $my_hostname"
      sleep 2
      continue
    fi
    sleep 2
  done
}

register_service &
/opt/entrypoint-inner.sh $@
