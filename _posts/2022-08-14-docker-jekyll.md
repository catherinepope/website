---
layout: single
title: Previewing Jekyll Sites with Docker
date: 2022-08-14
category: Docker
author_profile: true
share: true
toc: true
---

## Introduction

Jekyll is a beautifully simple way to build and deploy a static website. Well, it's simple *once* you've got everything installed and configured. Unless you're already confident with Ruby, it'll probably take you most of a soggy weekend to get it running consistently.

Although the local installation is working well for me, I'm nervous it'll break. I'm already encountering a few Ruby conflicts with other projects. Resolving those issues isn't my idea of fun. Given I've been doing a lot of work with Docker lately, I decided to see whether I could run my site as a container instead. Plot spoiler: yes, I could!

In this post, I'll explain my process.

## Getting the Jekyll Docker Images

Before you can get cracking, you'll need Docker installed and running on your local machine. [Docker Community Edition](https://docs.docker.com/get-docker/) is free, and simple to install. 

There are three Jekyll images available on [Docker Hub](https://hub.docker.com/u/jekyll):

- `jekyll/jekyll` - the default image.
- `jekyll/minimal` - a minimal version, excluding all the extra gems and dependencies
- `jekyll/builder` - includes extra stuff you'll need if you're deploying your build to another server with CI/CD

## Building Your Jekyll Site

To build and preview your site locally, run the following command from your website directory:

``` bash
docker run --rm -it \
  --volume="$PWD:/srv/jekyll" \
  --volume="$PWD/vendor/bundle:/usr/local/bundle" \
  -p 4000:4000  jekyll/jekyll:3.8 \
  --name website
  bundle exec jekyll serve

```

This command:

- runs a container with the `-rm` flag, which removes the container once it exits, and the `-it` flag, which allows you to interact with it.
- maps the current working directory to the `srv/jekyll` directory in the container. The container then builds the site from that directory.
- maps the `vendor/bundle` directory to the container so you can cache and reuse gems in subsequent builds.
- maps port 4000 in the container to port 4000 on the host.
- uses the `jekyll/jekyll:3.8` image to run the container.
- names the container *website* (this is optional, but it's then easier to identify your container).
- runs the `bundle exec jekyll serve` command to build and serve the site on port 4000.

Once you've run this Docker command, you should see your site at: http://localhost:4000. As you make changes to your site, Jekyll continuously builds and serves the updated version.

Press `Ctrl + c` in your terminal to exit the container. As you've set the `-rm` flag, this action also removes the container.

As you've pulled the Jekyll image and cached your gems, subsequent builds should be faster.

## Using Docker Compose

The `docker run` command is quite cumbersome. I guess you could create an alias or a TextExpander snippet, but there's a neater solution.

If you create a Docker Compose file, you can launch your site with the simpler command: `docker-compose up`.

Here's a sample file:

``` yaml
services:
  jekyll:
    image: bretfisher/jekyll-serve
    ports:
      - 4000:4000
    volumes:
      - ".:/site"
```

Docker Compose allows you to deploy multi-container applications on a single machine. In this case, there's just one container for the Jekyll site.

This time, we're using a [Jekyll image from Bret Fisher](https://github.com/BretFisher/jekyll-serve). It's optimized for running on a local dev site. As Bret says in his repo, *this isn't a production image*.

Here's how to use it:

- create a file called `docker-compose.yml` at the top level of your local website directory.
- copy and paste the code above, then save the file.
- run `docker-compose up` at the command line.

You should be able to see your website at: http://0.0.0.0:4000/.

To stop your container, run: `docker-compose stop`. As your container is running in interactive mode, it's easier to run this command in another terminal window. You need to be in the same directory as your website.

You can then restart the container with `docker-compose restart` Or to remove the container completely, use: `docker-compose rm`.

## Conclusion

If you're unfamiliar with Docker, this solution probably isn't less faffy. However, you might find other benefits that make the shift worthwhile. For example, it's much easier to get people to collaborate on your site if they don't need to first set up a Ruby development environment. Your local machine will be cleaner, too.



