---
layout: single
title: Getting Started with Helm
date: 2022-10-26
category: Kubernetes
author_profile: true
share: true
---

So far in this series, we've created some very simple Kubernetes applications. If you built something more complicated, with dozens of manifests, it would be a faff to share it with other people. Those other people might also struggle to understand and tweak your configuration.

With a Helm Chart, you can define, install, and upgrade even the most complex Kubernetes application. For instance, I currently work for a CI/CD company which offers a self-hosted Kubernetes-based version of its product. Rather than having to create lots of different Kubernetes resources, customers instead receive a Helm Chart with everything already mapped out - all the Deployments, Secrets, Users, and ConfigMaps. They then configure some of the values and install the chart on their own Kubernetes cluster.

In this post, I'll explain how Helm works and walk you through getting started. You'll install Helm and a chart for running MySQL locally.

To follow the steps in this tutorial, you'll need:

- kubectl
- minikube

For guidance on installing these tools, [see my earlier blog post](https://www.catherinepope.com/kubernetes/2022/08/28/kubernetes-minikube.html).

## What is Helm?
[Helm](https://helm.sh/) is a *package manager* for Kubernetes. Just as Homebrew is a package manager for macOS, and apt is a package manager for Linux. Helm allows you to bundle up all the files as a chart for your Kubernetes application and share it with others. Like Docker images, you can push Helm Charts to a repository, from where other people can download and use them. You can create both public and private repositories.

## What is a Helm Chart?

A Helm Chart is essentially a blueprint for your application. It comprises a collection of YAML files with dynamic values for users to populate.

Here's a simple example of a Helm Chart for a single Pod:

{% raw %}

``` yaml
apiVersion: v1
kind: Pod
metadata:
	name: {{ .Values.name }}
spec:
	containers:
	- name: {{ .Values.container.name }}
	  image: {{ .Values.container.image }}
	  port: {{ .Values.container.port }}
```
{% endraw %}

The placeholders are replaced with values from a file called `values.yaml`:

``` yaml
name: web-app
container:
	name: web-app-container
	image: web-app-image
	port: 9001
```

This approach allows you to use the same blueprint for different purposes. For example, you might want to recreate the same application in various environments (development, staging, production). You can specify a different `values.yaml` for each environment, but there's no need to create separate manifests. 

Another core use is for microservices. Rather than create a separate YAML file for all your microservices, you need just one chart and then a `values.yaml` file for each microservice.

## What does a Helm Chart look like?

A Helm Chart is a folder of files. Within the folder, you'll find:

- `Chart.yaml` - contains metadata about the chart.
- `values.yaml` - contains values for for the template files
- `charts/` - a subfolder of chart dependencies
- `templates/` - a subfolder of the actual template files

This Chart includes everything you need to recreate an app on an existing Kubernetes cluster.

## Installing Helm

You can install the Helm CLI from [a script or a binary release](https://helm.sh/docs/intro/install/ "https://helm.sh/docs/intro/install/").

Alternatively, macOS users can install it with Homebrew: `brew install helm`

And Windows users can use Chocolatey: `choco install kubernetes-helm`

To ensure Helm is installed properly, type `helm version` at the prompt. You should see a message similar to this:

![Helm version](/assets/images/helm-version.png)

## Adding a Helm Repository

Before you can install a Helm Chart, you need to *add* the repository in which it's stored. Unlike Docker images, there's no central repository from which you can pull authorized charts. You'll need to identify some reliable sources.

A good place to start is [ArtifactHUB](https://artifacthub.io/).  If I search for a MySQL Helm Chart, it returns 129 options. Most are from people or organizations I've never heard of. However, the top result is from Bitnami, a reputable company.

SCREENSHOT

I'm using Bitnami for this example, as they offer a lot of useful charts. 

Click on the link, and you get more information, including versions and commands. You'll also see the values you can override to configure your installation.

To add the Bitnami repository, use the following command:

``` sh
helm repo add bitnami https://charts.bitnami.com/bitnami
```

The `helm repo add` command takes two arguments: the name of the repository and the URL of the repository. You can give it any name you like, so it's more like an alias. Make sure it's something distinctive, though.

If you used the command above, you'll see a message to confirm: `"bitnami" has been added to your repositories`.

## Installing a Helm Chart

Once that repository is added, you should run the `helm repo update` command to ensure you've got the latest version of the Chart. You can then install the MySQL chart with the following command:

``` sh
helm install my-release bitnami/mysql
```

The `helm install` command takes two arguments: the name you want to give your release (or Helm-based application), then the repo name and Chart name. The repo name is whatever you called it. 

You'd want to come up with something better than `my-release`, but hey, it's a start. Alternatively, you could ask Helm to generate a name. Just add the `--generate-name` flag. For example:

``` sh
helm install bitnami/mysql --generate-name
```

As you can see, Helm has installed the Chart with the name `my-release`.

There's also an alarming amount of information in my terminal. This is good. If you skim through it, you'll find various nuggets of useful information.

![MySQL instructions](/assets/images/mysql-instructions.png)

For example, there are instructions on how to connect with MySQL. By running the three suggested commands, I can connect to the Pod, log in to MySQL, and list all the databases:

![MySQL show databases](/assets/images/mysql-prompt.png)

And if I run a `kubectl get all` command, I can see that the Helm Chart has created a Pod, two services, and a StatetfulSet:

![kubectl get all](/assets/images/kubectl-get-all.png)

All those Kubernetes resources were created with a simple Helm command. And we can make them go away easily, too.


## Deleting a Helm Release

Once you've finished experimenting with your MySQL installation, you can run another command to remove it:

`helm delete <my-release>`

The argument in angled brackets is the name of your release. If you've forgotten the name, use the `helm list` command to see everything that's running.

You should then see a message confirming that `release "my-release" uninstalled`.

## Conclusion

Admittedly, this isn't very this isn't very exciting. Yet. 

In my next tutorial, we'll use Helm to install and configure WordPress locally on minikube. Then you'll be able to interact with it in your browser.

Until then, Happy Helming.