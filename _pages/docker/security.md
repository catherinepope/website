---
layout: single
title: Securing Docker
permalink: /docker/security/
toc: true
---

## Overview

On Linux, Docker leverages most of the common Linux security and workload isolation technologies. These include:

- namespaces
- control groups (cgroups)
- capabilities
- mandatory access control (MAC) systems
- seccomp

**Docker Swarm Mode** is secure by default.

**Docker Content Trust** lets you sign your images and verify the integrity and publish of images you consume.

**Image security scanning** analyses images, detects known vulnerabilities, and provides detailed reports.

**Docker secrets** are stored in the encrypted cluster store, encrypted in-flight when delivered to containers, stored in in-memory filesystems when in use, and operate a least-privilege model.

## Namespaces

Kernel namespaces slice up an operating system so it looks and feels like multiple isolated operating systems. This is why you can run multiple web servers on the same OS without experiencing port conflicts.

Each *network namespace* gets its own IP address and full range of ports.

You can run multiple applications, each requiring their own version of a shared library or configuration file. To do this, you run each application inside its own mount namespace. This works because each mount namespace can have its own isolated copy of any directory on the system (e.g. /etc, /var, /dev).

Docker on Linux currently utilizes the following kernel namespaces:

- Process ID (pid)
- Network (net)
- Filesystem/mount (mnt)
- Inter-process Communication (ipc)
- User (user)
- UTS (uts)

**Docker containers are an organized collection of namespaces.**

Every container has its own `pid`, `net`, `mnt`, `ipc`, `uts`, and potentially `user` namespace. A container is an organized collection of these namespaces.

### Process ID Namespace

Docker uses the `pid` namespace to provide isolated process trees for each container. Every container gets its own PID 1. PID namespaces also mean that one container cannot see or access the process tree of other containers. Nor can it see or access the process tree of the host on which it's running.

### Network Namespace

Docker uses the `net` namespace to provide each container with its own isolate network stack. This stack includes:

- interfaces
- IP addresses
- port ranges
- routing tables

Every container gets its own eth0 interface with its own unique IP and range of ports.

### Mount Namespace

Every container gets its own unique isolate root (/) filesystem. This means every container can have its own /etc, /var, /dev constructs. Processes inside a container cannot access the `mnt` (mount) namespace of the Linux host or other containers.

### Inter-process Communication Namespace

Docker uses the `ipc` namespace for shared memory access within a container. It also isolates the container from shared memory outside the container.

### User Namespace

Docker lets you use `user` namespaces to map users inside a container to different users on the Linux host. A common example is mapping a container's root user to a non-root user on the Linux host.

## Control Groups

Control groups are about setting limits.

Containers are isolated from each other, but all share a common set of OS resources, such as CPU, RAM, network bandwidth, and disk I/O. Cgroups let us set limits on each of these resources so a single container can't consume everything and cause a denial of service (DoS) attack.

## Capabilities

It's a bad idea to run containers as root. However, non-root users are almost powerless.

The Linux root user is a long list of capabilities. Docker works with capabilities so you can run containers as root, but strips out all the capabilities you don't need.

This is an example of implementing *least privilege*.

### seccomp

Docker uses seccomp, in filter mode, to limit the syscalls a container can make to the host's kernel.

All new containers get a default seccomp profile, configured with sensible defaults. You can customize these profiles, and also pass a flag to Docker so containers can be started without a seccomp profile.

### SELinux

SELinux, or Security-Enhanced Linux, is a part of the Linux security kernel that acts as a protective agent on servers. In the Linux kernel, SELinux relies on mandatory access controls (MAC) that restrict users to rules and policies set by the system administrator. SELinux acts under the least-privilege model.

The interaction between SELinux policy and Docker is focused on two concerns:

- protection of the host
- protection of containers from one another.

## Securing Docker Swarm

By default, Swarm Mode includes:

- Cryptographic node IDs
- TLS for mutual authentication
- Secure join tokens
- CA configuration with automatic certificate rotation
- Encrypted cluster store (config DB)
- Encrypted networks

When you initialize a Swarm with a manager and workers:

- node1 is configured as the first manager of the swarm and also as the - root certificate authority (CA).
- the swarm itself is given a cryptographic clusterID.
- node1 has issued itself with a client certificate that identifies it as a manager in the swarm.
- certificate rotation is configured with the default value of 90 days.
- a cluster config database is configured and encrypted.
- a set of secure tokens is created so new managers and workers can join the swarm.

To rotate tokens:

`docker swarm join-token --rotate manager`

Existing managers don't need updating, but you'll need to the new token to add new managers.

Join tokens are stored in the cluster store, which is encrypted by default.

### TLS and Mutual Authentication

Every manager and worker that joins the swarm is issued a client certificate. This certificate is used for mutual authentication. It identifies the node, the Swarm it's a member of, and the role the node performs in the Swarm.

You can configure the certificate rotation period with the following command:

`docker swarm update --cert-expiry 720h`

