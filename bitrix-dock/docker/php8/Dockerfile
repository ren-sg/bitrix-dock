FROM php:8.2-fpm-alpine as base

# Install system dependencies
RUN apk add --no-cache \
    shadow \
    bash \
    git \
    tzdata \
    icu-dev \
    libxml2-dev \
    libzip-dev \
    oniguruma-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev

# Install PHP extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
    bcmath \
    bz2 \
    calendar \
    exif \
    gd \
    intl \
    mbstring \
    mysqli \
    opcache \
    pdo_mysql \
    soap \
    zip \
    memcache \
    redis

# Configure PHP
COPY ./php.ini /usr/local/etc/php/conf.d/bitrix.ini

# Set up user and permissions
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data
RUN mkdir -p /var/log/php && chown www-data:www-data /var/log/php

WORKDIR /var/www

FROM base as dev
RUN install-php-extensions xdebug
ENV XDEBUG_CONFIG="client_host=host.docker.internal client_port=9003 start_with_request=yes"

FROM base as prod
# Production specific settings if any
