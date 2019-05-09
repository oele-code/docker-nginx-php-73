FROM ubuntu:16.04

LABEL Author="Osmell Caicedo <@oele_co>"

RUN apt-get clean && apt-get -y update && apt-get install -y locales && locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' LC_ALL='en_US.UTF-8'

RUN apt-get update \
    && apt-get install -y vim curl zip unzip git nginx memcached software-properties-common supervisor sqlite3 libxrender1 libxext6 mysql-client \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update

RUN apt-get install -y php7.2-fpm php7.2-cli php7.2-gd php7.2-mysql \
       php7.2-imap php-memcached php7.2-mbstring php7.2-xml php7.2-curl \
       php7.2-sqlite3 php7.2-zip php7.2-pdo-dblib php7.2-bcmath php7.2-gmp

RUN apt-get install -y php5.6-fpm php5.6-cli php5.6-gd php5.6-mysql \
       php5.6-imap php5.6-memcached php5.6-mbstring php5.6-xml php5.6-curl \
       php5.6-sqlite3 php5.6-zip php5.6-pdo-dblib php5.6-bcmath

RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && mkdir /run/php

RUN update-ca-certificates;

RUN curl -fsSL https://get.docker.com -o get-docker.sh

RUN sh get-docker.sh

RUN apt-get remove -y --purge software-properties-common \
	&& apt-get -y autoremove \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& echo "daemon off;" >> /etc/nginx/nginx.conf


RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY default /etc/nginx/sites-available/default

COPY ./php/5.6/php-fpm.conf /etc/php/5.6/fpm/php-fpm.conf
COPY ./php/5.6/www.conf /etc/php/5.6/fpm/pool.d/www.conf

COPY ./php/7.2/php-fpm.conf /etc/php/7.2/fpm/php-fpm.conf
COPY ./php/7.2/www.conf /etc/php/7.2/fpm/pool.d/www.conf

RUN echo "<?php phpinfo(); ?>" > /var/www/html/index.php \
    && mkdir -p /var/www/ovy/public \
    && echo "<?php phpinfo(); ?>" > /var/www/ovy/public/index.php

EXPOSE 80

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]