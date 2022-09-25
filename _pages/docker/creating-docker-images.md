---
layout: single
title: Creating Docker Images
permalink: /docker/creating-docker-images/
toc: true
---

## Overview

With Docker, you can enjoy the benefits of a microservice architecture. Your key features are in small, isolated units that you can manage independently. That means you can test changes quickly. You’re not changing the monolith, only the containers running your feature. You can scale features up and down, and you can use different technologies to suit requirements.

First, you need to containerize your app.

## Containerizing an App

The process of containerizing an app:

1. Start with application code and dependencies.
2. Create a Dockerfile that describes your app, its dependencies, and how to run it.
3. Feed the Dockerfile into the `docker image build` command.
4. Push the new image to a registry (optional).
5. Run container from the image.

You can create an image from an existing container:

`docker container commit <container-name> <image-name:tag>`

Mostly, though, you'll be using a Dockerfile.

## Creating a Dockerfile

In Docker, the *Builder Pattern* is used to maintain two individual Dockerfiles for app development and production purposes.

Here's a simple example of a Dockerfile:

```
FROM alpine

LABEL maintainer="docker@catherinepope.com"

# Install Node and NPM
RUN apk add --update nodejs npm curl

# Copy app to /src
COPY . /src

WORKDIR /src

# Install dependencies
RUN  npm install

EXPOSE 8080

ENTRYPOINT ["node", "./app.js"]

```

`ARG` is the only instruction that can precede `FROM` in the Dockerfile. It is used to pass variables to the other instructions. For example:

```
ARG  CODE_VERSION=latest
FROM base:${CODE_VERSION}
CMD  /code/run-app

FROM extras:${CODE_VERSION}
CMD  /code/run-extras 
```

An `ARG` declared before a `FROM` is outside of a build stage, so it can't be used in any instruction after a `FROM`. To use the default value of an ARG declared before the first FROM use an ARG instruction without a value inside of a build stage:

```
ARG VERSION=latest
FROM busybox:$VERSION
ARG VERSION
RUN echo $VERSION > image_version
```

Unlike `ENV`s, `ARG`s are not persisted to run-time.

`FROM` is the base layer of the image. If it's a Linux app, this must specify a Linux-based image. The base layer should be small, and preferably from an official source. If you want to create a new image with no parent image, use `FROM scratch`.

`LABEL` is a key-value pair and a way of adding custom metadata to an image.

`RUN` runs a command and creates a new layer above the base layer (typically downloading and installing software, such as Node).

`CMD`: there are several difference between `CMD` and `RUN`:

