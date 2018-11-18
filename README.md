# Satisfy in Docker
[![Docker Automated build](https://img.shields.io/docker/automated/anapsix/satisfy.svg)](https://hub.docker.com/r/anapsix/satisfy/ "see it on Docker Hub") [![Docker Pulls](https://img.shields.io/docker/pulls/anapsix/satisfy.svg)](https://hub.docker.com/r/anapsix/satisfy/)



[Satisfy][1] - Satis composer repository manager with a Web UI, in Docker container based on Alpine Linux.

 component    | version
------------- | -------
Alpine Linux  | `3.8`
PHP           | `7.2`
Composer      | `1.7.3`
Satisfy       | `3.0.4`


## Build and Run
```
docker build -t satisfy .
docker run -d --rm \
           --name satisfy \
           -e SSH_PRIVATE_KEY="$(<./id_rsa)" \
           -p 8080:8080 \
           satisfy
```

## Run
```
docker run -d --rm \
           --name satisfy \
           -e SSH_PRIVATE_KEY="$(<./id_rsa)" \
           -p 8080:8080 \
           anapsix/satisfy
```

## Launch options
See [`entrypoint.sh`][2]


[: Links Reference :]::
[1]: https://github.com/ludofleury/satisfy
[2]: ./entrypoint.sh
