---
layout: single
title: Managing Docker Images
permalink: /docker/managing-docker-images/
toc: true
---

## Inspecting Images

The main command is:

`docker image inspect <image-name>`

This produces too much information!

But you can filter the information. For example, to get just the architecture and operating system an image is compatible with, use the following command:

{% raw %}

`docker image inspect --format='{{.Architecture}} {{.Os}}' testimage`

{% endraw %}

And this command would return just the size of the image:

{% raw %}

`docker image ls --format "{{.Size}}"`

{% endraw %}

Finally, let's return all images, but display only the repo, tag, and size:

{% raw %}

`docker image ls --format "{{.Repository}}: {{.Tag}}: {{.Size}}"`

{% endraw %}

## Deleting Images

To delete a Docker image, you can use the following command:

`docker image rm <image-name>`

Or:

`docker rmi <image-name>`

To remove all the images, use:

`docker image rm -f $(docker image ls -q)`

This passes a list of the Docker images to the `rm` command.

## Removing Dangling Images

Dangling images are layers that have no relationship to any tagged images. They serve no purpose and consume disk space. They appear in listings as `<none:none>`. This usually occurs when building an image with an existing tag. When this happens, Docker builds the new image and removes the tag from the existing image.

To find dangling images, you can use the filter flag:

`docker image ls --filter dangling=true`

Then to remove them, use:

`docker rmi $(docker images -f "dangling=true" -q)`

This command lists the dangling images and passes the list to the `rmi` (remove image) command.

Alternatively, you can use:

`docker image prune`

If you add the `-a` flag, Docker also removes all unused images (those not in use by any containers).

`docker image prune -a`

### Pruning Images in DTR

Pruning removes the unused images automatically by setting the pruning policies. Select it from the left menu Repositories ➤ Pruning tab.