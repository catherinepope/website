---
layout: single
title: Using Docker Compose
permalink: /docker/docker-compose/
toc: true
---

## Overview

Docker Compose deploys and manages *multi-container applications* (microservices) on Docker nodes running in **single-engine** mode.

In contrast, Docker Swarm deploys and manages multi-container apps on Docker nodes running in **swarm mode**.

Docker Compose allows you to describe an entire app in a single declarative configuration file and deploy it with a single command.

Once the app is deployed, you can manage its entire lifecycle with a simple set of commands. And the configuration file can be stored in a VCS.

To check Docker Compose is installed, run: `docker-compose --version`. It should be installed by default with Docker Desktop on Mac and Windows.

## Creating Docker Compose Files

Docker Compose uses YAML files to define multi-service applications. You can also use JSON.

The default name for a Docker Compose YAML file is `docker-compose.yml`. You can also use the `-f` flag to specify custom filenames.

Here's an example of a Docker Compose file:

``` yaml

version: "3.8"
services:
  web-fe:
    build: .
    command: python app.py
    ports:
      - target: 5000
        published: 5000
    networks:
      - counter-net
    volumes:
      - type: volume
        source: counter-vol
        target: /code
  redis:
    image: "redis:alpine"
      networks:
        counter-net

networks:
  counter-net:

volumes:
  counter-vol:

```

The `version` key is mandatory. This defines the version of the Compose file format (i.e. the API), not the version of Docker Compose or Docker Engine.

The `services` key is where you define the different application microservices. In this case, there are two microservices: `web-fe` and `redis`.

The top-level `networks` key tells Docker to create new networks. By default, Compose creates [bridge networks](./../networking/#single-host-bridge-networks). These are single-host networks that can connect only containers on the same Docker host. You can use the driver property to specify different network types. For example:

``` yaml
networks:
  over-net:
  driver: overlay
  attachable: true
```

The top-level `volumes` key is where you tell Docker to create new volumes.

In the example above, the `services` section has two second-level keys:

- web-fe
- redis

Each of these defines a service (container) in the app. Within the definition of the `web-fe` service, you give Docker the following instructions:

- `build: .` - this tells Docker to build a new image using the instructions in the Dockerfile in the current directory (.). The newly built image is used in a later stage to create the container for this service.
- `command: python app.py` - this tells Docker to run a Python app called `app.py` as the main app in the container. This can also be specified in the Dockerfile, although you can override it here in the Compose file. The `app.py` file must exist in the image, and the image must contain Python. This is handled by the Dockerfile.
- `ports:` - tells Docker to map port 5000 inside the container (`-target`) to port 5000 on the host (`published`). Traffic sent to the Docker host on port 5000 is directed to port 5000 on the container. The app inside the container listens on port 5000.
- `networks:` - tells Docker which network to attach the service's container to. The network should already exist or be defined in the `networks` top-level key. If it's an overlay network, it needs to have the `attachable` flag.
- `volumes:` - tells Docker to mount the `counter-vol` volume (source:) to /code (target:) inside the container. The `counter-vol` needs to already exist, or be define in the `volumes` top-level key at the bottom of the file.

As both services are deployed to the same `counter-net` network, they will be able to resolve each other by name.

## Deploying an App with Compose

Compose uses the name of your directory as the project name. If your directory is called `counter-app`, all resources names are prepended with `counter-app_`.

The command to deploy an app is:

`docker-compose up &`

The ampersand forces Compose to output all messages to the terminal window.

You can add the `-d` flag to run the app in the background.

Once the app is built and running, you can use normal `docker` commands to view the images, containers, networks, and volumes created by Compose.

- docker volume ls
- docker network ls

## Managing an App with Compose

To stop an application, use `docker-compose down`.

This command doesn't delete any volumes. This is because volumes are intended to be long-term persistent data stores. Their lifecycle is entirely decoupled from the applications they serve.

Also, any images that were built or pulled as part of the `docker-compose up` operation will still be present on the system. This means future deployments of the app will be faster.

To see the current state of the app, use `docker-compose ps`.

![Output of docker-compose ps](./../../assets/images/docker-compose-ps.png)

Use `docker-compose top` to list the processes running inside of each service (container).

![Output of docker-compose top](./../../assets/images/docker-compose-top.png)

To stop a Compose app, use `docker-compose stop`. This command just stops the app's containers. The application definition remains on the system.

You can delete a stopped Compose app with `docker-compose rm`. This deletes the containers and networks the app is using, but doesn't delete volumes or images.

You can restart the app with the `docker-compose restart` command.

Use the `docker-compose down` command to stop and delete the app with a single command. Then only the images, volumes, and source code remain.

If the app's code resides on a Docker volume, this means we can make changes to file in the volume from outside the container. Those changes are then reflected immediately in the app.


