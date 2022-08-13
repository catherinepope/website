---
layout: single
title: Introduction to Docker
permalink: /docker/intro/
toc: true
---

## Overview

Docker is an open source platform for building, deploying, and managing containerized applications.

With Docker, you can migrate each part of your application to a container, and then you can run the whole application in containers using Azure Kubernetes Service or Amazon’s Elastic Container Service, or on your own Docker cluster in the datacenter.

## Docker Elements

 - **Docker Engine** is the management component of Docker. It looks after the local image cache, downloading images when you need them, and reusing them if they’re already downloaded. It also works with the operating system to create containers, virtual networks, and all the other Docker resources. The Engine is a background process that is always running (like a Linux daemon or a Windows service).
 - Docker Engine makes all the features available through the **Docker API**, which is a standard HTTP-based REST API. You can configure the Engine to make the API accessible only from the local computer (which is the default), or make it available to other computers on your network.
 - The **Docker command-line interface (CLI)** is a client of the Docker API. When you run Docker commands, the CLI actually sends them to the Docker API, and the Docker Engine does the work.

The Docker Engine uses a component called containerd to actually manage containers, and containerd in turn makes use of operating system features to create the virtual environment that is the container.

containerd is an open source component overseen by the Cloud Native Computing Foundation, and the specification for running containers is open and public. It’s called the Open Container Initiative (OCI).