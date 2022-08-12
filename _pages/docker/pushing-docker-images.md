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

## Pushing an Image to Docker Hub

If you're pushing to Docker Hub, you need to log in first using the `docker login` command.

You need to retag an existing image to include your Docker ID, e.g.:

`docker image tag web:latest catherinepope/web:latest`

This adds an additional tag, rather than overwriting the original.

Then you can push it (push it, real good):

`docker image push catherinepope/web:latest`

## Pushing and Image to the DTR Repository

Log in to the DTR using `docker login <dtr-ip-address>`.

Then push the image:

`docker push <ip/user/image-name:tag>`

Verify that the image has been submitted correctly by clicking on the left menu in the UCP: Repositories ➤ Tags or Images.

### Making Images Immutable

Setting the image as immutable prevents it from being overwritten and deleted. This option is usually selected for an image after it's scanned and promoted.

If a user tries to delete this image, it throws an error. To set immutability, select from the left menu Repositories ➤ Settings ➤ Immutability tab.

