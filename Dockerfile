# Using PHP-Apache image
FROM php:8.0-apache

# Maintained by Hiob for Galette community
LABEL maintainer="Hiob <hello@hiob.fr>"

LABEL version="0.9.6"
LABEL description="PHP 8.0 / Apache 2 / Galette 0.9.6"

# Install APT dependencies
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

# Install, Configure and Enable PHP extensions  
RUN docker-php-ext-install -j$(nproc) tidy gettext intl && \
  docker-php-ext-install mysqli pdo pdo_mysql && \
  docker-php-ext-enable mysqli && \
  docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
  docker-php-ext-install -j$(nproc) gd 
RUN apachectl restart

# Enabling apache vhost
COPY vhost.conf /etc/apache2/sites-available/vhost.conf
RUN sed -i 's/galette.localhost/galette.${HOSTNAME}/' /etc/apache2/sites-available/vhost.conf \
    && a2dissite * && a2ensite vhost.conf

# ENVIRONMENT VARIABLES
## Galette version
ENV GALETTE_VERSION 0.9.6

## Galette ENV
ENV GALETTE_CONFIG /var/www/galette/config
ENV GALETTE_DATA /var/www/galette/data
ENV GALETTE_INSTALL /var/www/galette
ENV GALETTE_WEBROOT /var/www/galette/webroot
ENV RM_INSTALL_FOLDER 0

## Plugins versions
ENV PLUGIN_AUTO 1.8.0
ENV PLUGIN_EVENTS 1.5.0
ENV PLUGIN_FULLCARD 1.8.2
ENV PLUGIN_MAPS 1.7.0
ENV PLUGIN_OBJECTSLEND 1.2.0
ENV PLUGIN_PAYPAL 1.10.0

# Changing DOCUMENT ROOT
RUN mkdir $GALETTE_INSTALL
ENV APACHE_DOCUMENT_ROOT $GALETTE_INSTALL

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

## Timezone
ENV TZ Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Installation Galette + Plugins
## Galette
RUN cd /usr/src; wget https://download.tuxfamily.org/galette/galette-${GALETTE_VERSION}.tar.bz2
RUN cd /usr/src; tar jxvf galette-${GALETTE_VERSION}.tar.bz2; mv galette-${GALETTE_VERSION}/galette/* ${GALETTE_INSTALL} ; rm galette-${GALETTE_VERSION}.tar.bz2

# Install official plugins
## Auto
RUN cd ${GALETTE_INSTALL}/plugins; wget https://download.tuxfamily.org/galette/plugins/galette-plugin-auto-${PLUGIN_AUTO}.tar.bz2
RUN cd ${GALETTE_INSTALL}/plugins; tar jxvf galette-plugin-auto-${PLUGIN_AUTO}.tar.bz2; rm galette-plugin-auto-${PLUGIN_AUTO}.tar.bz2; mv galette-plugin-auto-${PLUGIN_AUTO} plugin-auto

## Events
RUN cd ${GALETTE_INSTALL}/plugins; wget https://download.tuxfamily.org/galette/plugins/galette-plugin-events-${PLUGIN_EVENTS}.tar.bz2
RUN cd ${GALETTE_INSTALL}/plugins; tar jxvf galette-plugin-events-${PLUGIN_EVENTS}.tar.bz2; rm galette-plugin-events-${PLUGIN_EVENTS}.tar.bz2; mv galette-plugin-events-${PLUGIN_EVENTS} plugin-events

## FullCard
RUN cd ${GALETTE_INSTALL}/plugins; wget https://download.tuxfamily.org/galette/plugins/galette-plugin-fullcard-${PLUGIN_FULLCARD}.tar.bz2
RUN cd ${GALETTE_INSTALL}/plugins; tar jxvf galette-plugin-fullcard-${PLUGIN_FULLCARD}.tar.bz2; rm galette-plugin-fullcard-${PLUGIN_FULLCARD}.tar.bz2; mv galette-plugin-fullcard-${PLUGIN_FULLCARD} plugin-fullcard

## Maps
RUN cd ${GALETTE_INSTALL}/plugins; wget https://download.tuxfamily.org/galette/plugins/galette-plugin-maps-${PLUGIN_MAPS}.tar.bz2
RUN cd ${GALETTE_INSTALL}/plugins; tar jxvf galette-plugin-maps-${PLUGIN_MAPS}.tar.bz2; rm galette-plugin-maps-${PLUGIN_MAPS}.tar.bz2; mv galette-plugin-maps-${PLUGIN_MAPS} plugin-maps

## ObjectsLend
RUN cd ${GALETTE_INSTALL}/plugins; wget https://download.tuxfamily.org/galette/plugins/galette-plugin-objectslend-${PLUGIN_OBJECTSLEND}.tar.bz2
RUN cd ${GALETTE_INSTALL}/plugins; tar jxvf galette-plugin-objectslend-${PLUGIN_OBJECTSLEND}.tar.bz2; rm galette-plugin-objectslend-${PLUGIN_OBJECTSLEND}.tar.bz2; mv galette-plugin-objectslend-${PLUGIN_OBJECTSLEND} plugin-objectslend

## Paypal
RUN cd ${GALETTE_INSTALL}/plugins; wget https://download.tuxfamily.org/galette/plugins/galette-plugin-paypal-${PLUGIN_PAYPAL}.tar.bz2
RUN cd ${GALETTE_INSTALL}/plugins; tar jxvf galette-plugin-paypal-${PLUGIN_PAYPAL}.tar.bz2; rm galette-plugin-paypal-${PLUGIN_PAYPAL}.tar.bz2; mv galette-plugin-paypal-${PLUGIN_PAYPAL} plugin-paypal

# CRON Auto-Reminder
## Copy galette-cron file to the cron.d directory
COPY galette-cron /etc/cron.d/galette-cron

## Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/galette-cron

## Apply cron job
RUN crontab -u www-data /etc/cron.d/galette-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log

# Chown /var/www/galette
RUN chown -R www-data:www-data $GALETTE_INSTALL
RUN chmod -R 0755 $GALETTE_DATA

# Mount volumes
VOLUME $GALETTE_DATA
VOLUME $GALETTE_CONFIG

# Working directory
WORKDIR $GALETTE_INSTALL

# Entrypoint
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod -v +x /entrypoint.sh
USER www-data:www-data
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]

