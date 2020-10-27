FROM alpine:3.12
LABEL Maintainer="Osmell Caicedo <@oele_co>" \
      Description="Lightweight container with Nginx 1.18 & PHP-FPM 7.3 and 5.6 based on Alpine Linux."

# Install php7.3
RUN apk update  \
       && apk upgrade \
       && apk add --no-cache \
       php7 \
       php7-fpm \
       php7-cli \
       php7-gd  \
       php7-mysqli \
       php7-imap \
       php7-mbstring \
       php7-xml \
       php7-curl \
       php7-zip \
       php7-pdo_dblib \
       php7-bcmath \
       php7-ssh2 \
       php7-gmp \
       php7-xdebug \
       php7-imagick \
       php7-json \
       php7-phar

# Install nginx nodejs curl docker
RUN apk update && apk add --no-cache git curl nginx mysql-client npm py-pip \
       && pip install supervisor

# Install php5.6
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.8/main" >> /etc/apk/repositories \
       && echo "http://dl-cdn.alpinelinux.org/alpine/v3.8/community" >> /etc/apk/repositories \
       && apk update && apk add --no-cache php5-fpm \
       php5-gd \
       php5-mysql \
       php5-imap \
       php5-xml \
       php5-curl \
       php5-zip \
       php5-pdo_dblib \
       php5-bcmath

# Install composer
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer --version=1.10.16

# Default vhost
COPY default /etc/nginx/conf.d/default

# PHP 7.3 Configuration
COPY ./php7/php-fpm.conf /etc/php7/php-fpm.conf
COPY ./php7/www.conf /etc/php7/php-fpm.d/www.conf
COPY ./php7/xdebug.ini /etc/php7/conf.d/xdebug.ini
COPY ./php7/php.dev.ini /etc/php7/conf.d/php.dev.ini

# PHP 5.6 Configuration
COPY ./php5/php-fpm.conf /etc/php5/php-fpm.conf
COPY ./php5/www.conf /etc/php5/fpm.d/www.conf

# Default site files
RUN mkdir -p /var/www/html \
    && echo "<?php phpinfo(); ?>" > /var/www/html/index.php \
    && mkdir -p /var/www/ovy/public \
    && echo "<?php phpinfo(); ?>" > /var/www/ovy/public/index.php

EXPOSE 80

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]