FROM ubuntu:xenial

LABEL Author="Osmell Caicedo <@oele_co>"

RUN apt-get clean && apt-get -y update && apt-get install -y locales --no-install-recommends \
      && locale-gen en_US.UTF-8 && rm -rf /var/lib/apt/lists/* \
ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' LC_ALL='en_US.UTF-8'

# Install tools
RUN apt-get update && apt-get install -y software-properties-common supervisor libxrender1 libxext6 \
       curl git nginx mysql-client --no-install-recommends \
       && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:jason.grammenos.agility/php

# Install php7.3
RUN apt-get update && apt-get install -y php7.3-fpm php7.3-cli php7.3-gd php7.3-mysql \
       php7.3-imap php7.3-mbstring php7.3-xml php7.3-curl \
       php7.3-zip php7.3-pdo-dblib php7.3-bcmath php7.3-ssh2 \
       php7.3-gmp php7.3-xdebug php7.3-sqlite php7.3-imagick --no-install-recommends \
       && rm -rf /var/lib/apt/lists/*

# Install php5.6
RUN apt-get update && apt-get install -y php5.6-fpm php5.6-cli php5.6-gd php5.6-mysql \
       php5.6-imap php5.6-mbstring php5.6-xml php5.6-curl \
       php5.6-zip php5.6-pdo-dblib php5.6-bcmath --no-install-recommends \
       && rm -rf /var/lib/apt/lists/*

# Install composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer --version=1.10.16 \
       && mkdir /run/php \
       && composer global require hirak/prestissimo

RUN update-ca-certificates;
RUN curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
RUN sh nodesource_setup.sh
RUN apt-get install -y nodejs build-essential --no-install-recommends
RUN curl -fsSL https://get.docker.com -o get-docker.sh
RUN sh get-docker.sh
RUN apt-get remove -y --purge software-properties-common \
	&& apt-get -y autoremove \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& echo "daemon off;" >> /etc/nginx/nginx.conf

# Default vhost
COPY default /etc/nginx/sites-available/default

# PHP 7.3 Configuration
COPY ./php/7.3/php-fpm.conf /etc/php/7.3/fpm/php-fpm.conf
COPY ./php/7.3/www.conf /etc/php/7.3/fpm/pool.d/www.conf
COPY ./php/7.3/xdebug.ini /etc/php/7.3/mods-available/xdebug.ini
COPY ./php/7.3/php.dev.ini /etc/php/7.3/fpm/conf.d/php.dev.ini

# PHP 5.6 Configuration
COPY ./php/5.6/php-fpm.conf /etc/php/5.6/fpm/php-fpm.conf
COPY ./php/5.6/www.conf /etc/php/5.6/fpm/pool.d/www.conf

# Default site files
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
RUN echo 'alias ams="a migrate:status"' >> ~/.bashrc
RUN echo 'alias aml="amr && am"' >> ~/.bashrc
RUN echo 'alias t="vendor/bin/phpunit --testdox"' >> ~/.bashrc
RUN echo 'alias t-f="t --filter"' >> ~/.bashrc
RUN echo 'alias d="a dusk --testdox"' >> ~/.bashrc
RUN echo 'alias d-f="d --filter"' >> ~/.bashrc