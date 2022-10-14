---
layout: single
title: Creating a Jekyll Site with Docker
date: 2022-09-25
category: Docker
author_profile: true
share: true
---

Although it only takes a minute to create a Jekyll site, you could easily spend a large chunk of your life installing the environment. A query on the [Write the Docs forum](https://www.writethedocs.org/slack/) prompted me to share an easier way.

In this post, I'll show you how to create a Jekyll site in three steps, using the free Docker Community Edition and Bret Fisher's images. 

## Step 1: Install Docker

First, you'll need Docker installed on your local machine. [Docker Community Edition](https://docs.docker.com/get-docker/) is free, and straightforward to install.

Follow the instructions for your OS, and then make sure Docker is running - on a Mac, you'll see the whale icon in the menu bar; on Windows, it's lurking in the systray.

## Step 2: Run the Jekyll command

With Docker installed, you can use it from the command line. Open your terminal and navigate to the empty directory where you want to create your Jekyll site.

Now copy and paste the following Docker command:

``` sh
docker run -v $(pwd):/site bretfisher/jekyll new .
```

You should see the installation progress, followed by a message to confirm that the new site has been installed.

![Jekyll new](/assets/images/create-jekyll-docker.png){: .align-center}

Here's what's happening in the snippet above:

- `docker run` - Runs a Docker container.
- `-v $(pwd):/site` - Mounts your current directory (`pwd` *prints* the working directory) to the `site` directory in the Docker container. 
- `bretfisher/jekyll` - Specifies that the Docker container should use this image.
- `new` - Passes the `new` command to Jekyll, creating a new site.
- `.` - Tells Docker to use the current directory. Don't forget this period/full stop, or it won't work.

It's a complicated command, so I recommend copying and pasting it.

Docker spins up a container from the Jekyll image and creates your site in the current directory. Once that's done, the container exits.

Type `ls` at the command line, and you should see the elements of your Jekyll site:

![Jekyll file listing](/assets/images/jekyll-ls.png){: .align-center}

## Step 3: Test your new site

Right now, you just have some files. You want to know whether they'll actually work as a website.

Happily, there's another Docker command and image for this purpose. In the same directory, paste the following command:

``` sh
docker run -p 4000:4000 -v $(pwd):/site bretfisher/jekyll-serve
```

Here's what's happening:

- `docker run` - Runs a Docker container.
- `-p 4000:4000` - Tells Docker to map port 4000 on the host to port 4000 on the container.
- `-v $(pwd):/site` - Mounts your local working directory and mounts it to the `site` directory in the container.
- `bretfisher/jekyll-serve` - Specifies that the Docker container should use this image.

The Docker container spins up, then builds and serves your new website. You'll see a URL through which you can preview your site.

![jekyll serve](/assets/images/jekyll-serve.png){: .align-center}

It'll be the default Jekyll site for now. To test it properly, make a change to the `about.markdown` page and refresh your browser.

The files are all on your local machine, but Jekyll itself is safely isolated within the Docker container.

## Next Steps

You now have a Jekyll site on your local machine, without the pain of installing Ruby and myriad libraries. 

In a previous post, I explained an [alternative method for building and previewing existing Jekyll sites](https://www.catherinepope.com/docker/2022/08/14/docker-jekyll.html). There are also some tips on simplifying the Docker commands - worthwhile if you're using this method a lot.

There's more information on the [Docker images on Bret Fisher's GitHub page](https://github.com/BretFisher/jekyll-serve). A big thank you to Bret for creating and maintaining these images. They make Jekylling much easier.

If you want to learn about Docker in more depth, I recommend [Bret's course](https://www.bretfisher.com/coupon-for-docker-mastery-udemy-course-the-complete-toolset-from-a-docker-captain/).

If you prefer to see a demo of this tutorial, here's a video version:

{% include video id="n18i3uTMhd4" provider="youtube" %}