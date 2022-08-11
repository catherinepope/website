---
layout: single
title: Docker Stacks
permalink: /docker/docker-stacks/
toc: true
---

## Overview

Stacks are groups of interrelated services that share dependencies and can be scaled together.

Stacks simplify application management by providing:

- desired state
- rolling updates
- scaling operations
- health checks

Define the desired state of your app in a *Compose* file, then deploy and manage it with the `docker stack` command.

The Compose file includes the entire stack of microservices that comprise the app. It also includes all the volumes, networks, secrets, and other infrastructure required by the app.

Stacks build on top of Docker Swarm, so you get all those security and advanced features.

Containers --> Services --> Stacks

## Creating a Stack File

At the highest level, the Stack file defines 4 top-level keys:

- `version:` - version of Compose file format (3 or higher)
- `services:` - stack of services that comprise the app
- `networks:` - required networks
- `secrets:` - secrets used

Here's an example:

``` yaml
version: "3.2"

services:
  reverse_proxy:
    image: dockersamples/atseasampleshopapp_reverse_proxy
    ports:
      - "80:80"
      - "443:443"
    secrets:
      - source: revprox_cert
        target: revprox_cert
      - source: revprox_key
        target: revprox_key
    networks:
      - front-tier

  database:
    image: dockersamples/atsea_db
    environment:
      POSTGRES_USER: gordonuser
      POSTGRES_DB_PASSWORD_FILE: /run/secrets/postgres_password
      POSTGRES_DB: atsea
    networks:
      - back-tier
    secrets:
      - postgres_password
    deploy:
      placement:
        constraints:
          - 'node.role == worker'

  appserver:
    image: dockersamples/atsea_app
    networks:
      - front-tier
      - back-tier
      - payment
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
        failure_action: rollback
      placement:
        constraints:
          - 'node.role == worker'
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
    secrets:
      - postgres_password

  visualizer:
    image: dockersamples/visualizer:stable
    ports:
      - "8001:8080"
    stop_grace_period: 1m30s
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    deploy:
      update_config:
        failure_action: rollback
      placement:
        constraints:
          - 'node.role == manager'

  payment_gateway:
    image: dockersamples/atseasampleshopapp_payment_gateway
    secrets:
      - source: staging_token
        target: payment_token
    networks:
      - payment
    deploy:
      update_config:
        failure_action: rollback
      placement:
        constraints:
          - 'node.role == worker'
          - 'node.labels.pcidss == yes'

networks:
  front-tier:
  back-tier:
  payment:
    driver: overlay
    driver_opts:
      encrypted: 'yes'

secrets:
  postgres_password:
    external: true
  staging_token:
    external: true
  revprox_key:
    external: true
  revprox_cert:
    external: true

```

If the networks don't already exist, Docker creates them.

If secrets are defined as external, they must already exist before the stack can be deployed:

``` yaml
external: true
file: <filename>
```

It's possible for secrets to be created on-demand when the application is deployed. However, this means the secret must exist as an unencrypted value in the host's file system. That's not very secure!

The environment key lets you inject environment variables into services replicas at runtime. For sensitive data, a better solution would be to pass values as secrets.

The constraints key defines a placement constraint. This ensures replicas for this service always run on Swarm worker nodes:

``` yaml

deploy:
  placement:
    constraints:
      - 'node.role == worker'

```
You could also use `Role.node.role != manager`.

When Docker stops a container, it issues a `SIGTERM` to the application process with PID 1 inside the container. The application then has a 10-second grace period to perform any clean-up operations. If it doesn't handle the signal, it's forcibly terminated after 10 seconds with a `SIGKILL`. The `stop_grace_period` property overrides this 10-second grace period.

## Deploying a Stack

To deploy a Stack, use:

`docker stack deploy -c docker-stack.yml <stack-name>`

## Removing a Stack

To remove a Stack, use:

`docker stack rm <stack-name>`

When using the `rm` command, pre-existing secrets aren't deleted.
