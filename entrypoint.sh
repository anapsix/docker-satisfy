#!/usr/bin/env sh

set -e
set -u

GENERATED_SECRET="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)"
PARAM_FILE="${APP_ROOT}/app/config/parameters.yml"
SATIS_FILE="${APP_ROOT}/satis.json"

: ${APP_ROOT:?must be set}
: ${SECRET:=$GENERATED_SECRET}
: ${ADMIN_AUTH:=false}
: ${ADMIN_USERS:=\~}

: ${REPO_NAME:=myrepo}
: ${HOMEPAGE:=http://localhost:8080}

: ${SSH_PRIVATE_KEY:=unset}
: ${ADD_HOST_KEYS:=false}
: ${STRICT_HOST_KEY_CHECKING:-default set down below}

: ${CRON_ENABLED:=true}
: ${CRON_SYNC_EVERY:=60}

if [[ ! -e ${PARAM_FILE} ]]; then
  cat >${PARAM_FILE} <<EOF
parameters:
  secret: "${SECRET}"
  satis_filename: "%kernel.project_dir%/satis.json"
  satis_log_path: "%kernel.project_dir%/var/satis"
  admin.auth: ${ADMIN_AUTH}
  admin.users: ${ADMIN_USERS}
  composer.home: "%kernel.project_dir%/.composer"
EOF
fi


if [[ ! -e ${SATIS_FILE} ]]; then
  cat >${SATIS_FILE} <<EOF
{
    "name": "${REPO_NAME}",
    "homepage": "${HOMEPAGE}",
    "repositories": [
    ],
    "require-all": true
}
EOF
fi


if [[ "${SSH_PRIVATE_KEY}" != "unset" ]] && [[ ! -e ${APP_ROOT}/id_rsa ]]; then
  echo "${SSH_PRIVATE_KEY}" > ${APP_ROOT}/id_rsa
  chmod 400 ${APP_ROOT}/id_rsa
fi


if [[ ! -e ~/.ssh ]]; then
  mkdir ~/.ssh
  chmod 700 ~/.ssh
fi


if [[ ${ADD_HOST_KEYS} == "true" ]]; then
  : ${STRICT_HOST_KEY_CHECKING:=yes}
  while inotifywait -e close_write ${SATIS_FILE}; do
    /record_host_fingerprint.sh
  done&
fi


if [[ ! -e ~/.ssh/config ]]; then
  : ${STRICT_HOST_KEY_CHECKING:=no}
  cat >~/.ssh/config <<EOF
Host *
IdentityFile ${APP_ROOT}/id_rsa
StrictHostKeyChecking ${STRICT_HOST_KEY_CHECKING}
EOF
chmod 400 ~/.ssh/config
fi


if [[ "${CRON_ENABLED}" == "true" ]]; then
  /sync_repos.sh ${CRON_SYNC_EVERY}&
fi


if [[ "${1:-unset}" == "satisfy" ]]; then
  exec -- php -S 0.0.0.0:8080 -t ${APP_ROOT}/web
else
  exec -- sh
fi
