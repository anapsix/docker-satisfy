#!/usr/bin/env sh

# sync repos every X seconds

SYNC_EVERY=${1:-60}

while true; do
  sleep ${SYNC_EVERY}
  ${APP_ROOT}/bin/satis build ${APP_ROOT}/satis.json
done
