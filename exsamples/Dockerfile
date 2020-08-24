ARG LARAVEL_TAG=5.7-apache-stretch
#######################################################################################################################
#
# Stage 1
#
# Install PHP dependencies
FROM composer as vendor
# ARG http_proxy=http://proxy.company.com:8080
# ARG https_proxy=http://proxy.company.com:8080
COPY composer.json composer.json
COPY composer.lock composer.lock
COPY database database
RUN composer install \
        --ignore-platform-reqs \
        --no-interaction \
        --no-plugins \
        --no-scripts \
        --prefer-dist \
        --optimize-autoloader \
        --no-dev


#######################################################################################################################
#
# Stage 2
#
# Compiling Assets https://laravel.com/docs/5.7/mix
FROM node:alpine as assets
RUN mkdir -p /app/public
COPY package.json package-lock.json /app/
WORKDIR /app
# RUN npm config set proxy http://proxy.company.com:8080 && \
#     npm config set https-proxy http://proxy.company.com:8080
RUN npm install
COPY webpack.mix.js /app/
COPY resources/sass/ /app/resources/sass/
COPY resources/js/ /app/resources/js/
RUN npm run production

#######################################################################################################################
#
# Stage 3
#
# Fix file permissions
FROM gzcascade/laravel:${LARAVEL_TAG} as source

USER root

# Copy source code
COPY . /app

WORKDIR /app

# Copy files from vendor stage
COPY --from=vendor /app/vendor/ /app/vendor/
# Copy files from assets stage
COPY --from=assets /app/public/js/ /app/public/js/
COPY --from=assets /app/public/css/ /app/public/css/
COPY --from=assets /app/mix-manifest.json /app/mix-manifest.json
RUN chmod -R g+rwX /app/storage /app/bootstrap/cache
RUN php artisan route:cache && \
    php artisan view:cache

#######################################################################################################################
#
# Stage 4
#
# Build Image
FROM gzcascade/laravel:${LARAVEL_TAG}

USER root

# Copy source code
COPY --from=source /app ${APP_DATA}

USER 1001
WORKDIR ${HOME}