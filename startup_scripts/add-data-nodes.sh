#!/bin/bash
set -e
# print commands executed for debugging
set -x

# get host ip and remove trailing space
# readonly host_ip="$(hostname -I | awk '{$1=$1};1' )"
readonly full_hostname="$(hostname -f)"
readonly api_port=":8091"

# export couchbase binaries to use cli tools
export PATH=/opt/couchbase/bin:$PATH


# Return true (0) if the first string (haystack) contains the second string (needle), and false (1) otherwise.
function string_contains {
  local -r haystack="$1"
  local -r needle="$2"

  [[ "$haystack" == *"$needle"* ]]
}

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

function add_server {
  local readonly server_add_max_retries=120
  local readonly sleep_between_server_add_retries_sec=5

  for (( i=0; i<"$server_add_max_retries"; i++ )); do
    # server-add-username use admin credentials if new node has not been provisioned,
    # otherwise specify the provisioned credentials for the node to be added
    out=$(couchbase-cli server-add -c "${cluster_node_ip}$api_port" \
    --username Administrator \
    --password password \
    --server-add "http://$full_hostname$api_port" \
    --server-add-username Administrator \
    --server-add-password password \
    --services data,query)

    if string_contains "$out" "SUCCESS: Server added"; then
      echo "Server is added to couchbase cluster"
      break
    else
      echo "adding server FAILED, sleeping $sleep_between_server_add_retries_sec seconds and then retry adding"
      sleep "$sleep_between_server_add_retries_sec"
    fi

  done

  # need to rebalance after server is added
  # couchbase-cli rebalance -c "${cluster_node_ip}$api_port" \
  # --username Administrator \
  # --password password
}

# run check function, if passed proceed to add the server
check_couchbase
echo "couchbase server is ready, proceeding..."

add_server 

