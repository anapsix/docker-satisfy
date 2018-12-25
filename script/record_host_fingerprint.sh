#!/usr/bin/env sh
# scan Satis config for repositorues

set -u

: ${APP_ROOT:?must be set}
: ${APP_USER:?must be set}

APP_USER_HOME="$(awk -F: -v user="${APP_USER}" '$1==user {print $6}' /etc/passwd)"
SATIS_FILE="${APP_ROOT}/satis.json"

> ${APP_USER_HOME}/.ssh/known_hosts
chown ${APP_USER}:${APP_USER} ${APP_USER_HOME}/.ssh/known_hosts
chmod 600 ${APP_USER_HOME}/.ssh/known_hosts

for host in $(jq -r '.repositories | .[] | select(.type=="git") | .url | scan("(?<=@)[A-Za-z0-9-]+\\.[a-z]+")' ${SATIS_FILE}); do
  ssh-keyscan $host >> ${APP_USER_HOME}/.ssh/known_hosts
done