# Using PHP-Apache image
FROM galette/galette:1.0.2
USER root
RUN apt-get -y update \
  && apt-get install --no-install-recommends -y \
  mariadb-server=1:10.11* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
ENV MYSQL_ROOT_PASSWORD=myrootpassword
ENV MYSQL_DATABASE=galette
ENV MYSQL_USER=galette
ENV MYSQL_PASSWORD=galette_pass
ENV MYSQL_PORT=3306
RUN mkdir /run/mysqld/
USER mysql:mysql
CMD ["mysqld_safe"]
USER www-data:www-data
