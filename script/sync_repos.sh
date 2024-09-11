#!/usr/bin/env bash
# sync repos every X seconds

set -u

: ${APP_ROOT:?must be set}

SYNC_EVERY=${1:-60}
LOCKFILE="${APP_ROOT}/sync_repos.lock"
LOCKTIMEOUT_SECONDS="300"

function check() {
  if [[ -r ${LOCKFILE} ]]; then
    now="$(date +%s)"
    last_changed="$(stat -c %Y ${LOCKFILE})"
    diff="$(( ${now} - ${last_changed} ))"
    if [[ ${diff} -gt ${LOCKTIMEOUT_SECONDS} ]]; then
      echo "## sync lockfile found, older than timeout (${LOCKTIMEOUT_SECONDS}), ignoring"
      unlock
      return 0
    else
      echo "## sync lockfile found, fresher than timeout (${LOCKTIMEOUT_SECONDS})"
      return 1
    fi
  else
    return 0
  fi
}

function lock() {
  lockfile-create --retry 3 --use-pid --lock-name ${LOCKFILE}
}

function unlock() {
  rm -rf ${LOCKFILE}
}

trap unlock EXIT

while true; do
  sleep ${SYNC_EVERY}
  echo "## running satis build.."
  if [[ -r "${APP_ROOT}/satis.json" ]]; then
    if check && lock; then
      ${APP_ROOT}/bin/satis build ${APP_ROOT}/satis.json ${APP_ROOT}/public
      unlock
      echo "## completed satis build run"
    fi
  else
    echo "## no config present at ${APP_ROOT}/satis.json, skipping.."
  fi
done
