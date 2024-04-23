# Galette Docker project
Building and maintaining this project is solely about the containerization of the finished Galette packages. If you want to contribute to Galette itself, take a look [here](https://galette.eu/site/contribute/). 

## Prerequisites
- `docker` is installed in your development environment.
- `dockerd` the docker deamon is installed (and [started](https://docs.docker.com/config/daemon/start/))
- `buildx` is installed in your development environment.

Although it's possible to build packages without `dockerd` running, using [`buildah`](https://buildah.io/), the focus here is on [`buildx`](https://docs.docker.com/reference/cli/docker/buildx/). You're welcome to contribute with instructions for `buildah`.

## Linting
1. Start the docker daemon if it's not already started: `sudo dockerd`
2. Run hadolint (containerized): `docker run --rm -i -v ./.config/hadolint.yml:/.config/hadolint.yaml hadolint/hadolint < Dockerfile`
3. Fix errors and warnings or add them to ignore list of the [hadolint configuration file](./.config/hadolint.yml) if there is a good reason for that. Read more [here](https://github.com/hadolint/hadolint).

## Building the docker image locally
1. Start the docker daemon if it's not already started: `sudo dockerd`
2. Run the build command: `docker buildx build -t galette-local .`
    * replace `galette-local` with any name you would like to give your local image

## Running the docker image locally
1. Follow the same steps as in [How to use this image](./README.md#How-to-use-this-image), replacing the image name `galette/galette:latest` with your local container name, e.g. `galette-local`.
