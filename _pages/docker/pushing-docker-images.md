---
layout: single
title: Pushing Docker Images
permalink: /docker/pushing-docker-images/
toc: true
---

Docker needs the following information when pushing an image:

- Registry
- Repository
- Tag

## Pushing to Docker Hub

If you're pushing to Docker Hub, you need to log in first using the `docker login` command.

You need to retag an existing image to include your Docker ID, e.g.:

`docker image tag web:latest catherinepope/web:latest`

This adds an additional tag, rather than overwriting the original.

Then you can push it (push it, real good):

`docker image push catherinepope/web:latest`