- The `CMD` is executed when you run a container from your image. The `RUN` instruction is executed during the build time of the image.
- **You can have only one `CMD` instruction in a Dockerfile**. If you add more, only the last one takes effect. You can have as many `RUN` instructions as you need in the same Dockerfile.
- You can add a health check to the CMD instruction, for example, `HEALTHCHECK CMD curl --fail http://localhost/health || exit 1`, which tells the Docker engine to kill the container with exit status 1 if the container health fails.
- The `CMD` syntax uses this form [“param”, param”, “param”] when used in conjunction with the `ENTRYPOINT` instruction. It should be in the following form CMD [“executable”, "param1”, “param2”…] if used by itself.

Example: `CMD "echo" "Hello World!"`

`COPY` creates another new layer and copies the application and dependency files from the build context.

`ADD` is similar to `COPY`, but there are some significant differences:

- `ADD` supports URL handling, `COPY` doesn't.
- `ADD` supports extra features, such as local-only tar extraction.
- `ADD` supports regular expression handling, `COPY` doesn't.
  
`WORKDIR` sets the working directory inside the image filesystem for the rest of the instructions in the file. This instruction doesn't create a new image layer.

`RUN` creates a new layer and uses npm (installed in previous instruction) to install application dependencies listed in the package.json file in the build context. It runs within the context of the WORKDIR set in the previous instruction.

`EXPOSE` exposes a web service on TCP port 8080. This is added as image metadata, not as a layer.

`ENTRYPOINT` sets the main application that the image (container) should run. It should be defined when using the container as an executable.`ENTRYPOINT` overrides the CMD instruction and CMD's parameters are used as arguments to `ENTRYPOINT`, e.g:

```
CMD "This is my container"
ENTRYPOINT echo
```

Using the shell format, the container main process, as defined by the `ENTRYPOINT` instruction, cannot be modified with arguments.

`ENV` sets the environment variables in the container, e.g. setting a log path other than the Docker Engine default, e.g. `ENV log_dir /var/log`. Environment variables can be used at both build-time (for subsequent build steps) and at run-time.

`USER` By default, the Docker engine sets the container’s user to root, which can be harmful. Actually, no one gives root privileges like that. Therefore, you should set a user ID and username for your container, e.g. `USER 75 engy`.

`VOLUME` creates a directory in the image filesystem, which can later be used for mounting volumes from the Docker host or the other containers.

If an instruction is adding content, such as files and programs to the image, it creates a new layer. If it is adding instructions, it creates metadata.

Docker images may be packaged with a default set of configuration values for the application, but you should be able to provide different configuration settings when you run a container.

### Understanding the Interaction Between CMD and ENTRYPOINT

Both `CMD` and `ENTRYPOINT` instructions define what command gets executed when running a container. There are few rules that describe their co-operation:

1. Dockerfile should specify at least one `CMD` or `ENTRYPOINT` command.

2. `ENTRYPOINT` should be defined when using the container as an executable.

3. `CMD` should be used as a way of defining default arguments for an ENTRYPOINT command or for executing an ad-hoc command in a container.

4. `CMD` is overridden when running the container with alternative arguments from the `docker run` command.

The table below shows what command is executed for different `ENTRYPOINT` / `CMD` combinations:


|                            | No ENTRYPOINT              | ENTRYPOINT exec_entry p1_entry | ENTRYPOINT [“exec_entry”, “p1_entry”]          |   |   |   |   |   |   |
|----------------------------|----------------------------|--------------------------------|------------------------------------------------|---|---|---|---|---|---|
| No CMD                     | error, not allowed         | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry                            |   |   |   |   |   |   |
| CMD [“exec_cmd”, “p1_cmd”] | exec_cmd p1_cmd            | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry exec_cmd p1_cmd            |   |   |   |   |   |   |
| CMD [“p1_cmd”, “p2_cmd”]   | p1_cmd p2_cmd              | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry p1_cmd p2_cmd              |   |   |   |   |   |   |
| CMD exec_cmd p1_cmd        | /bin/sh -c exec_cmd p1_cmd | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry /bin/sh -c exec_cmd p1_cmd |   |   |   |   |   |   |       

## Building Images

To build an image with a Dockerfile:

`docker image build -t <image-name>:<tag> .`

To check the image is created:

`docker image ls`

To see the instructions that were used to build the image:

`docker history <image-name>`

To inspect the layers that were created:

`docker image inspect <image-name>`

### Triggering an Image Build from a Git Repo

You can also build a Docker image from a git repo by providing the URL. For example, this command build the image from a directory called `docker` in a branch called `container`:

`docker build https://github.com/docker/rootfs.git#container:docker`

The commit history is not preserved.

### Optimizing Images

Dockerfiles should be optimized so the instructions are ordered by how frequently they change: instructions that are unlikely to change at the start of the Dockerfile, and instructions most likely to change at the end. 

Docker assumes the layers in a Docker image follow a defined sequence. If you change a layer in the middle of that sequence, Docker doesn’t assume it can reuse the later layers in the sequence.

Ideally, most builds should only need to execute the last instruction, using the cache for everything else. That saves time, disk space, and network bandwidth when you start sharing your images.

To check how much disk space Docker is using, run:

`docker system df`

And you can clear image layers and the build cache with:

`docker system prune`

### Using Multi-Stage Builds

Every `RUN` instruction adds a new layer. Consequently, it's best practice to include multiple commands as part of a single `RUN` instruction using `&&` and `\` line breaks.

It's even better to remove stuff you don't need, e.g. installation files, once you've finished with them.

```
FROM node:latest AS storefront
WORKDIR /usr/src/atsea/app/react-app
COPY react-app .
RUN npm install
RUN npm run build

FROM maven:latest AS appserver
WORKDIR /usr/src/atsea
COPY pom.xml .
RUN mvn -B -f pom.xml -s /usr/share/maven/ref/settings-docker.xml dependency:resolve
COPY . .
RUN mvn -B -s /usr/share/maven/ref/settings-docker.xml package -DskipTests

FROM java:8-jdk-alpine
RUN adduser -Dh /home/gordon gordon
WORKDIR /static
COPY --from=storefront /usr/src/atsea/app/react-app/build/ .
WORKDIR /app
COPY --from=appserver /usr/src/atsea/target/AtSea-0.0.1-SNAPSHOT.jar .
ENTRYPOINT ["java", "-jar", "/app/AtSea-0.0.1-SNAPSHOT.jar"]
CMD ["--spring.profiles.active=postgres"]
```

The example above includes three `FROM` instructions, each constituting a distinct build stage. They're numbered from the top, starting at 0. You can also give each stage a friendly name.

In this example, stage 0 is called `storefront`. This stage pulls the `node:latest` image and contains lots of build stuff.

Stage 1, called `appserver` pulls the `maven:latest` image and adds lots of build tools. There's not much production code yet.

Stage 2, called `production`, pulls the `java:9-jdk-alpine` image. It copies in some app code produced by the `storefront` and `appserver` stages.

`COPY --from` instructions are used to copy only production related application code from the images built by the previous stage. They don't copy build artifacts that aren't needed for production.

If you run `docker image ls`, you'll see a list of images pulled and created by the build operation. You should see that the final image - `multi:stage` - is significantly smaller than the other images that were pulled. This is because it's based on the much smaller `java:9-jdk-alpine` image and contains only the production-related app files from the previous stages.

The `docker image build` process iterates through a Docker file one line at a time, starting from the top. For each instruction, Docker looks to see whether it already has an image layer for that instruction in its cache. If it does, this is a *cache hit* and it uses that layer; if it doesn't, that's a *cache miss* and it builds a new layer from the instruction. Of course, cache hits can greatly accelerate the build process.

As soon as any instruction results in a cache miss, the cache is no longer used for the remainder of the build. This is important for how you write your Dockerfiles: *place instructions that are likely to invalidate the cache towards the end of the file*. This means a cache miss won't occur until the later stages of the build, allowing the build to benefit as much as possible from the cache.

You can force the build process to ignore the entire cache by passing the `--no-cache=true` flag to the `docker image build` command.

`COPY` and `ADD` instructions include steps to ensure that the content copies to the image hasn't changed since the last build. Docker performs a checksum against each file copies and compares it to a checksum of the same file in the cached layer. If the checksums don't match, the cache is invalidated and a new layer is built.

If you're building Linux images and using the apt package manager, you should use the `no-install-recommends` flag with the `apt-get install command` - this ensures apt installs only main dependencies and not recommended or suggested packages.

#### Stopping at a Specific Build Stage

When you build your image, you don't necessarily need to build the entire Dockerfile. You can specify a *target build stage*. The following command stops at a stage named `builder`:

`docker build --target builder -t <repo-name>/<image-name:tag> .`

### Merging a Docker Image to a Single Layer

Although this process isn't officially supported by Docker, it does pop up in the exam. Here's how to merge a Docker image into a single layer:

- Run a container from the image.
- Export the container to an archive using `docker export`.
- Import the archive as a new image using `docker import`.

## Backing Up Docker Images

The `docker save` command saves one or more images to a tar archive which contains all the parents layers, tags, and versions. For example:

```sh
docker save busybox > busybox.tar
```

The backed up image can be restored with the `docker load` command.

## Creating Containers without Running Them

The `docker container create` or `docker create` command creates a new container from the specified image, without starting it. You can then use the `docker container start` or `docker start` command to start the container at any point.

This is useful when you want to set up a container configuration ahead of time so that it is ready to start when you need it. The initial status of the new container is `created`.
