---
layout: single
title: Using Storage in Docker
permalink: /docker/storage/
toc: true
---

There are two main categories of data:

- persistent
- non-persistent

Every Docker container gets its own non-persistent storage. This is created automatically and is tightly coupled to the container's lifecycle.

To persist data, a container needs to store it in a volume. Volumes are separate objects whose lifecycles are decoupled from containers.

## Non-Persistent Data

Every Docker container is created by adding a thin read-write layer on top of the read-only image on which it's based. The writable layers exist in the filesystem of the Docker host: `/var/lib/docker/<storage-driver>`.

Any data written to this layer is deleted when the container is deleted.

This writable layer of local storage is managed on every Docker host by a storage driver.

You can share local storage between containers with the `--volumes-from` option in the `docker run` command. For example:

`docker run -it --volumes-from first-container --name second-container ubuntu bash`

If you want to commit information to the image before pushing it to a repo, you must use a filesystem. For example:

```bash
docker run -it -v /vol1 --name file_container ubuntu bash
mkdir new && cd new 
date > file1
exit
docker commit file_container file_image
docker run -it file_image
```

### Storage Drivers

Storage drivers are sometimes known as *graph drivers*. The appropriate storage driver often depends on your OS:

- **overlay2:** current Ubuntu and CentOS
- **aufs: Ubuntu** 14.04 and older
- **devicemapper:** CentOS 7 and earlier.

#### Configuring DeviceMapper

DeviceMapper is one of the Docker storage drivers available for some Linux distributions.

You can customize your DeviceMapper configuration using the daemon config file.

DeviceMapper supports two modes:

**loop-lvm** mode:

- Loopback mechanism simulates an additional physical disk using files on the local disk.
- Minimal setup, doesn't require an additional storage device.
- Bad performance, only use for testing.

**direct-lvm** mode:

- Stores data on a separate device.
- Requires an additional storage device.
- Good performance, use for production.

## Using Volumes

Volumes are the recommended way to persist data in containers. Here's the process:

- Create a volume.
- Create a container and mount the volume into it.
- The volume is mounted into a directory in the container's filesystem.
- Anything written to that directory is stored in the volume.
- If you delete the container, the volume and its data still exist.

Persistent data can be managed using several storage models.

### Storage Models

#### Filesystem storage

- Data stored in form of a file system.
- Used by overlay2 and aufs
- Efficient use of memory
- Inefficient with write-heavy workloads.

#### Block storage

- Stores data in blocks.
- Used by devicemapper.
- Efficient with write-heavy workloads.

#### Object storage

- Stores data in an external object-based store.
- Application must be designed to use object-based storage.
- Flexible and scalable.

You can also deploy volumes via Dockerfiles using the `VOLUME` instruction: `VOLUME <container-mount-point>`. You cannot specify a directory on the host when defining a volume in a Dockerfile. This is because host directories differ according to the OS on which your Docker host is running. Consequently, defining a volume in a Dockerfile requires you to specify host directories at deploy-time.

### Creating Volumes

To create a volume, use the following command:

`docker volume create <volume-name>`

By default, Docker creates new volumes with the built-in `local` driver. As the name suggests, volumes created with the `local` driver are available only to containers on the same node as the volume. You can use the `-d` flag to specify a different driver.

Third-party volume drivers are available as plugins. Once the plugin is registered, you can create new volumes from the storage system using docker volume create with the `-d` flag.

Use docker volume inspect to see what driver it's using and where the volume exists.

All volumes created with the local driver get their own directory under `/var/lib/docker/volumes` on Linux. This means you can see them in your Docker host's filesystem.

### Mounting a Volume

To mount a volume to a container, use the following command:

`docker container run -dit --name voltainer --mount source=bizvol,target=/vol alpine`

If you specify a volume that doesn't exist, Docker creates it for you.


### Removing Volumes

To remove a volume, use `docker volume rm`.

To delete any unmounted volumes, use `docker volume prune`.

## Kubernetes

For the DCA exam, you also need to know about [storage in Kubernetes](./../../kubernetes/storage/).

