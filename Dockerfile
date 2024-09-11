FROM alpine:3.20

ARG APP_USER=satisfy

ENV \
    COMPOSER_VERSION=2.7.9 \
    SATISFY_VERSION=3.7.0 \
    LD_PRELOAD=/usr/lib/preloadable_libiconv.so \
    PHP_INI_PATH=/etc/php82/php.ini \
    PHP_INI_SCAN_DIR=/etc/php82/conf.d \
    APP_ROOT=/app \
    APP_USER=${APP_USER}

LABEL \
      maintainer="Anastas Dancha <https://github.com/anapsix>" \
      com.php.composer.version="${COMPOSER_VERSION}" \
      playbloom.satisfy.version="${SATISFY_VERSION}"

RUN \
    apk upgrade --no-cache && \
    apk add --no-cache bash lockfile-progs php82-apcu php82-bcmath php82-ctype php82-curl php82-dom php82-fileinfo \
      php82-iconv php82-json php82-mbstring php82-openssl php82-phar php82-session \
      php82-simplexml php82-xml php82-xmlwriter php82-tokenizer php82-zip \
      nginx unit-php82 \
      libxml2-dev inotify-tools jq zip curl openssh-client git && \
    apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gosu && \
    ln -s /usr/bin/php82 /usr/bin/php && \
    curl -o /usr/local/bin/composer https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar && \
    chmod +x /usr/local/bin/composer && \
    rm -rf /var/cache/apk/* && \
    if [[ "$APP_USER" != "root" ]]; then adduser -h ${APP_ROOT} -D -H ${APP_USER}; fi

WORKDIR ${APP_ROOT}

RUN \
    yes | composer create-project \
        --no-dev \
        playbloom/satisfy . \
        ${SATISFY_VERSION} && \
    rm ${APP_ROOT}/config/parameters.yml && \
    echo "HTTP server is up" > ${APP_ROOT}/web/serverup.txt && \
    mkdir ${APP_ROOT}/.composer && \
    chown -R ${APP_USER}:${APP_USER} ${APP_ROOT}

COPY script/*.sh /
COPY config/unit.json /var/lib/unit/conf.json
COPY config/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "satisfy" ]
