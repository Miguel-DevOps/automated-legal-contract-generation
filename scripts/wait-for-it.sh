#!/usr/bin/env bash
# wait-for-it.sh: Wait for a service to be available before continuing
# Usage: ./scripts/wait-for-it.sh host:port [--timeout=seconds]

hostport=$1
timeout=${2:---timeout=30}

host=$(echo $hostport | cut -d: -f1)
port=$(echo $hostport | cut -d: -f2)

start_ts=$(date +%s)

while :
do
  (echo > /dev/tcp/$host/$port) >/dev/null 2>&1 && break
  sleep 1
  now_ts=$(date +%s)
  if [ $((now_ts-start_ts)) -ge ${timeout#--timeout=} ]; then
    echo "Timeout waiting for $hostport"
    exit 1
  fi
done

echo "$hostport is available."
