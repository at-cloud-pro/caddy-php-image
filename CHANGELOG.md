# Changelog

## 4.0.0 (2024-02-22)
### Changed
- use alpine image to use much less space

## 3.0.0 (2023-12-03)
### Changed
update PHP image to version 8.3

## 2.4.0 (2021-12-03)
### Changed
- update PHP image to version 8.3

### v2.3.0
- install and enable php apcu extension

### v2.2.0
- fix Caddyfile formatting

### v2.1.0
- update PHP image to version 8.2
- update CI scripts standard

### v2.0.0
- use Debian Buster image as a source (compatibility with linux/arm64/v8)

### v1.1.0
- fix Caddyfile syntax (no warning in logs is thrown)
- fix implementation details of environment configuration on GH Actions

### v1.0.4
- minor files review, removing files which are not required for image to run
- remove Symfony console completion
- change logging into ghcr from native to package use

### v1.0.3
- changed base PHP docker image to php:8.1-fpm
