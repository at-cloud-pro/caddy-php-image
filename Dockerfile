FROM php:8.3-fpm-alpine3.19 AS rte

# Install Caddy
RUN apk add --no-cache \
    curl \
    libcap \
    mailcap \
&& apk add caddy

# install php extensions
RUN apk add --no-cache \
    icu-dev \
    postgresql-dev \
    libzip-dev \
    $PHPIZE_DEPS \
&& pecl install \
    redis \
    apcu \
&& docker-php-ext-install \
    intl \
    opcache \
    pdo_mysql \
    pdo_pgsql \
    zip \
&& docker-php-ext-enable \
    redis \
    sodium \
    apcu

# install composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# configure caddy
COPY ./etc/Caddyfile /etc/caddy/Caddyfile
RUN mkdir -p /var/www/.config/caddy \
&& chmod -R 777 /var/www/.config

ENV CADDY_CGI_SERVER_HOST="127.0.0.1"
ENV CADDY_CGI_SERVER_PORT="9000"
ENV CADDY_LOG_OUTPUT="stderr"
# DEBUG|INFO|WARN|ERROR|PANIC|FATAL (https://caddyserver.com/docs/json/logging/logs/level/)
ENV CADDY_LOG_LEVEL="ERROR"

# FPM configuration
COPY ./etc/php-fpm.conf /usr/local/etc/php-fpm.d/php-fpm.conf
ENV FPM_WORKERS_COUNT="2"
# "/proc/self/fd/1" does not work for FPM_ACCESS_LOG
ENV FPM_ACCESS_LOG="/proc/self/fd/2"
ENV FPM_ERROR_LOG="/proc/self/fd/2"
# debug|notice|warning|error|alert (https://www.php.net/manual/en/install.fpm.configuration.php#log-level)
ENV FPM_LOG_LEVEL="error"

# configure php
COPY ./etc/php.ini /usr/local/etc/php/conf.d/php.ini
ENV PHP_OPCACHE_ENABLE="true"
COPY ./etc/apcu.ini /usr/local/etc/php/conf.d/apcu.ini
ENV PHP_APCU_ENABLE=1
ENV PHP_ERROR_LOG="/proc/self/fd/2"
# E_ALL|E_STRICT|E_NOTICE|E_WARNING|E_ERROR|E_CORE_ERROR (https://www.php.net/manual/en/errorfunc.constants.php)
ENV PHP_LOG_LEVEL="E_ERROR"

# configure composer
ENV COMPOSER_ALLOW_SUPERUSER="1"

# entrypoint
ENTRYPOINT []
CMD ["bash", "-c", "php-fpm --daemonize && caddy run --config=/etc/caddy/Caddyfile"]
EXPOSE 80 9000
HEALTHCHECK NONE
WORKDIR /app


FROM rte AS sdk

# install xdebug
RUN apk add --no-cache $PHPIZE_DEPS linux-headers \
&& pecl install xdebug  \
&& docker-php-ext-enable xdebug

# configure xdebug
COPY ./etc/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
ENV XDEBUG_MODE="off"
ENV XDEBUG_CONFIG=""
ENV XDEBUG_OUTPUT_DIR="/tmp"
