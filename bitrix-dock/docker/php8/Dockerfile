FROM php:8.2-fpm-alpine as base

RUN apk update && apk add \
    shadow g++ make git wget \
    bzip2-dev zlib-dev \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    libzip-dev oniguruma-dev \
    libxml2-dev icu-dev tzdata fcgi \
    ca-certificates openssl openssh \ 
    cyrus-sasl-dev

RUN update-ca-certificates
# install php composer
# RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
#     && php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
#     && php composer-setup.php --install-dir=/usr/bin --filename=composer \
#     && php -r "unlink('composer-setup.php');"

# install php packages
# possible options in `docker-php-exe-install'`
# bcmath   |fileinfo |json      |pdo_firebird |readline   |standard   |zend_test
# bz2      |filter   |ldap      |pdo_mysql    |reflection |sysvmsg    |zip
# calendar |ftp      |mbstring  |pdo_oci      |session    |sysvsem
# ctype    |gd       |mysqli    |pdo_odbc     |shmop      |sysvshm
# curl     |gettext  |oci8      |pdo_pgsql    |simplexml  |tidy
# dba      |gmp      |odbc      |pdo_sqlite   |snmp       |tokenizer
# dom      |hash     |opcache   |pgsql        |soap       |xml
# enchant  |iconv    |pcntl     |phar         |sockets    |xmlreader
# exif     |imap     |pdo       |posix        |sodium     |xmlwriter
# ffi      |intl     |pdo_dblib |pspell       |spl        |xsl
RUN docker-php-ext-install bcmath bz2 mysqli pdo_mysql mbstring intl pdo opcache xml soap \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
# RUN docker-php-ext-install bz2

## Deps the block below is an example of how to install memcache and redis feature
## uncomment if you need this features installed
## Install Memcache and redis
ENV MEMCACHE_DEPS zlib-dev cyrus-sasl-dev g++ make git
RUN apk add --no-cache -t .phpize-deps $PHPIZE_DEPS \
    && apk add --no-cache -t .memcache-deps $MEMCACHE_DEPS \
## Prepare php for extensions
    # && apk add --no-cache -u \
## Install timezone util
    # tzdata \
## fpm healthcheck status check dep
    # fcgi \
    # zlib-dev \
## Install php-redis
#     pecl install redis -y && \
#     docker-php-ext-enable redis && \
## Install memcache
    && cd /tmp && git clone https://github.com/websupport-sk/pecl-memcache \
    && cd pecl-memcache \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && docker-php-ext-enable memcache
## Install mcrypt
# RUN pecl update-channels pecl.php.net \
    # && apk del .phpize-deps && apk del .memcache-deps
RUN pecl update-channels && apk del .memcache-deps


COPY ./php.ini /usr/local/etc/php/conf.d/php.ini

RUN usermod -u 1000 www-data
RUN mkdir -p /var/log/php && chown www-data:www-data /var/log/php

## Install xdebug
#FROM base as dev
#ENV XDEBUG_CONF=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
#RUN apk add --no-cache $PHPIZE_DEPS && pecl install xdebug && docker-php-ext-enable xdebug
#WORKDIR /var/www

FROM base as dev
ENV XDEBUG_CONF=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN apk add --no-cache --virtual .dev-deps $PHPIZE_DEPS
RUN apk add --update linux-headers
RUN pecl update-channels
RUN pecl install xdebug && docker-php-ext-enable xdebug
#RUN pecl install rdkafka && docker-php-ext-enable rdkafka
RUN apk del -f .dev-deps    
WORKDIR /var/www

## injecting all code
FROM base as code
WORKDIR /var/www
COPY . .
# remove unused code
RUN rm -rf .git .github .vscode docs coverage vendor

FROM code as ci
WORKDIR /var/www
RUN composer install

FROM code as prod
WORKDIR /var/www
RUN composer install --no-dev
