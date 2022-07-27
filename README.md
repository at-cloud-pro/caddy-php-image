# Caddy PHP Image
This is a scaffold image of high-performance PHP server using Caddy and php-fpm daemon. It's common image for my 
internal and external projects as it contains all the PHP server setup and configuration in one place.

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
FROM ghcr.io/archi-tektur/caddy-php:1.0.2 AS app

COPY ./app /app
RUN composer install

USER www-data:www-data
```
And actually you're all set!