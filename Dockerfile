# Using PHP-Apache image
FROM php:8-apache

# Maintained by Hiob for Galette community
MAINTAINER Hiob <hello@hiob.fr>

LABEL version="1.1.0"
LABEL description="PHP 8 / Apache 2 / Galette 0.9.4.2"

# Install dependencies
RUN a2enmod rewrite
RUN apt-get -y update && apt-get install -y \
  cron \
  wget \
  libfreetype6-dev \
  libicu-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libtidy-dev
RUN docker-php-ext-install -j$(nproc) tidy gettext intl mysqli pdo_mysql && \
  docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
  docker-php-ext-install -j$(nproc) gd

# Enabling apache vhost
COPY vhost.conf /etc/apache2/sites-available/vhost.conf
RUN sed -i 's/galette.localhost/galette.${HOSTNAME}/' /etc/apache2/sites-available/vhost.conf \
    && a2dissite * && a2ensite vhost.conf

# Changing DOCUMENT ROOT
RUN mkdir /var/www/galette
ENV APACHE_DOCUMENT_ROOT /var/www/galette

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf


# Galette ENV
ENV GALETTE_VERSION 0.9.4.2

ENV GALETTE_INSTALL /var/www/galette
ENV GALETTE_DATA /var/www/galette/data
ENV GALETTE_CONFIG /var/www/galette/config
ENV GALETTE_WEBROOT /var/www/galette/webroot

# Install Galette
RUN cd /usr/src; wget http://download.tuxfamily.org/galette/galette-${GALETTE_VERSION}.tar.bz2
RUN cd /usr/src; tar jxvf galette-${GALETTE_VERSION}.tar.bz2; mv galette-${GALETTE_VERSION}/galette/* ${GALETTE_INSTALL} ; rm galette-${GALETTE_VERSION}.tar.bz2

# Install plugins
## Events
RUN cd ${GALETTE_INSTALL}/plugins; wget https://download.tuxfamily.org/galette/plugins/galette-plugin-events-1.3.0.tar.bz2
RUN cd ${GALETTE_INSTALL}/plugins; tar jxvf galette-plugin-events-1.3.0.tar.bz2; rm galette-plugin-events-1.3.0.tar.bz2

## Maps
RUN cd ${GALETTE_INSTALL}/plugins; wget https://download.tuxfamily.org/galette/plugins/galette-plugin-maps-1.5.0.tar.bz2
RUN cd ${GALETTE_INSTALL}/plugins; tar jxvf galette-plugin-maps-1.5.0.tar.bz2; rm galette-plugin-maps-1.5.0.tar.bz2

## Paypal
RUN cd ${GALETTE_INSTALL}/plugins; wget https://download.tuxfamily.org/galette/plugins/galette-plugin-paypal-1.8.2.tar.bz2
RUN cd ${GALETTE_INSTALL}/plugins; tar jxvf galette-plugin-paypal-1.8.2.tar.bz2; rm galette-plugin-paypal-1.8.2.tar.bz2

## Stripe
RUN cd ${GALETTE_INSTALL}/plugins; wget https://github.com/galette-community/plugin-stripe/archive/v0.0.2.tar.gz
RUN cd ${GALETTE_INSTALL}/plugins; tar xvf v0.0.2.tar.gz; rm v0.0.2.tar.gz; mv plugin-stripe-0.0.2 galette-plugin-stripe


# Cron auto-reminder
## Copy galette-cron file to the cron.d directory
COPY galette-cron /etc/cron.d/galette-cron

## Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/galette-cron

## Apply cron job
RUN crontab /etc/cron.d/galette-cron

# Chown /var/www/galette
RUN chown -R www-data:www-data ${GALETTE_INSTALL}
RUN chmod -R 0755 ${GALETTE_DATA}

# Mount volumes
VOLUME $GALETTE_DATA
VOLUME $GALETTE_CONFIG
