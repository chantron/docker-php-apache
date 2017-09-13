# build from php 7.0
FROM php:7-apache

# install supporting packages
RUN apt-get update && apt-get install -y --fix-missing \
    build-essential \
    pkg-config \
    git-core \
    autoconf \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libcurl4-openssl-dev \
    libpq-dev \
    libpspell-dev \
    libmemcached-dev \
    libmemcached11 \
    libsqlite3-dev \
    libmagickwand-dev \
    imagemagick \
    subversion \
    python \
    g++ \
    curl \
    vim \
    wget \
    netcat \
    chrpath \
    sudo

# install officially supported php extensions
RUN docker-php-ext-install \
    iconv \
    mcrypt \
    opcache \
    curl \
    gd \
    mysqli \
    pdo \
    pdo_pgsql \
    pdo_mysql \
    pdo_sqlite \
    pspell \
    pgsql \
    soap \
    zip

# install memcached extension
COPY scripts/install-php-memcached.sh /install-php-memcached.sh
RUN bash /install-php-memcached.sh && rm /install-php-memcached.sh

# install imagick extension
COPY scripts/install-php-imagick.sh /install-php-imagick.sh
RUN bash /install-php-imagick.sh && rm /install-php-imagick.sh

# install redis / xdebug extensions
RUN pecl install redis xdebug
RUN docker-php-ext-enable \
    redis \
    xdebug

# cleanup apt
RUN apt-get clean
RUN apt-get autoremove -y
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/src/*

# enable apache modules
RUN a2enmod rewrite headers cache cache_disk expires ssl

# install composer
WORKDIR /tmp
RUN wget https://getcomposer.org/composer.phar
RUN mv composer.phar /bin/composer
RUN chmod 755 /bin/composer

# entrypoint/configuration scripts
COPY entrypoint /opt/entrypoint
COPY configure /opt/configure
RUN chmod 755 /opt/entrypoint
RUN chmod 755 /opt/configure

# set working directory
WORKDIR /var/www

# add and run as docker user
RUN groupadd docker
RUN useradd docker -s /bin/bash -m -g docker
RUN usermod -aG www-data docker
RUN usermod -aG sudo docker
RUN echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# give docker user permission to run composer
RUN chown docker:docker /bin/composer

# run comtainer as docker user
USER docker

# copy php.ini
COPY php.ini /usr/local/etc/php/conf.d

# entrypoint/command
ENTRYPOINT ["/opt/entrypoint"]
CMD ["sudo", "-E", "apache2-foreground"]
