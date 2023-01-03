FROM php:8.2-fpm-buster AS rte

# Install Caddy
RUN apt-get update && apt-get install --yes --no-install-recommends \
  apt-transport-https \
  debian-archive-keyring \
  debian-keyring \
  gnupg2 \
&& apt-get clean && rm -rf /var/lib/apt/lists/* \
&& curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
&& curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list \
&& apt-get update && apt-get install --yes --no-install-recommends \
  caddy \
  mime-support \
&& apt-get clean && rm -rf /var/lib/apt/lists/* \
&& rm \
  /etc/caddy/Caddyfile

# Install PHP extensions
RUN rm \
  /usr/local/etc/php-fpm.d/* \
  /usr/local/etc/php/conf.d/* \
&& apt-get update && apt-get install --yes --no-install-recommends \
  libicu-dev \
  libpq-dev \
  libzip-dev \
  unzip \
  zip \
  zlib1g-dev \
&& apt-get clean && rm -rf /var/lib/apt/lists/* \
&& pecl install \
  redis \
&& pecl clear-cache \
&& docker-php-ext-install \
  intl \
  opcache \
  pdo_mysql \
  pdo_pgsql \
  zip \
&& docker-php-ext-enable \
  redis \
  sodium

# Install Composer
RUN apt-get update && apt-get install --yes --no-install-recommends git
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Caddy configuration
COPY ./etc/Caddyfile /etc/caddy/Caddyfile
RUN mkdir -p /var/www/.config/caddy
RUN chmod -R 777 /var/www/.config

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

# PHP configuration
COPY ./etc/php.ini /usr/local/etc/php/conf.d/php.ini
ENV PHP_OPCACHE_ENABLE="true"
ENV PHP_ERROR_LOG="/proc/self/fd/2"
# E_ALL|E_STRICT|E_NOTICE|E_WARNING|E_ERROR|E_CORE_ERROR (https://www.php.net/manual/en/errorfunc.constants.php)
ENV PHP_LOG_LEVEL="E_ERROR"

# Composer configuration
ENV COMPOSER_ALLOW_SUPERUSER="1"

# Entrypoint
ENTRYPOINT []
CMD ["bash", "-c", "php-fpm --daemonize && caddy run --config=/etc/caddy/Caddyfile"]
EXPOSE 80 9000
HEALTHCHECK NONE
WORKDIR /app


FROM rte AS sdk

# Install Xdebug
RUN pecl install xdebug
RUN pecl clear-cache
RUN docker-php-ext-enable xdebug

# Xdebug configuration
COPY ./etc/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
ENV XDEBUG_MODE="off"
ENV XDEBUG_CONFIG=""
ENV XDEBUG_OUTPUT_DIR="/tmp"
