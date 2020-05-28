![Docker Stars](https://img.shields.io/docker/stars/galette/galette.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/galette/galette.svg) ![Docker Automated](https://img.shields.io/docker/automated/galette/galette.svg) ![Docker Build](https://img.shields.io/docker/build/galette/galette.svg)

# Galette using Docker

## Maintained by: [Galette Community](https://github.com/galette-community/)

Current repository hosts sources of the [Galette docker image](https://hub.docker.com/repository/docker/galette/galette), created and maintained by [Galette Community](https://github.com/galette-community/).


## Features

* mount volume to keep persistent database settings (*config.inc.php*)
* keep data (images, logs, etc) persistent by mounting volume
* enabling Log IP addresses behind a proxy (*optional*)
* custom your CSS (volume)
* a crontab will run `reminder.php` every day at 8:30am to send reminder mail
* only webroot is exposed via Apache DocumentRoot and vhost
* you can use reverse proxy to access Galette by domain or subdomain

## How to use this image

### Run manually

#### First launch

run your docker container to install to connect Galette to your database server

```
docker run  -d -p 8080:80 --name galette \
galette/galette:latest
```
* go to localhost:8080 and complete installation (database, etc)
* stop container `docker container stop galette` and remove it `docker container rm galette`

Now your Galette database is created, to have a persistent MySQL/PostgreSQL configuration, you need to mount your `config.inc.php` as a volume

* create a `config.inc.php` file wherever you want containing the configuration copied above
* now run again your container with a persistent volume to your `config.inc.php`
```
docker run  -d -p 8080:80 --name galette
-v  /path/to/config.inc.php:/var/www/galette/config/config.inc.php \
-v  /path/to/data/attachments:/var/www/galette/data/attachments \
-v  /path/to/data/cache:/var/www/galette/data/cache \
-v  /path/to/data/files:/var/www/galette/data/files \
-v  /path/to/data/logs:/var/www/galette/data/logs \
-v  /path/to/data/photos:/var/www/galette/data/photos \
- ./data/templates_c:/var/www/galette/data/templates_c \
galette/galette:latest
```
You're done !


**N.B.:** You can check `config.inc.php` in container.
* in terminal, connect to container console `docker container exec -ti galette bash`
* and type `cat /var/www/galette/config/config.inc.php` to check your dabatase configuration
* exit from container console  : `exit`


## Using Docker Compose
An [example of docker-compose.yml](.example/docker-compose.yml) is provided.

#### First launch
* copy `docker-compose.yml` example wherever you want in a folder
* Edit your `docker-compose.yml` **without** a mounted volume (config.inc.php) and launch with `docker-compose up -d`
* go to localhost:8080 and complete installation (database, etc)
* stop and remove container : `docker-compose down`
* create a `config.inc.php` file wherever you want containing the configuration copied above
* edit `docker-compose.yml` and uncomment *volumes* section, make sure that your `/path/to/config.inc.php` is OK
* launch container with `docker-compose up -d`

You're done !


## Reverse proxy

### Nginx

An [example of reverse proxy configuration for Nginx](.example/nginx/nginx.conf) is provided.
