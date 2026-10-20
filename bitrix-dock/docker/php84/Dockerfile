FROM php:8.4-fpm-alpine as base

# 1. Системные runtime-библиотеки
RUN apk add --no-cache \
    shadow \
    bash \
    git \
    tzdata \
    icu-libs \
    libxml2 \
    libzip \
    oniguruma \
    libpng \
    libjpeg-turbo \
    freetype

# 2. Установка встроенных модулей ядра PHP через docker-php-ext-install
RUN apk add --no-cache --virtual .build-deps-core \
        icu-dev \
        libxml2-dev \
        libzip-dev \
        oniguruma-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        bz2 \
        # [DEPRECATED / РЕКОМЕНДУЕТСЯ УБРАТЬ]: calendar в Битриксе практически не используется, 
        # ядро и интернет-магазин работают со стандартным модулем date / DateTime:
        calendar \
        exif \
        gd \
        intl \
        mbstring \
        mysqli \
        opcache \
        pdo_mysql \
        # [DEPRECATED / РЕКОМЕНДУЕТСЯ УБРАТЬ]: soap нужен только при прямом обмене по SOAP с 1С/WSDL. 
        # Если интеграций по старому SOAP нет — модуль избыточен:
        soap \
        zip \
    && apk del .build-deps-core

# 3. Установка внешних расширений через PIE
RUN --mount=type=bind,from=ghcr.io/php/pie:bin,source=/pie,target=/usr/local/bin/pie \
    apk add --no-cache --virtual .build-deps-ext \
        autoconf \
        automake \
        libtool \
        m4 \
        make \
        gcc \
        g++ \
        zlib-dev \
        linux-headers \
        git \
        unzip \
    # phpredis — основной инструмент кеширования и сессий Битрикс:
    && pie install --no-cache phpredis/phpredis \
    # [DEPRECATED / РЕКОМЕНДУЕТСЯ УБРАТЬ]: старый модуль memcache (не memcached).
    # В Битриксе устарел и вытеснен Redis. Оставлен по вашему требованию.
    # PIE не поддерживает форк websupport-sk, поэтому собираем из исходников:
    && git clone --depth=1 https://github.com/websupport-sk/pecl-memcache.git /tmp/memcache \
    && cd /tmp/memcache \
    && phpize \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && docker-php-ext-enable memcache \
    && rm -rf /tmp/memcache \
    && apk del .build-deps-ext

# Configure PHP
COPY ./php.ini /usr/local/etc/php/conf.d/bitrix.ini

# Set up user and permissions
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data
RUN mkdir -p /var/log/php && chown www-data:www-data /var/log/php

WORKDIR /var/www

# -----------------------------------------------------------------------------
# Среда разработки (Local Dev)
# -----------------------------------------------------------------------------
FROM base as dev

# Сборка Xdebug через git (PIE зависает при активации Xdebug)
RUN apk add --no-cache --virtual .build-deps-xdebug \
        autoconf \
        make \
        gcc \
        g++ \
        linux-headers \
        git \
    && git clone --depth=1 --branch 3.5.3 https://github.com/xdebug/xdebug.git /tmp/xdebug \
    && cd /tmp/xdebug \
    && phpize \
    && ./configure --enable-xdebug \
    && make -j$(nproc) \
    && make install \
    && docker-php-ext-enable xdebug \
    && rm -rf /tmp/xdebug \
    && apk del .build-deps-xdebug

ENV XDEBUG_CONFIG="client_host=host.docker.internal client_port=9003 start_with_request=yes"

# -----------------------------------------------------------------------------
# Продакшн-среда
# -----------------------------------------------------------------------------
FROM base as prod
# Production specific settings if any