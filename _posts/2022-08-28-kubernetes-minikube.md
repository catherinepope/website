---
layout: single
title: Creating a Kubernetes Deployment with minikube
date: 2022-08-28
category: Kubernetes
toc: true
author_profile: true
share: true
---

One of my first tasks as a technical writer was to document a Kubernetes-based release orchestration tool. Not daunting at all. At that time, I could provide a vague description of Kubernetes, but hadn't the foggiest idea what it actually looked like. There aren't many opportunities in life to just *play* with a Kubernetes cluster - at least, not without spending thousands of dollars on AWS.

Fortunately, I discovered [minikube](https://minikube.sigs.k8s.io/docs/start/), a free solution for installing a single-node cluster Kubernetes on your local machine. With this setup, I've been able to experiment with various products and projects. Thanks to a couple of clever add-ons, you can even simulate load balancers and DNS servers, too.

In this post, I'll explain how to set up minikube and run your first simple Kubernetes deployment.

## Installing and Configuring minikube

Alongside minikube, you'll also need a couple of other tools. 

### minikube

First, [download minikube](https://minikube.sigs.k8s.io/docs/start/) for your platform. It's currently available for macOS, Linux, and Windows. If you're using a Mac and [Homebrew](https://brew.sh/) you can install it by typing `brew install minikube` at the command line. Windows users can use the command `choco install minikube` with [Chocolatey](https://chocolatey.org/).

### Hyperkit

To run minikube, you'll also need a virtual machine manager. There are several options, but Hyperkit seems to be most reliable. If Docker for Desktop is installed on your computer, you already have Hyperkit. Otherwise, there are the following installation options:

- On macOS, use the Homebrew command `brew install hyperkit`
- On Windows, use the Chocolatey command `choco install hyperkit`
- Install from [the GitHub repo](https://github.com/moby/hyperkit).

### kubectl

kubectl (pronounced *cube-control*), provides command-line access to your Kubernetes cluster. There are a few installation options:

- On macOS, use the Homebrew command `brew install kubectl`.
- On Windows, use the Chocolatey command `choco install kubernetes-cli`.
- Follow the instructions for your OS in the [kubectl documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/).

To check kubectl is installed, run `kubectl version` at the command line.

Once you've got minikube, Hyperkit, and kubectl, you're ready.

At the command line, type:

```sh
minikube start --driver=hyperkit
```

The first time you do this, it'll be sloooow. Make yourself a cup of tea while it downloads and installs Kubernetes. Subsequent startups will be a lot faster.

Take a look at the documentation if you want to limit how much memory minikube can use.

Eventually, you'll see some jaunty emojis to show that minikube is up and running. You have a Kubernetes cluster called `minikube`.

![minikube start](/assets/images/minikube-start.png)

## Creating a Kubernetes Deployment

Pods are the smallest unit of work on Kubernetes. Although you can create pods individually, deployments give you more control. The Kubernetes deployment object lets you:

- Deploy a replica set or pod.
- Update pods and replica sets.
- Roll back to previous deployment versions.
- Scale a deployment.
- Pause or continue a deployment.

In short, a Kubernetes deployment ensures the desired number of pods are running and available at all times. 

The best way to create a Kubernetes deployment is *declaratively* with a YAML file. That way, your deployment is fully documented and (hopefully) stored in version control. 

While you're getting started, though, it's much more fun to be *imperative* and issue a command.

Type the following command to create your deployment:

```sh
kubectl create deployment my-deploy --image=catherinepope/my-web
```

This command creates a Kubernetes deployment called `my-deploy`, running one pod with an Docker image called `catherinepope/my-web`. This image simply displays a random picture from Unsplash. You can substitute it with an image of your own.

Although Kubernetes tells you the deployment is created, there's not a lot to see. Hmm, not impressive so far.

To get more confirmation of your deployment, use: `kubectl get deploy`.

And you can take a peek at your pod with: `kubectl get pod`.

![kubectl get pod](/assets/images/kubectl-get-pod.png)

There's your solitary pod. As it's part of a deployment, its name is generated automatically and prefixed with the deployment name.

To make your deployment visible as a web app, you need to expose it as a service.

## Exposing a Kubernetes Service

The default Kubernetes service type is `ClusterIP`, which means your Pods are visible only within the cluster. That's not much good if you want to run a web app. To make your application publicly available, you need a `NodePort` service. 

Here's the command:

```sh
kubectl expose deployment my-deploy --port 80 --name my-deploy-np --type NodePort
```

The `port` is the port exposed on my image. If you're using a different image, the port should be available in the documentation. If you've already pulled the image, you can discover the port with the following command:

{% raw %}

```sh
docker inspect --format='{{.Config.ExposedPorts}}' catherinepope/my-web
```

{% endraw %}

![exposed ports](/assets/images/exposed-ports.png)

This command uses a Go template to extract the port information from the Docker image's configuration.

There are a couple more steps. First, you need to enable Ingress for your cluster. That sounds complicated, but just type:

```sh
minikube addons enable ingress
```

I find it often hangs for a few minutes, so watch a couple of kitten videos on YouTube while you're waiting.

![minikube addons enable ingress](/assets/images/my-web.png)

Then you need to know the IP address for your minikube cluster. Again, this is simple. Just type: `minikube ip`

![minikube ip](/assets/images/minikube-ip.png)

To view the web app, you need this minikube ip, along with the port number for your service. Type: `kubectl get svc`

Here you'll see the port number for the `my-app-np` service is 32132.

![kubectl get svc](/assets/images/kubectl-get-svc.png)

Perversely, the port order is the reverse of what you'll see in Docker - it's the container first, then the host.

In this case, the app is visible from: `192.168.64.27:32132`

Your IP address and port will probably be different.

![My Kubernetes deployment](/assets/images/my-web.png)

## Monitoring Your Deployment with the minikube Dashboard

Although you can get a lot of information with `kubectl` commands, a more visual tool is helpful when you're getting started. Prepare to be amazed (or at least moderately pleased) by the minikube dashboard. At the command line, type:

```sh
minikube dashboard
```

Wait a few moments, and the dashboard should open automatically in your default browser. If that doesn't happen, you should at least see a link in your terminal:

![minikube dashboard](/assets/images/minikube-dashboard.png)

You'll get real-time information about your cluster. Also, you can tinker with your deployment and have a good look at what's happening behind the scenes.

![Workloads in minikube dashboard](/assets/images/minikube-dashboard-workloads.png)

The dashboard itself is simply a Kubernetes pod, which you can see by switching to the `kubernetes-dashboard` namespace.

![minikube dashboard](/assets/images/kubernetes-dashboard-namespace.png)

Namespaces are a way of isolating groups of resources within a cluster. In this case, it's keeping all the Kubernetes mechanisms where we can't accidentally delete them.

Let's scale things up so you can see what happens in the dashboard. At the command line type:

```sh
kubectl scale --replicas 3 deployment my-deploy
```

Do this in a new terminal window if you want to keep the dashboard running.

Hopefully, you'll now have three pods bobbing around in the dashboard (make sure you've selected *default* from the namespace drop-down at the top).

![scaling pods](/assets/images/scale-pods.png)

## Conclusion

That's a quick canter through a simple Kubernetes deployment. If you've finished for now, here are the steps for cleaning up:

- Delete your deployment: `kubectl delete deployment my-deploy`.
- Delete your service: `kubectl delete service my-deploy-np`.
- Stop minikube: `minikube stop`.

In a future post, I'll introduce some other useful minikube add-ons. And we'll look at some declarative Kubernetes manifests, too.







