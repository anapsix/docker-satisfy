#!/usr/bin/env sh
# sync repos every X seconds

set -u

: ${APP_ROOT:?must be set}

SYNC_EVERY=${1:-60}
LOCKFILE="${APP_ROOT}/sync_repos.lock"
LOCKTIMEOUT="300"

function lock(){
	lockfile -1 -r1 -l${LOCKTIMEOUT} ${LOCKFILE} >&2
}

function unlock(){
	rm ${LOCKFILE}
}

while true; do
  sleep ${SYNC_EVERY}
  if [[ -e ${APP_ROOT}/satis.json ]]; then
  	if lock; then
	    ${APP_ROOT}/bin/satis build ${APP_ROOT}/satis.json ${APP_ROOT}/web
	    unlock
	  fi
  fi
done
