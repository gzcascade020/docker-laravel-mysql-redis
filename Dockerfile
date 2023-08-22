FROM gzcascade/php:8.1-apache-bullseye

# Description
# This image provides an Apache 2.4 + PHP 8.2 environment for running Laravel applications.
# Exposed ports:
# * 8080 - alternative port for http

ENV LARAVEL_VERSION=10 \
    LARAVEL_VER_SHORT=10 \
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

ENV EXT_REDIS_VERSION=5.3.7

# Install PHP extensions
# gd
RUN requirements="libpng-dev libjpeg62-turbo libjpeg62-turbo-dev libfreetype6 libfreetype6-dev libgpgme11-dev" \ 
    && apt-get update \
    && apt-get install -y $requirements \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd
    
# igbinary
RUN pecl install igbinary \
    && docker-php-ext-enable igbinary

# redis
RUN mkdir -p /usr/src/php/ext/redis \
    && curl -fsSL https://github.com/phpredis/phpredis/archive/$EXT_REDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && docker-php-ext-configure redis --enable-redis-igbinary \
    && docker-php-ext-install redis

# others
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions \ 
    && install-php-extensions gnupg pdo_mysql intl

# Cleanup
RUN docker-php-source delete \
    && requirementsToRemove="libpng-dev libjpeg62-turbo-dev libfreetype6-dev " \
    && apt-get purge --auto-remove -y $requirementsToRemove \
    && rm -rf /var/lib/apt/lists/*

# Enable httpd rewrite mod
RUN a2enmod rewrite

# Add pre-start scripts
COPY ./pre-start ${PHP_CONTAINER_SCRIPTS_PATH}/pre-start/

USER 1001
WORKDIR ${HOME}
