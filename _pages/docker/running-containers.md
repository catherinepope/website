---
layout: single
title: Running Docker Containers
permalink: /docker/running-containers/
toc: true
---

## Overview

Images are *build-time* constructs, whereas containers are `run-time` constructs.

Use `docker container run` and `docker service create` commands to start one or more containers from a single image.

You cannot delete an image until the last container using it has been stopped and destroyed.

Images don't contain a kernel. All containers running on a Docker host share access to the host's kernel.

Containers run until the app they are executing exits. For example, a Linux container exits when the Bash shell exits.

## Managing Containers

To see everything that's been executed in the container, use:

`docker logs <container-name>`

To stop the container:

`docker container stop <container-name>`

You can also pause and unpause a container from another terminal:

`docker container pause <container-name>`

`docker container unpause <container-name>`

To restart the container:

`docker container start <container-name>`

To remove the container:

`docker container rm <container-name>`

To check the container is removed, run:

`docker container ls -a`

The `-a` flag tells Docker to list all containers, even those in stopped state.

To delete a running container with a single command, use:

`docker container rm <container-name> -f`

But it's best practice to take the two-step approach of stopping then removing the container.

To delete all containers, use:

`docker container -rm -f $(docker container ls -aq)`

## Running a Container in Interactive Mode

To run a container in interactive mode, add the `-it` flag:

`docker container run -it ubuntu:latest /bin/bash`

Press `Ctrl-PQ` to exit the container without terminating it.

It should still be visible through this command:

`docker container ls`

You can attach your shell to the terminal of a running container with the `docker container exec` command:

`docker container exec -it <container-name> bash`

This exec command runs a new process inside a running container. This means the container won't stop when you exit it.

You can also use:

`docker container attach <container-name>`

`attach` doesn't start a new process.

## Running Self-Healing Containers with Restart Policies

Restart policies can be configured:

- imperatively on the command line as part of run commands
- declaratively in YAML files for use with Docker Swarm, Docker Compose, and Kubernetes

There are currently three types of restart policy:

- always
- unless-stopped
- on-failed

### always

This policy always restarts a stopped container unless it has been explicitly stopped, such as via a `docker container stop` command.

For example, if you exit from a container's shell, it kills the container. However, if you've set the `--restart always` policy, it'll restart automatically.

If you explicitly stop a container with `docker container stop` and restart the Docker daemon, the container will be automatically restarted.

### unless-stopped

Unlike containers with the `--restart always` policy, those with an `unless-stopped` policy won't be restarted when the daemon restarts.

### on-failure

The `on-failure` policy restarts a containers if it exits with a non-zero exit code. It also restarts containers when the Docker daemon restarts, even containers that were in the stopped state.
