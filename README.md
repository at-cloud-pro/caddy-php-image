[![.github/workflows/workflow.yaml](https://github.com/archi-tektur/caddy-php-image/actions/workflows/workflow.yaml/badge.svg?branch=main)](https://github.com/archi-tektur/caddy-php-image/actions/workflows/workflow.yaml)

# Caddy PHP Image
This is a scaffold image of high-performance PHP server using Caddy and php-fpm daemon. It's common image for my
internal and external projects as it contains all the PHP server setup and configuration in one place.

## What's inside
The package uses as a base `php:8.2-fpm` image, and adds:
* fully-configured Caddy runner with php-fpm daemon
* PHP extensions required by Symfony (`intl`, `pdo_mysql`, `pdo_pgsql`, `redis`, `sodium`)
* PHP extensions required for maximum application performance (`opcache`, `zip`, `apcu`)
* Composer package manager with cache optimizations (local OS cache is bind)
* php-fpm configuration for maximum performance
* Configured and ready to use Xdebug debugger

## How to use this image
The simplest possible way of implementing it is shown below. Let's assume you have a Symfony (PHP) project with
structure as follows:

```
my-awesome-project
└───.idea
└───.git
└───.github
└───app
│   └───bin
│   └───config
│   └───public
│   └───src
│   └───tests
│   └───var
│   └───vendor
│   │   composer.json
│   │   composer.lock
│   Dockerfile
```

Content of your Dockerfile:

```dockerfile
FROM ghcr.io/archi-tektur/caddy-php:2.4.0 AS app

COPY ./app /app

RUN composer install

USER www-data:www-data
```
In Dockerfile shown above you're just copying `app` folder, and you're all set. You may install Composer packages or do
other actions that your application requires to run - it's extensive.

Last line is recommended to avoid privilege issues on files created in container by other processes.

## Changelog
Changelog is available [here](CHANGELOG.md). Please update changelog each time commission is made. I adapted
[semantic versioning](https://semver.org/) in this repository, and this versioning practice should be used.
