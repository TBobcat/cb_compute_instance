#!/bin/bash
set -e

# print commands executed for debugging
#set -x

echo "INITIALIZING couchbase cluster"

# do a 2 min. check to wait for couchbase to be fully up
function check_couchbase {
  local x=0
  while [ $x -lt 8 ]
  do
    local status=$(systemctl show -p ActiveState couchbase-server.service --value)
    if [ $status != "active" ]
    then
      echo "sleeping 15 sec. to wait for couchbase to become ready..."
      sleep 15s
      x=$(( $x + 1 ))
    else
      break
    fi
  done
  if [ $x -ge 8 ]
  then
    echo "Waiting for couchbase to be ready timed out"
    exit 1
  fi
}
# run check function, if passed proceed
check_couchbase

# export couchbase binaries to use cli tools
echo "couchbase server is ready, proceeding..."
export PATH=/opt/couchbase/bin:$PATH

# get host ip and remove trailing space
readonly host_ip="$(hostname -I | awk '{$1=$1};1' )"
readonly full_hostname="$(hostname -f)"
readonly api_port=":8091"

# sleep 10s to make sure the api server is up
sleep 10s

couchbase-cli node-init -c $host_ip \
-u Administrator -p password \
--node-init-data-path /opt/couchbase/var/lib/couchbase/data \
--node-init-index-path /opt/couchbase/var/lib/couchbase/data \
--node-init-eventing-path /opt/couchbase/var/lib/couchbase/data \
--node-init-analytics-path /opt/couchbase/var/lib/couchbase/data \
--node-init-hostname $full_hostname \
--ipv4

# init node with data and query services
couchbase-cli cluster-init -c $host_ip \
--cluster-username Administrator \
--cluster-password password \
--services data,query \
--cluster-ramsize 2046 \
--cluster-index-ramsize 256


# create an empty bucket
# persist on shard hosting node and have replicas on majority of data nodes
# couchbase-cli bucket-create \
# --cluster "$host_ip$api_port" \
# --username Administrator \
# --password password \
# --bucket initialBucket \
# --bucket-type couchbase \
# --bucket-ramsize 512 \
# --max-ttl 500000000 \
# --durability-min-level persistToMajority \
# --enable-flush 0