### The Cluster Store

The cluster store is the brains of the swarm and where cluster config and state are stored. If you're not running in swarm mode, there are many technologies and security features you'll be unable to use.

The store is based on `etcd` and is automatically configured to replicate itself to all managers in the swarm. It is also encrypted by default.

## Signing and Verifying Images with Docker Content Trust

Docker Content Trust (DCT) makes it simple to verify the integrity and publisher of images you pull and run. DCT allows developers to sign images when they're pushed to Docker Hub and other registries. DCT can also be used to provide context, e.g. whether an image has been signed for use in a particular environment (prod or dev).

You need a cryptographic key-pair to sign images:

`docker trust key generate <key-name>`

DCT uses three keys:

- Root/offline key
- Repository/tagging key
- Timestamp key

The root key is crucial! Don't lose it, else you'll need to contact Docker Support to reset it. The root key belongs to one person or organization.

The repository key is associated with an image repository. The last key (the timestamp) denotes image freshness.

To sign an image:

`docker trust sign <username/image:tag>`

To inspect the signed image:

`docker trust inspect <username/image:tag>`

To revoke a signature from an image:

`docker trust revoke <username/image:tag>`

You can force a Docker host to always sign and verify image push and pull operations by exporting the `DOCKER_CONTENT_TRUST` environment variable with a value of `1`:

`export DOCKER_CONTENT_TRUST=1`

Once the above environment variable is set, when you push an image, you'll be prompted to create root and repository keys.

With `DOCKER_CONTENT_TRUST` set to `1`, all images pulled or pushed must be signed, unless they are official or verified images.

You could override DCT with `docker image pull --disable-content-trust <image-name>` but you'd be unable to run the image as a container.

Set `DOCKER_CONTENT_TRUST` to `0` to disable it.

## Transport Layer Security (TLS)

TLS ensures authenticity of the registry endpoint and that traffic to/from the registry is encrypted.

You use TLS (HTTPS) to protect the Docker daemon socket. If you need Docker to be reachable safely through HTTP rather than SSH, you can enable TLS be specifying the `tlsverify` flag and pointing Docker's `tlscacert` flag to a trusted CA certificate.

To configure the Docker engine to use a registry that is not configured with TLS certificates from a trusted CA, pass the `--insecure-registry` flag to the dockerd daemon at runtime. Also, place the certificate in `/etc/docker/certs.d/dtr.example com/ca.crt` on all cluster nodes. These two steps will save you from receiving the error `’`x509: certificate signed by unknown authority`.

**For the exam, always remember the difference between DCT and TLS. The exam tries to confuse you about them.**

## Mutually Authenticated Transport Layer Security (MTLS)

- Both participants in communication exchange certificates and all communication is authenticated and encrypted.
- When a swarm is initialized, a root certificate authority (CA) is created, which is used to generate certificates for all nodes as they join the cluster.
- Worker and manager tokens are generated using the CA and are used to join new nodes to the cluster.
- Used for all cluster-level communication between swarm nodes.
- Enabled by default, you don't need to do anything to set it up.

## Role-Based Access Control (RBAC)

RBAC is performed by creating grants. The grant consists of:

- Subject (person or team)
- Collection (resources)
- Role (privileges)

The subject is the team, or one of more users, who will access a certain collection/resource with granular roles/privileges.

You can make the grant and its components using the UCP or the command line.

RBAC works the same way in Docker and Kubernetes.

1. Create users
2. Create a collection (you can include or exclude children/grandchildren)
3. Create a role
4. Create a grant

A **grant** defines who (subject) has how much access (role) to a set of resources (collection). Each grant is a 1:1:1 mapping of subject, role, and collection.

For example the *masters* team has all to all *secret* operations in the *kubeadmins* collection.

## Docker Secrets

Secrets are:

- encrypted at rest
- encrypted in-flight
- mounted in containers to in-memory filesystems
- operate under least-privilege model

The default location of secrets inside a Docker container is `/run/secrets`.

Secrets are not available to standalone containers, only to Swarm services.

### Creating Secrets

To create a secret, use the following command format:

``` sh
echo "This is an external secret" | docker secret create my_external_secret -
```

Don't miss that dash at the end!

To list secrets, use:

`docker secret ls`

#### Using Secrets with Services

You can attach secrets to services by specifying the `--secret` flag to the `docker service create` command.

To add or remove secrets to or from an existing service, use:

``` sh
docker service update --secret-add <secret-name>

docker service update --secret-rm <secret-name>
```
#### Using Secrets with Stacks

You need to use at least version 3.1 for secrets.

Here's an example:

``` yaml
version: '3.1'
services:
    psql:
        image: postgres
        secrets:
            - psql_user
            - psql_password
    
    secrets:
        psql_user:
            file: ./psql_user.txt
        psql_password:
            external: true
```

The `psql_user` secret is created from a file, while `psql_password` is an existing secret.

Removing a Stack also removes the secrets.