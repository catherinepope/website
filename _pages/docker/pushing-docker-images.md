---
layout: single
title: Pushing Docker Images
permalink: /docker/pushing-docker-images/
toc: true
---

## Overview

Docker needs the following information when pushing an image:

- Registry
- Repository
- Tag

Repository names should be between 2 and 255 characters long.

An image tag name can be a maximum of 128 characters.
## Pushing an Image to Docker Hub

If you're pushing to Docker Hub, you need to log in first using the `docker login` command.

You need to retag an existing image to include your Docker ID, e.g.:

`docker image tag web:latest catherinepope/web:latest`

This adds an additional tag, rather than overwriting the original.

Tags are effectively a pointer to an image commit.

Then you can push it (push it, real good):

`docker image push catherinepope/web:latest`

You push an image, but Docker actually uploads the image *layers*.

The Docker daemon pushes five layers at a time.

Layers are only uploaded to the registry if there isn't an existing match for that layer's hash.

## Pushing an Image to the DTR Repository

Log in to the DTR using `docker login <dtr-ip-address>`.

Then push the image:

`docker push <ip/user/image-name:tag>`

Verify that the image has been submitted correctly by clicking on the left menu in the UCP: Repositories ➤ Tags or Images.

### Trusting Images

By default, when you push an image to DTR, the Docker CLI doesn't sign the image. To sign images, you need to set an environment variable of `DOCKER_CONTENT_TRUST=1`. Now when you push an image, it creates trust metadata. It also creates public and private keys pairs to sign the trust metadata, and push that metadata to the Notary Server.

To sign images to ensure UCP trust, you need to:

- Configure your Notary client.
- Initialize trust metadata for the repository.
- Delegate signing to the keys in your UCP client bundle.

### Making Images Immutable

Setting the image as immutable prevents it from being overwritten and deleted. This option is usually selected for an image after it's scanned and promoted.

If a user tries to delete this image, it throws an error. To set immutability, select from the left menu Repositories ➤ Settings ➤ Immutability tab.

