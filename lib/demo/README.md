# Solidus Docker Demo
The Dockerfile in this folder is intended for demoing purposes, meaning that a
user can run an installation of Solidus using a Docker container.

## How to build the image
Make sure Docker is installed in your local and run the following command:

```shell
docker build -t solidusio/solidus-demo:latest -f lib/demo/Dockerfile .
```

## How to run the image
You can either run the image you built locally or run the official image pushed
in Dockerhub.

```shell
docker run --rm -it -p 3000:3000 solidusio/solidus-demo:latest
```

## How to push the image
If you want to push the image you can use the following command, just note that
this specific command will push the image to the official Solidus Dockerhub
account.

```shell
docker push solidusio/solidus-demo:latest
```