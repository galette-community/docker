# Using PHP-Apache image
FROM php:8-apache

# Maintained by Hiob for Galette community
LABEL maintainer="Hiob <hello@hiob.fr>"

LABEL version="1.5.0"
LABEL description="PHP 8 / Apache 2 / Galette 0.9.5"

# Install dependencies
RUN a2enmod rewrite
RUN apt-get -y update && apt-get install -y \
  cron \
  wget \
  libfreetype6-dev \
  libicu-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libtidy-dev \
  tzdata
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
ENV GALETTE_VERSION 0.9.5

ENV GALETTE_CONFIG /var/www/galette/config
ENV GALETTE_DATA /var/www/galette/data
ENV GALETTE_INSTALL /var/www/galette
ENV GALETTE_WEBROOT /var/www/galette/webroot

ENV PLUGIN_EVENTS 1.4.0
ENV PLUGIN_MAPS 1.6.0
ENV PLUGIN_PAYPAL 1.9.0
ENV PLUGIN_STRIPE 0.0.2

#Timezone default Env
ENV TZ Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install Galette
RUN cd /usr/src; wget https://github.com/galette/galette/archive/refs/tags/${GALETTE_VERSION}.tar.gz
RUN cd /usr/src; tar xvf ${GALETTE_VERSION}.tar.gz; rm ${GALETTE_VERSION}.tar.gz; mv galette-${GALETTE_VERSION}/galette/* ${GALETTE_INSTALL}

# Install plugins
## Events
RUN cd ${GALETTE_INSTALL}/plugins; wget https://github.com/galette/plugin-events/archive/refs/tags/${PLUGIN_EVENTS}.tar.gz
RUN cd ${GALETTE_INSTALL}/plugins; tar xvf ${PLUGIN_EVENTS}.tar.gz; rm ${PLUGIN_EVENTS}.tar.gz; mv plugin-events-${PLUGIN_EVENTS} plugin-events

## Maps
RUN cd ${GALETTE_INSTALL}/plugins; wget https://github.com/galette/plugin-maps/archive/refs/tags/${PLUGIN_MAPS}.tar.gz
RUN cd ${GALETTE_INSTALL}/plugins; tar xvf ${PLUGIN_MAPS}.tar.gz; rm ${PLUGIN_MAPS}.tar.gz; mv plugin-maps-${PLUGIN_MAPS} plugin-maps

## Paypal
RUN cd ${GALETTE_INSTALL}/plugins; wget https://github.com/galette/plugin-paypal/archive/refs/tags/${PLUGIN_PAYPAL}.tar.gz
RUN cd ${GALETTE_INSTALL}/plugins; tar xvf ${PLUGIN_PAYPAL}.tar.gz; rm ${PLUGIN_PAYPAL}.tar.gz; mv plugin-paypal-${PLUGIN_PAYPAL} plugin-paypal

## Stripe
RUN cd ${GALETTE_INSTALL}/plugins; wget https://github.com/galette-community/plugin-stripe/archive/v${PLUGIN_STRIPE}.tar.gz
RUN cd ${GALETTE_INSTALL}/plugins; tar xvf v${PLUGIN_STRIPE}.tar.gz; rm v${PLUGIN_STRIPE}.tar.gz; mv plugin-stripe-${PLUGIN_STRIPE} galette-plugin-stripe


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
