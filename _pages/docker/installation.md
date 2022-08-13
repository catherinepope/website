---
layout: single
title: Installing and Configuring Docker
permalink: /docker/installation/
toc: true
---

## Overview

There are two Docker editions:

- Community Edition (CE, entirely free)
- Enterprise Edition (EE, not free)

## Docker Enterprise Edition

Docker Enterprise Edition (EE) is now rebranded as Mirantis Kubernetes Engine (MKE).

Docker EE has three components:

- Docker EE
- UCP (Universal Control Plane)
- DTR (Docker Trusted Registry)

You interact with the UCP, rather than directly with Docker EE.

The UCP is a container that you run from an image.

You cannot install the DTR on the same node as the UCP. Therefore, your Swarm must have more than one node.

Fortunately, the (very tricky) installation steps aren't covered by the exam!

### Sizing Requirements

Sizing requirements *are* covered by the exam, although I have no idea why you'd ever try to memorise this information, rather than just looking it up. Anyway, here it is:

- Minimum 8Gb memory and 2 CPUs for manager modes.
- Recommended 16Gb memory and 4 CPUs for manager modes.
- Minimum 4Gb memory for worker nodes.

### Configuration of Logging Drivers

By default, Docker uses the `json-file` logging driver, which caches container logs as JSON internally.

Docker can also use other drivers, such as splunk and journald.

To configure the logging driver, run the following command:

`docker run -it --log-driver <log-driver> <image-name>`

To fetch the driver type, run:

{% raw %}

`docker inspect -f '{{.HostConfig.LogConfig.Type}}' <container-name>`

{% endraw %}

### Configuring Docker to Start on Boot

Most current Linux distributions (RHEL, CentOS, Fedora, Debian, Ubuntu 16.04 and higher) use systemd to manage which services start when the system boots. On Debian and Ubuntu, the Docker service is configured to start on boot by default. To automatically start Docker and Containerd on boot for other distros, use the commands below:

```
 sudo systemctl enable docker.service
 sudo systemctl enable containerd.service
```

## Backing Up UCP and DTR

Here's the process for backing up UCP and DTR:

1. [Back up the Docker Swarm](./../docker-swarm/#backing-up-a-swarm)
2. Back up UCP
3. Back up DTR Images
4. Back up DTR Metadata

### Backing up UCP

This is done with an image:

![Using an image to back up UCP](./../../assets/images/backup-ucp.png)

### Backing up DTR Images

Make a copy of the following directory:

`/var/lib/docker/volumes/dtr-registry`

### Backing up DTR Metadata

This is done with an image. For example:

``` bash
read -sp 'ucp password: ' UCP_PASSWORD; \
docker run --log-driver none -i --rm \
  --env UCP_PASSWORD=$UCP_PASSWORD \
  docker/dtr:2.5.3 backup \
  --ucp-url <ucp-url> \
  --ucp-insecure-tls \
  --ucp-username <ucp-username> \
  --existing-replica-id <replica-id> > dtr-metadata-backup.tar
```

## Installing Docker Trusted Registry (DTR)

When you install the UCP, you have access to install the DTR from the Admin Settings of the UCP.

Installation Requirements

- Minimum 16Gb memory, 2 CPUs, 10Gb disk
- Recommended 16Gb memory, 4 CPUs, 25-100Gb disk

To install the DTR, you must have at least two nodes in your cluster. It won't work if you try to install it on the same node as the UCP - they both use port 443, so you'll be unable to access the DTR.

1. On the left menu, click admin ➤ Admin Settings ➤ Docker Trusted Registry.
2. Write the IP of the second node in the DTR external URL.
3. Choose the second node in UCP node.
4. Select PEM-CA.
5. Copy the generated code.
6. docker-machine ssh <second node for DTR>
7. Then paste the generated code.
8. The DTR should be installed with TLS for the <second-node-url>.

When the DTR is successfully installed, go again to admin ➤ Admin Settings ➤ Docker Trusted Registry. It will display the IP address of the second node. Copy and paste in the browser. The DTR IP will be displayed.


