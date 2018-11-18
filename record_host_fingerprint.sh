#!/usr/bin/env sh

SATIS_FILE="${APP_ROOT}/satis.json"

> ~/.ssh/known_hosts

for host in $(jq -r '.repositories | .[] | select(.type=="git") | .url | scan("(?<=@)[A-Za-z0-9-]+\\.[a-z]+")' ${SATIS_FILE}); do
  ssh-keyscan $host >> ~/.ssh/known_hosts
done