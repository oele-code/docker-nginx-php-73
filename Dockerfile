FROM ubuntu:16.04

LABEL Author="Osmell Caicedo <@oele_co>"

RUN apt-get clean && apt-get -y update && apt-get install -y locales && locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' LC_ALL='en_US.UTF-8'

# Install tools
RUN apt-get update \
       && apt-get install -y  software-properties-common supervisor sqlite3 libxrender1 libxext6 \
       wget vim curl zip unzip git nginx memcached mysql-client \
       && add-apt-repository -y ppa:ondrej/php \
       && apt-get update

# Install php7.3
RUN apt-get install -y php7.3-fpm php7.3-cli php7.3-gd php7.3-mysql \
       php7.3-imap php-memcached php7.3-mbstring php7.3-xml php7.3-curl \
       php7.3-sqlite3 php7.3-zip php7.3-pdo-dblib php7.3-bcmath php7.3-ssh2 \
       php7.3-gmp php7.3-xdebug php7.3-sqlite \
       && apt-get update

# Install Xdebug
RUN echo "xdebug.remote_enable=1" >> /etc/php/7.3/mods-available/xdebug.ini \
       && echo "xdebug.remote_host=docker.for.mac.localhost" >> /etc/php/7.3/mods-available/xdebug.ini \
       && echo "xdebug.remote_connect_back=0" >> /etc/php/7.3/mods-available/xdebug.ini \
       && echo "xdebug.remote_autostart=1" >> /etc/php/7.3/mods-available/xdebug.ini \
       && echo "xdebug.remote_connect_back=0" >> /etc/php/7.3/mods-available/xdebug.ini \
       && echo "xdebug.remote_handler=dbgp" >> /etc/php/7.3/mods-available/xdebug.ini \
       && echo "xdebug.max_nesting_level=250" >> /etc/php/7.3/mods-available/xdebug.ini

# Install php5.6
RUN apt-get install -y php5.6-fpm php5.6-cli php5.6-gd php5.6-mysql \
       php5.6-imap php5.6-memcached php5.6-mbstring php5.6-xml php5.6-curl \
       php5.6-sqlite3 php5.6-zip php5.6-pdo-dblib php5.6-bcmath \
       && apt-get update

# Install composer
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

COPY ./php/7.3/php-fpm.conf /etc/php/7.3/fpm/php-fpm.conf
COPY ./php/7.3/www.conf /etc/php/7.3/fpm/pool.d/www.conf

RUN echo "<?php phpinfo(); ?>" > /var/www/html/index.php \
    && mkdir -p /var/www/ovy/public \
    && echo "<?php phpinfo(); ?>" > /var/www/ovy/public/index.php

EXPOSE 80

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]

RUN echo 'alias c="clear"' >> ~/.bashrc
RUN echo 'alias a="php artisan"' >> ~/.bashrc
RUN echo 'alias am="a migrate"' >> ~/.bashrc
RUN echo 'alias amr="a migrate:rollback"' >> ~/.bashrc
RUN echo 'alias aml="amr && am"' >> ~/.bashrc
RUN echo 'alias t="vendor/bin/phpunit"' >> ~/.bashrc
RUN echo 'alias t-f="t --filter"' >> ~/.bashrc
RUN echo 'alias t-d="t --testdox"' >> ~/.bashrc
RUN echo 'alias t-d-f="td --filter"' >> ~/.bashrc
RUN echo 'alias d="a dusk"' >> ~/.bashrc
RUN echo 'alias d-f="d --filter"' >> ~/.bashrc
RUN echo 'alias d-d="d --testdox"' >> ~/.bashrc
RUN echo 'alias d-d-f="d-d --filter"' >> ~/.bashrc