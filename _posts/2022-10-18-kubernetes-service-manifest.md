---
layout: single
title: Creating a Kubernetes Service Manifest
date: 2022-10-18
category: Kubernetes
author_profile: true
share: true
---

Last time, we [created a simple manifest](https://www.catherinepope.com/kubernetes/2022/10/18/kubernetes-manifest.html) to launch a Kubernetes deployment. Although we found a Pod lurking in minikube dashboard, we couldn't actually see anything interesting.

In this tutorial, we'll extend that manifest to include a Service and make the app available through a web browser.

As before, you'll need minikube and associated tools, all of which are [detailed in an earlier post](https://www.catherinepope.com/kubernetes/2022/08/28/kubernetes-minikube.html).

## Exposing your Pod

To make the Pod containing the app visible, you need to expose the container's port. This involves a small addition to the original manifest file:


``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-web
spec:
  selector:
    matchLabels:
      app: my-webster
  template:
    metadata:
      labels:
        app: my-web
    spec:
      containers:
      - name: my-web
        image: catherinepope/my-web
        ports:
        - containerPort: 80
```

Under `containers` in your `my-deployment.yaml` file, add:

``` yaml
        ports:
        - containerPort: 80
```

And make sure it's aligned with `image`.

If you're using a different image, you'll need to find the port number. This will be documented in Docker Hub, or from whichever source you've pulled your image.

The Pod (and the container within it) is now accessible, but we need to connect it to a Kubernetes Service before it's visible.

## Creating a Kubernetes Service

As with the Deployment, we'll use a manifest to create our Service. Although we could make and apply separate files, it's neater to keep everything together. You can include multiple manifests in one YAML file, simply by separating them with three dashes.

First add those three dashes to your `my-deployment.yaml` file. Then copy and paste the Service manifest. The additions to your YAML file look like this:

``` yaml
---

apiVersion: v1
kind: Service
metadata:
  name: my-web
spec:
  selector:
    app: my-web
  ports:
  - port: 80
    nodePort: 30080
  type: NodePort

```

Most of this manifest will look familiar from last time. However, now `kind` is `Service`, rather than `Deployment`. The `metadata` and `selector` remain the same, as we want to link this Service with our Deployment. 

Under `ports`, there are two entries. First, the container `port` we specified in the Deployment manifest, then the `nodePort`. The `nodePort` makes your application available outside the Kubernetes cluster. You can choose any number in the range 30000-32767, provided it's not already in use. Finally, we specify the port type of `NodePort`.

Nearly there.

## Launching your web app

We're almost ready to launch the web app. 

First, make sure minikube is running (use `minikube start` if it's not). 

Then, if you haven't done so already, enable ingress:

``` shell
minikube addons enable ingress
```

You'll also need your cluster's IP address. You can get this with the `minikube ip` command.

Now you can apply your manifest containing the Deployment and Service. In the same directory as your `my-deployment.yaml` file, type the following command:

``` shell
kubectl apply -f my-deployment.yaml
```

You should see that your Deployment and Service have been created:

![Deployment and Service created](/assets/images/service-created.png)

Open your web browser, then paste your minikube IP address, a colon, and the NodePort number. For example: 192.168.64.27:30080.

If you're using my Docker image, you'll get a random picture:

![Web app from Kubernetes manifest](/assets/images/nodeport-web.png)

Keep clicking refresh for some moderate fun.

To delete your Deployment and Service, use the following command:

``` shell
kubectl delete -f my-deployment.yaml
```

## Conclusion

In this tutorial, you've included multiple manifests in one YAML file to deploy a web app. In my next post, I'll explain how you can package a Kubernetes-based app with a tool called Helm.
