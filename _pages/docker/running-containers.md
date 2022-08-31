---
layout: single
title: Running Docker Containers
permalink: /docker/running-containers/
toc: true
---

## Overview

Images are *build-time* constructs, whereas containers are *run-time* constructs.

An image is a stack of layers. The container is the last layer at the top, where you can manipulate it, adding commands and packages on top of that base image.

With the `docker commit` command or a [Dockerfile](./../creating-docker-images/#creating-a-dockerfile), you can save this new image that contains the base image, plus all the additions.

## Starting Containers

Use `docker container run` and `docker service create` commands to start one or more containers from a single image. For example:

``` sh
docker container run <image-name>
```

## Setting Limits on Containers

### Memory

You can limit how much memory the container can use with the `-m` flag. For example:

``` sh
docker container run -m 512m ubuntu
```

### CPU

By default, each container's access to the host machine's CPU cycles is unlimited. To assign CPUs to a container, use the following command:

``` sh
docker run -it cpuset-cpus="1,3" ubuntu
```

The example above specifies that processes in the container can be executed on CPU 1 and CPU 3.

### Controlling Capabilities

Docker Engine includes a default list of capabilities for newly created containers. By using the `--cap-drop` option for `docker run`, you can exclude additional capabilities. This is good for limiting the attack surface of the container.

All privileges can be dropped with the `--user` option.

Likewise, additional capabilities can be granted with the `--cap-add`. Using `--cap-add=ALL` is highly discouraged!

### Removing All Limits

By adding the `--privileged` flag, you give all capabilities to the container and also lift any limitations enforced by the device cgroup controller. In other words, the container can do almost everything the host can do. This is generally a bad idea!

It's better to add specific capabilities with `--cap-add` or specific devices with the `--device` flag. For example:

`docker run --device=/dv/snd:/dev/snd`

## Managing and Updating Containers

The `docker update` command dynamically updates the configuration on running or stopped containers. You can use this command to prevent containers from consuming too many resources from their Docker host. To specify more than one container, provide a space-separated list of container names or IDs.

To see the process list across *all* containers, use: `docker ps`.

To see the process list in a *specific* container, use: `docker container top <container-name>`.

For live stats across *all* containers, use: `docker container stats`.

For live stats on a *specific* container, use: `docker container stats <container-name>`.

To see everything that's been executed in the container, use:

`docker logs <container-name>`

To stop the container:

`docker container stop <container-name>`

You can also pause and unpause a container from another terminal:

`docker container pause <container-name>`

`docker container unpause <container-name>`

To restart the container:

`docker container start <container-name>`

If you want to restart the container in interactive mode, use: `docker container start -ai <container-name>`. The `a` stands for *attach* and the `i` for *interactive*.

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

You cannot delete an image until the last container using it has been stopped and destroyed.

Containers run until the app they are executing exits. For example, a Linux container exits when the Bash shell exits.

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

## Checking Container Health

Docker monitors the health of your app at a basic level every time you run a container. Docker checks the process is still running. If it stops, the container goes into the exited state.

This checks the process is running, but not whether the app is actually healthy. For example, it could be returning a 503 error to every request.

You can add a `HEALTHCHECK` instruction to the [Dockerfile](./../creating-docker-images/). This tells the runtime exactly how to check whether the app in the container is still healthy.

The `HEALTHCHECK` instruction specifies a command for Docker to run inside the container, which returns a status code. For example:

`HEALTHCHECK CMD curl --fail http://localhost/health`

The health check makes an HTTP call to the `/health` endpoint, which tests whether the app is healthy. Using the `--fail` parameter means the `curl` command passes the status code on to Docker. If the request succeeds, it returns `0`.

Docker runs that command in the container at a timed interval. If the status code says everything is OK, the container is healthy. If the status code denotes failure several times in a row, the container is marked as unhealthy.

Docker can’t be sure that taking action to fix the unhealthy container won’t make the situation worse, so it broadcasts that the container is unhealthy but leaves it running. The health check continues, too. If the failure is temporary and the next check passes, the container status flips to healthy again.

## Inspecting Changes to Containers

To inspect changes to files or directories on a container's filesystem, use the following command:

`docker diff <container-name>`

Three different types of change are tracked:

- **A** - a file or directory was added
- **D** - a file or directory was deleted
- **C** - a file or directory was changed

## Backing Up Containers

The `docker export` command exports a container's filesystem as a tar archive.

The `docker export` command does not export the contents of volumes associated with the container. If a volume is mounted on top of an existing directory in the container, `docker export` will export the contents of the *underlying directory*, not the contents of the volume.