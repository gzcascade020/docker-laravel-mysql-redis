FROM gzcascade/php:7.2-apache-stretch

# Description
# This image provides an Apache 2.4 + PHP 7.2 environment for running Laravel applications.
# Exposed ports:
# * 8080 - alternative port for http

ENV LARAVEL_VERSION=5.7 \
    LARAVEL_VER_SHORT=57 \
    NAME=laravel

ENV SUMMARY="Platform for building and running Laravel $LARAVEL_VERSION applications" \
    DESCRIPTION="Laravel is a web application framework with expressive, elegant syntax. \
    We’ve already laid the foundation freeing you to create without sweating the small things."

LABEL summary="${SUMMARY}" \
      description="${DESCRIPTION}" \
      io.k8s.description="${DESCRIPTION}" \
      io.k8s.display-name="Apache 2.4 with Laravel ${LARAVEL_VERSION}" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="${NAME},${NAME}${LARAVEL_VER_SHORT}" \
      version="${LARAVEL_VERSION}"

# Set httpd DocumentRoot
ENV HTTPD_DOCUMENT_ROOT=/public

ENV LARAVEL_CONFIG_CACHE= \
    LARAVEL_OPTIMIZE= \
    LARAVEL_SECRETS=1 \
    LARAVEL_ENV_EXAMPLE_FILES=.env.example \
    LARAVEL_ENV_FILES=.env

USER root

ENV EXT_REDIS_VERSION=5.2.2 \
    EXT_IGBINARY_VERSION=3.1.2

# Install PHP extensions
RUN requirements="libpng-dev libjpeg62-turbo libjpeg62-turbo-dev libfreetype6 libfreetype6-dev" \
    && apt-get update \
    && apt-get install -y $requirements \
    # gd
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
# Install database driver    
    # pdo_mysql
    && docker-php-ext-install pdo_mysql \
# Install cache driver    
    && docker-php-source extract \
    # igbinary
    && mkdir -p /usr/src/php/ext/igbinary \
    && curl -fsSL https://github.com/igbinary/igbinary/archive/$EXT_IGBINARY_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/igbinary --strip 1 \
    && docker-php-ext-install igbinary \
    # redis
    && mkdir -p /usr/src/php/ext/redis \
    && curl -fsSL https://github.com/phpredis/phpredis/archive/$EXT_REDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && docker-php-ext-configure redis --enable-redis-igbinary \
    && docker-php-ext-install redis \
# Cleanup
    && docker-php-source delete \
    && requirementsToRemove="libpng-dev libjpeg62-turbo-dev libfreetype6-dev " \
    && apt-get purge --auto-remove -y $requirementsToRemove \
    && rm -rf /var/lib/apt/lists/*

# Enable httpd rewrite mod
RUN a2enmod rewrite

# Add pre-start scripts
COPY ./pre-start ${PHP_CONTAINER_SCRIPTS_PATH}/pre-start/

USER 1001
WORKDIR ${HOME}
