# Using PHP-Apache image
FROM php:8.2-apache

# Maintained by GrasDK for Galette community
LABEL maintainer="GrasDK"
# @author Hiob
# @author GrasDK

LABEL phpversion="8.2"
ARG galetteversion="1.0.3"

## Plugins versions
ARG plugin_auto_version="2.0.0"
ARG plugin_events_version="2.0.0"
ARG plugin_fullcard_version="2.0.0"
ARG plugin_maps_version="2.0.0"
ARG plugin_objectslend_version="2.0.0"
ARG plugin_paypal_version="2.0.0"

LABEL version=$galetteversion
LABEL description="PHP $phpversion / Apache 2 / Galette $galetteversion"

LABEL org.opencontainers.image.source=https://github.com/galette-community/docker
LABEL org.opencontainers.image.description="Galette is a membership management web application towards non profit organizations."
LABEL org.opencontainers.image.licenses=GPL-3.0-or-later

ARG main_package_url="https://galette.eu/download/"
ARG plugin_package_url="https://galette.eu/download/plugins/"
#ARG main_package_url="https://download.tuxfamily.org/galette/"
#ARG plugin_package_url="https://download.tuxfamily.org/galette/plugins/"

# Install APT dependencies
RUN a2enmod rewrite
RUN apt-get -y update \
  && apt-get install --no-install-recommends -y \
  cron \
  wget \
  libfreetype6-dev \
  libicu-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libtidy-dev \
  tzdata \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install, Configure and Enable PHP extensions  
RUN docker-php-ext-install "-j$(nproc)" tidy gettext intl && \
  docker-php-ext-install mysqli pdo pdo_mysql && \
  docker-php-ext-enable mysqli && \
  docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
  docker-php-ext-install "-j$(nproc)" gd 
RUN apachectl restart

# Enabling apache vhost
COPY vhost.conf /etc/apache2/sites-available/vhost.conf
RUN sed -i "s/galette.localhost/galette.${HOSTNAME}/" /etc/apache2/sites-available/vhost.conf \
    && a2dissite -- * && a2ensite vhost.conf

# ENVIRONMENT VARIABLES
## Galette version
ENV GALETTE_VERSION=$galetteversion

## Galette ENV
ENV GALETTE_CONFIG /var/www/galette/config
ENV GALETTE_DATA /var/www/galette/data
ENV GALETTE_INSTALL /var/www/galette
ENV GALETTE_WEBROOT /var/www/galette/webroot
ENV RM_INSTALL_FOLDER 0

# Changing DOCUMENT ROOT
RUN mkdir $GALETTE_INSTALL
ENV APACHE_DOCUMENT_ROOT $GALETTE_INSTALL

RUN sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf \
 && sed -ri -e "s!/var/www/!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

## Timezone
ENV TZ Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Installation Galette and plugins
## Galette
WORKDIR /usr/src
RUN wget --progress=dot:giga ${main_package_url}galette-${GALETTE_VERSION}.tar.bz2
RUN tar jxvf galette-${GALETTE_VERSION}.tar.bz2; mv galette-${GALETTE_VERSION}/galette/* ${GALETTE_INSTALL} ; rm galette-${GALETTE_VERSION}.tar.bz2

## Official plugins
WORKDIR ${GALETTE_INSTALL}/plugins
### Auto
RUN wget --progress=dot:giga ${plugin_package_url}galette-plugin-auto-${plugin_auto_version}.tar.bz2
RUN tar jxvf galette-plugin-auto-${plugin_auto_version}.tar.bz2; rm galette-plugin-auto-${plugin_auto_version}.tar.bz2; mv galette-plugin-auto-${plugin_auto_version} plugin-auto

### Events
RUN wget --progress=dot:giga ${plugin_package_url}galette-plugin-events-${plugin_events_version}.tar.bz2
RUN tar jxvf galette-plugin-events-${plugin_events_version}.tar.bz2; rm galette-plugin-events-${plugin_events_version}.tar.bz2; mv galette-plugin-events-${plugin_events_version} plugin-events

### FullCard
RUN wget --progress=dot:giga ${plugin_package_url}galette-plugin-fullcard-${plugin_fullcard_version}.tar.bz2
RUN tar jxvf galette-plugin-fullcard-${plugin_fullcard_version}.tar.bz2; rm galette-plugin-fullcard-${plugin_fullcard_version}.tar.bz2; mv galette-plugin-fullcard-${plugin_fullcard_version} plugin-fullcard

### Maps
RUN wget --progress=dot:giga ${plugin_package_url}galette-plugin-maps-${plugin_maps_version}.tar.bz2
RUN tar jxvf galette-plugin-maps-${plugin_maps_version}.tar.bz2; rm galette-plugin-maps-${plugin_maps_version}.tar.bz2; mv galette-plugin-maps-${plugin_maps_version} plugin-maps

### ObjectsLend
RUN wget --progress=dot:giga ${plugin_package_url}galette-plugin-objectslend-${plugin_objectslend_version}.tar.bz2
RUN tar jxvf galette-plugin-objectslend-${plugin_objectslend_version}.tar.bz2; rm galette-plugin-objectslend-${plugin_objectslend_version}.tar.bz2; mv galette-plugin-objectslend-${plugin_objectslend_version} plugin-objectslend

### Paypal
RUN wget --progress=dot:giga ${plugin_package_url}galette-plugin-paypal-${plugin_paypal_version}.tar.bz2
RUN tar jxvf galette-plugin-paypal-${plugin_paypal_version}.tar.bz2; rm galette-plugin-paypal-${plugin_paypal_version}.tar.bz2; mv galette-plugin-paypal-${plugin_paypal_version} plugin-paypal

# CRON Auto-Reminder
## Copy galette-cron file to the cron.d directory
COPY galette-cron /etc/cron.d/galette-cron

## Give execution rights on the cron job
## Apply cron job
# Create the log file to be able to run tail
RUN chmod 0644 /etc/cron.d/galette-cron \
 && crontab -u www-data /etc/cron.d/galette-cron \ 
 && touch /var/log/cron.log

# Run the command on container startup
CMD ["cron", "tail -f /var/log/cron.log"]

# Chown /var/www/galette
RUN chown -R www-data:www-data $GALETTE_INSTALL \
 && chmod -R 0755 $GALETTE_DATA

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