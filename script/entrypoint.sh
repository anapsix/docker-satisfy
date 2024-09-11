#!/usr/bin/env bash

set -e
set -u

GENERATED_SECRET="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)"
PARAM_FILE="${APP_ROOT}/config/parameters.yml"
SATIS_FILE="${APP_ROOT}/satis.json"

: ${APP_ROOT:?must be set}
: ${APP_USER:?must be set}
: ${SECRET:=$GENERATED_SECRET}
: ${ADMIN_AUTH:=false}
: ${ADMIN_USERS:="[]"}
: ${GITHUB_SECRET:=\~}
: ${GITLAB_SECRET:=\~}
: ${GITLAB_AUTO_ADD_REPO:=false}
: ${GITLAB_AUTO_ADD_REPO_TYPE:=\~}

: ${REPO_NAME:=myorg/myrepo}
: ${HOMEPAGE:=http://localhost:8080}

: ${SSH_PRIVATE_KEY:=unset}
: ${ADD_HOST_KEYS:=false}
: ${STRICT_HOST_KEY_CHECKING:-default set down below}

: ${CRON_ENABLED:=true}
: ${CRON_SYNC_EVERY:=60}

APP_USER_HOME="$(awk -F: -v user="${APP_USER}" '$1==user {print $6}' /etc/passwd)"

if [[ ! -e ${PARAM_FILE} ]]; then
  cat >${PARAM_FILE} <<EOF
parameters:
  secret: ${SECRET}
  satis_filename: ${APP_ROOT}/satis.json
  satis_log_path: ${APP_ROOT}/var/satis
  admin.auth: ${ADMIN_AUTH}
  admin.users: ${ADMIN_USERS}
  composer.home: ${APP_ROOT}/.composer
  github.secret: ${GITHUB_SECRET}
  gitlab.secret: ${GITLAB_SECRET}
  gitlab.auto_add_repo: ${GITLAB_AUTO_ADD_REPO}
  gitlab.auto_add_repo_type: ${GITLAB_AUTO_ADD_REPO_TYPE}
EOF
  chown ${APP_USER}:${APP_USER} ${PARAM_FILE}
fi


if [[ ! -e ${SATIS_FILE} ]]; then
  cat >${SATIS_FILE} <<EOF
{
    "name": "${REPO_NAME}",
    "homepage": "${HOMEPAGE}",
    "repositories": [
    ],
    "require-all": true,
    "providers": true,
    "archive": {
        "directory": "dist",
        "format": "zip",
        "skip-dev": false
    }
}
EOF
  chown ${APP_USER}:${APP_USER} ${SATIS_FILE}
fi


if [[ "${SSH_PRIVATE_KEY}" != "unset" ]] && [[ ! -e ${APP_ROOT}/id_rsa ]]; then
  echo "${SSH_PRIVATE_KEY}" > ${APP_ROOT}/id_rsa
  chmod 400 ${APP_ROOT}/id_rsa
  chown ${APP_USER}:${APP_USER} ${APP_ROOT}/id_rsa
fi


if [[ ! -e ${APP_USER_HOME}/.ssh ]]; then
  mkdir ${APP_USER_HOME}/.ssh
  chown ${APP_USER}:${APP_USER} ${APP_USER_HOME}/.ssh
  chmod 700 ${APP_USER_HOME}/.ssh
fi


if [[ ${ADD_HOST_KEYS} == "true" ]]; then
  : ${STRICT_HOST_KEY_CHECKING:=yes}
  while inotifywait -e close_write ${SATIS_FILE}; do
    gosu ${APP_USER}:${APP_USER} /record_host_fingerprint.sh
  done&
fi


if [[ ! -e ${APP_USER_HOME}/.ssh/config ]]; then
  : ${STRICT_HOST_KEY_CHECKING:=no}
  cat >${APP_USER_HOME}/.ssh/config <<EOF
Host *
IdentityFile ${APP_ROOT}/id_rsa
StrictHostKeyChecking ${STRICT_HOST_KEY_CHECKING}
EOF
chmod 400 ${APP_USER_HOME}/.ssh/config
chown ${APP_USER}:${APP_USER} ${APP_USER_HOME}/.ssh/config
fi


if [[ "${CRON_ENABLED}" == "true" ]]; then
  gosu ${APP_USER}:${APP_USER} /sync_repos.sh ${CRON_SYNC_EVERY}&
fi


if [[ "${1:-unset}" == "satisfy" ]]; then
  echo >&2 "Starting NGINX Unit.."
  unitd --log /dev/stdout
  echo >&2 "Stating Nginx.."
  exec -- nginx
else
  exec -- sh
fi
