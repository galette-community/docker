![Docker Stars](https://img.shields.io/docker/stars/galette/galette.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/galette/galette.svg) ![Docker Automated](https://img.shields.io/docker/automated/galette/galette.svg)
# Galette using Docker

Current repository hosts sources of the [Galette docker image](https://hub.docker.com/repository/docker/galette/galette), created and maintained by [Galette Community](https://github.com/galette-community/).

## Contributing
If you want to contribute to containerized galette, take a look [here](./CONTRIBUTING.md).

## Features
* integrated plugins : [events](https://github.com/galette/plugin-events), [fullcard](https://github.com/galette/plugin-fullcard), [maps](https://github.com/galette/plugin-maps), [objectslend](https://github.com/galette/plugin-objectslend) and [paypal](https://github.com/galette/plugin-paypal)
* mount volume to keep persistent database settings (*config.inc.php*)
* keep data (images, logs, etc) persistent by mounting volumes
* enabling Log IP addresses behind a proxy (*optional*)
* customize your CSS (volume)
* user www-data instead of root
* a crontab will run `reminder.php` (with user www-data) every day at 8:30am to send reminder mail
* only webroot is exposed via Apache DocumentRoot and vhost
* you can use reverse proxy to access Galette by domain or subdomain

## How to use this image using docker command line
Galette has a really nice installer, that runs you through database setup and initial admin user creation. The installer creates a configuration files, which you will be interested in keeping on a volume outside the docker image, for reuse when you upgrade to a newer version.

Therefore it is really important that you follow this guide exactly.

If you are upgrading from an ealier version, you can skip the first step below.

1. Create an empty file `config.inc.php` which you will mount as a volume in the next step.
    - It is important that you create this file. You can also take a copy of [this](.example/config/config.inc.php), as the contents do not matter
2. Start a container with the version of galette you want (perhaps :latest) and the proper list of volumes, take note of the `config.inc.php` volume which is a file.
    ```
    docker run  -d -p 8080:80 --name galette
    -v  /path/to/config.inc.php:/var/www/galette/config/config.inc.php \
    -v  /path/to/data/attachments:/var/www/galette/data/attachments \
    -v  /path/to/data/cache:/var/www/galette/data/cache \
    -v  /path/to/data/files:/var/www/galette/data/files \
    -v  /path/to/data/logs:/var/www/galette/data/logs \
    -v  /path/to/data/photos:/var/www/galette/data/photos \
    -v ./path/to/data/templates_c:/var/www/galette/data/templates_c \
    galette/galette:latest
    ```
    Remember to replace `./path/to/` with your own path.

3. Run the installer: Open a browser to http://\<ip or server name\>:8080/installer.php, e.g. [http://localhost:8080/installer.php](http://localhost:8080/installer.php) and follow the instructions.
    - Remember your database details, as you will need them in this process.

    You're done!
    
    N.B.: You can check `config.inc.php` in container.

    `docker exec galette cat /var/www/galette/config/config.inc.php`

4. As a subsequent security precaution, you should delete the galette installation files. Replace `galette` with the actual container name, if you changed that in the commands above.

    `docker exec galette rm -r /var/www/galette/install`

5. Advanced configuration:

    Add the following volume to your container parameters to control logging of IP addresses behind a proxy, or to enable debugging mode. Read [here](https://doc.galette.eu/en/master/usermanual/avancee.html#log-ip-addresses-behind-a-proxy) for more info:

    `-v ./path/to/config/behavior.inc.php:/var/www/galette/config/behavior.inc.php`
    
    Add the folloing volume to your container parameters to enable custom styling via CSS. Read [here](https://doc.galette.eu/en/master/usermanual/avancee.html#adapt-to-your-graphical-chart) for more info:

    `v ./path/to/galette_local.css:/var/www/galette/webroot/themes/default/galette_local.css`

    Remember to replace `./path/to/` with your own path.

### Configure plugins
From the main page of galette, click the plugin icon and manage the built-in modules. You can disable/enable them an initialize their database configuration from the UI.

## How to use this image using Docker Compose
1. Copy [docker-compose.yml](.example/docker-compose.yml) to the folder, where you want to persist your configuration.
2. Create a `config` folder and an empty `config.inc.php` in that folder. Or copy the one from [here](.example/config/config.inc.php).
3. Launch with `docker-compose up -d`
4. Go to http://localhost:8080/installer.php and complete installation (database, etc)

You're done.

5. See above for deleting the install folder, advanced configuration and plugin configuration! In the docker compose example file, there are commented out lines for the behavior or css volumes.

## Reverse proxy
### Nginx

An [example of reverse proxy configuration for Nginx](.example/nginx/nginx.conf) is provided.
