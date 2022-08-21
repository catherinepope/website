---
layout: single
title: Creating and Running a Docker Image of Your Website
date: 2022-08-21
category: Docker
author_profile: true
share: true
---

## Introduction

In the olden days, it would take hours to install and configure a web server on a local machine. It was especially fiddly if you wanted to recreate a specific environment for testing purposes. Happily, Docker has made our lives much easier. 

In this tutorial, we'll package a simple website and nginx server as a Docker image. Anyone with Docker Desktop installed can then run that site in seconds without having to set up anything.

For this to work, you'll need [Docker Desktop](https://docs.docker.com/get-docker/) installed on your machine.

## Creating Your Docker Image

First, let's take a peek at the default behaviour of the nginx image. If you type: `docker container run --publish 80:80 nginx` at the command line, you'll see nginx is running and serving its default page:

![Default nginx page](/assets/images/nginx.png)

Next, we'll create our own version of this image and get it to display a (marginally) more exciting webpage.

To build an image, you'll need to create a *Dockerfile* with the following contents:

``` 
FROM nginx:latest

WORKDIR /usr/share/nginx/html

COPY index.html index.html
```

In the `FROM` instruction, we're specifying `nginx:latest` as the base layer.

Then we switch the `WORKDIR` (working directory) to `/usr/share/nginx/html` - the location where nginx is expecting to find webpages.

Finally, we `COPY` a local `index.html` file to the nginx container, giving it the same name. 

As we're using the nginx base layer, the `CMD` instruction (which tells the container what to do) is already specified. 

That's everything we need in our Dockerfile.

Of course, there should also be an `index.html` file. 

I'm using a very simple example, which displays a random image from Unsplash:

``` html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Random Image</title>
</head>
<body>
    <h1>What will it be?</h1>
    <img src="https://source.unsplash.com/random" alt="Displays a random image from Unsplash">
</body>
</html>
```
Make sure your `Dockerfile` and `index.html` are in the same directory.

Now we can build the image:

``` sh
docker image build -t my-web .
```

This command builds our image from the Dockerfile, giving it a name of `my-web`. The full stop (or period) tells Docker to look in the current directory for the Dockerfile.

A quick `docker image ls` command shows us the image is ready and waiting:

![Tada! Image has been created](/assets/images/my-web.png)

## Running Your Docker Container

To run a container from our newly created image, use the following command:

`docker container run --publish 80:80 my-web`

We're running the container on port 80 of localhost, and the container exposes port 80 (this was specified in the `nginx` base layer).

Visit localhost in your browser, and you'll see your tiny website. If you used my `index.html` file, you'll get a random image (hopefully it's nothing rude).

![Webpage served by nginx](/assets/images/random-image.png)

To share your website with someone else, you can push your image to Docker Hub. There are three steps:

1. Make sure you're logged into Docker Hub (use `docker login`).
2. Tag your image with your repository name. For example, I would use: `docker image tag my-web catherinepope/my-web` - this renames `my-web` to `catherinepope/my-web`.
3. Push your image: `docker image push catherinepope/my-web`. Now anyone can use this image by referencing `catherinepope/my-web`.

If you're just using the nginx container locally to test your website, there's no need to create a new image. Instead, you can mount your local files onto the container:

`docker container run -d --publish 80:80 -v $(pwd):/usr/share/nginx/html nginx`

In this command:

- the `-v` flag indicates we want to mount a local directory as a volume. 
- `$(pwd)` outputs the current working directory, where our HTML files are located. This is the source. 
- a colon `:` is followed by the location (or destination) on the container where we want to mount the directory. In this case, we're using the nginx default `/usr/share/nginx/html`.
- finally, we specify the `nginx` image.

Any web files you add to this directory are now accessible to your nginx server. If you update a file in this directory and hit refresh, you'll see the new version in your browser.

## Conclusion

That's a very simple example of running a website with Docker. Hopefully, it's enough to get you started with a more sophisticated build. Or you can just keep hitting refresh on your random image page.