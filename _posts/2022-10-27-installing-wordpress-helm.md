---
layout: single
title: Installing WordPress with Helm
date: 2022-10-27
category: Kubernetes
author_profile: true
share: true
---

One of the many advantages of Helm is that it gives you a one-command installation method for many popular apps. It would take a while to create all the necessary Pods, Services, and ConfigMaps manually.

In this tutorial, I'll guide you through a three-step process for installing WordPress with Helm. Although this isn't necessarily something you'd want to do in the real world, it's good for understanding the basics. I was *very* excited when I first got this working.

To follow the steps, you'll need:

- minikube
- kubectl
- Helm

If you've not used Helm before, please read [my previous post](https://www.catherinepope.com/kubernetes/2022/10/26/getting-started-helm.html) first. 

## Step 1 - Add the Repo

For this demo, we'll use Bitnami's WordPress Helm Chart. If you haven't done so already, you'll need to add the Bitnami repo with the following command:

``` sh
helm repo add bitnami https://charts.bitnami.com/bitnami
```

## Step 2 - Install the Helm Chart

Before you install the WordPress Chart, make sure the repo is up-to-date with the following command:

``` sh
helm repo update
```

Then run the `install` command:

``` sh
helm install my-blog bitnami/wordpress
```

You can replace `my-blog` with a name of your choice.

Now you should see confirmation that your WordPress release has been deployed:

![Helm release confirmation](/assets/images/my-blog-deployed.png)

You'll also get instructions on how to interact with your new WordPress installation.

## Step 3 - Access your WordPress site

To access your WordPress site, you'll need to know the number of the port on which it's served.

Run the following command to see the Kubernetes resources created by the Helm chart:

``` sh
kubectl get all
```

![Helm release confirmation](/assets/images/my-blog-loadbalancer.png)

There should be a LoadBalancer service called `service/my-blog-wordpress`. In this case, it has a port number of `30624`.

Then you'll need your minikube IP address, which you can retrieve with the following command:

`minikube ip`

Make sure you've enabled ingress with the `minikube addons enable ingress` command.

In my case, the full URL is http://192.168.64.27:30624. Paste the URL in your browser and you should see your WordPress site:

![WordPress frontend](/assets/images/wordpress-frontend.png)

To create posts or configure your site, you'll need to log in as an administrator. 

If you've used WordPress before, you'll know you need to append `/wp-admin` to the URL. The username is `user`, but you'll need to extract the password from a Kubernetes secret. Fortunately, the instructions in your terminal include a command to copy and paste:

![WordPress instructions](/assets/images/wordpress-instructions.png)

The command retrieves and decrypts the Kubernetes secret for you:

![WordPress password](/assets/images/wordpress-password.png)

Now you have full access to your WordPress site.

## Conclusion

In this tutorial, you've seen how Helm can help you install Kubernetes-based apps. Thanks to the Helm Chart, you had everything you needed to run WordPress locally: three Services, a Deployment, a ReplicaSet, and a StatefulSet.

Of course, it would be overkill to use Kubernetes for a simple WordPress site. If you wanted a local copy without installing everything, it would make more sense to use [Docker Compose](https://www.catherinepope.com/docker/docker-compose/). However, hopefully this gave you a familiar example for understanding Helm.

To keep it simple, we just used all the default values. If you're eager to start tinkering, take a look at [the Chart page](https://artifacthub.io/packages/helm/bitnami/wordpress) to see what you can configure. Otherwise, hold tight, and I'll guide you through it in my next post.

