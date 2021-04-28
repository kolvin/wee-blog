FROM php:8.0.3-fpm AS base

ARG PROJECT_NAME=kolv.in
ENV PROJECT_NAME ${PROJECT_NAME}
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libzip-dev \
        libcurl4-openssl-dev \
        unzip \
        zip \
        vim \
        zlib1g-dev \
        && rm -rf /var/lib/apt/lists/* \
        && docker-php-ext-install -j$(nproc) gd zip curl pdo pdo_mysql

COPY .docker/scripts/ scripts/

RUN ./scripts/composer_install.sh

COPY .docker/config/php/php.ini.development $PHP_INI_DIR/php.ini

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

WORKDIR /var/www/${PROJECT_NAME}


FROM composer AS dependencies
COPY app/composer.json /app
COPY app/composer.lock /app
COPY app/symfony.lock /app
RUN composer install --ignore-platform-reqs --no-scripts
LABEL image=dependencies


FROM base
ARG BUILD_ENV=dev
ARG PROJECT_NAME=kolv.in
ENV PROJECT_NAME ${PROJECT_NAME}


COPY app /var/www/${PROJECT_NAME}
WORKDIR /var/www/${PROJECT_NAME}

COPY --from=dependencies app/vendor vendor

# TODO check how to install chrome into php-fpm image,
# if i decide to use panther for browser testsing
# RUN ./scripts/composer_install.sh
#RUN apt-get update && apt-get install -y libappindicator1 fonts-liberation \
#    && wget https://dl.google.com/dl/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb \
#    && dpkg -i /tmp/chrome.deb; apt-get -fy install \
#    && rm /tmp/chrome.deb

# RUN vendor/bin/bdi detect /etc/chromium-browser
# ENV PANTHER_CHROME_DRIVER_BINARY="/etc/chromium-browser/chromedriver"
# ENV PANTHER_NO_SANDBOX 1
# ENV PANTHER_WEB_SERVER_PORT 9800
# ENV PANTHER_CHROME_ARGUMENTS='--disable-dev-shm-usage'

RUN bin/console ca:cl
RUN chmod -R 777 var/log var/cache

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD php-fpm -t || exit 1
