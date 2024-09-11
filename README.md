# Satisfy in Docker

![License](https://img.shields.io/github/license/anapsix/docker-satisfy.svg) [![Built with Nginx](https://img.shields.io/badge/built%20with-NGINX%20+%20Unit-green.svg?logo=nginx&logoColor=white)][unit]
[![Docker Automated build](https://img.shields.io/docker/automated/anapsix/satisfy.svg)][docker hub] [![Docker Pulls](https://img.shields.io/docker/pulls/anapsix/satisfy.svg)][docker hub]

[Satisfy][1] - Satis composer repository manager with a Web UI, in Docker container based on Alpine Linux.

## Features
* After container launch, configured repos are synced every `CRON_SYNC_EVERY` seconds (60), as long as `CRON_ENABLED` is `true`
* If `ADD_HOST_KEYS` is `true`, any time new Git repo is added, SSH fingerprints are collected and saved.
* SSH private key can be passed via `SSH_PRIVATE_KEY` to enable sync for `git+ssh` type repos.

## Versions
 component    | version
------------- | -------
Alpine Linux  | `3.20`
PHP           | `8.2`
Composer      | `2.7.9`
Satisfy       | `3.7.0`


## Build and Run
```
docker build -t satisfy .
docker run -d --rm \
           --name satisfy \
           -e SSH_PRIVATE_KEY="$(<./id_rsa)" \
           -p 8080:80 \
           satisfy
```

## Run
```
docker run -d --rm \
           --name satisfy \
           -e SSH_PRIVATE_KEY="$(<./id_rsa)" \
           -e CRON_SYNC_EVERY=120 \
           -p 8080:80 \
           anapsix/satisfy
```

## Launch options
See [`entrypoint.sh`][2] for more details

 option             | description
------------------- | --------
`REPO_NAME`         | name of your repository, defaults to `my-vendor-name/my-package-name`
`HOMEPAGE`          | url of this repository, defaults to `http://localhost:8080`
`SSH_PRIVATE_KEY`   | private SSH key, used to access `git` repos, unused by default
`ADD_HOST_KEYS`     | flag to enable watching `satis.json` for `git` repos, also turns on SSH `StrictHostKeyChecking`, defaults to `false`
`CRON_ENABLED`      | flag to enable periodic `satis build`, defaults to `true`
`CRON_SYNC_EVERY`   | rebuild satis index frequency, in seconds, defaults to `60`


Access the Admin UI via http://localhost:8080/admin.


[== Links Reference ==]::
[license]: ./LICENSE
[docker hub]: https://hub.docker.com/r/anapsix/satisfy/ "see it on Docker Hub"
[unit]: https://unit.nginx.org/ "built with Nginx & Nginx Unit"
[1]: https://github.com/ludofleury/satisfy
[2]: ./entrypoint.sh
