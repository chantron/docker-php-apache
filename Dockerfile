FROM php:7.0-apache

RUN apt-get update

RUN apt-get install -y \
    build-essential \
    pkg-config \
    git-core \
    autoconf \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libcurl4-openssl-dev \
    libpq-dev \
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
    chrpath

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
    pgsql \
    zip

# install memcached
COPY scripts/install-php-memcached.sh /install-php-memcached.sh
RUN bash /install-php-memcached.sh && rm /install-php-memcached.sh

# install imagick
COPY scripts/install-php-imagick.sh /install-php-imagick.sh
RUN bash /install-php-imagick.sh && rm /install-php-imagick.sh

# install composer
WORKDIR /tmp
RUN wget https://getcomposer.org/composer.phar
RUN mv composer.phar /bin/composer
RUN chmod 700 /bin/composer

# cleanup
RUN apt-get clean
RUN apt-get autoremove -y
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/src/*

# entrypoint/configuration scripts
COPY entrypoint /opt/entrypoint
COPY configure /opt/configure
RUN chmod 755 /opt/entrypoint
RUN chmod 755 /opt/configure

WORKDIR /var/www

RUN a2enmod rewrite

ENTRYPOINT ["/opt/entrypoint"]

CMD ["apache2-foreground"]
