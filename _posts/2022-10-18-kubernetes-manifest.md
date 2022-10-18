---
layout: single
title: Creating a Simple Kubernetes Manifest
date: 2022-10-18
category: Kubernetes
author_profile: true
share: true
---

In my previous post, I showed you how to create a Kubernetes deployment *imperatively* at the command line. Although this is a quick method, it's not a good choice for real-world scenarios. You need code that's properly documented and version controlled. Now we're going to use a *declarative* approach.

In this tutorial, I'll show you how to create a simple Kubernetes deployment with a manifest file. As before, I'll be using minikube on my local machine. [Hop over to that previous tutorial](https://www.catherinepope.com/kubernetes/2022/08/28/kubernetes-minikube.html) if you need instructions on installing minikube and related tools.

## What is a Kubernetes manifest?

The manifest describes the resources you want to create, and how you want those resources to run inside your Kubernetes cluster. Resources include deployments, services, and pods. Through this manifest, you interact with the underlying Kubernetes API.

A Kubernetes manifest can be written in either YAML or JSON. For this example, we'll use YAML.

## Creating a Kubernetes manifest

Let's take a look at a relatively simple manifest:

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-web
spec:
  selector:
    matchLabels:
      app: my-web
  template:
    metadata:
      labels:
        app: my-web
    spec:
      containers:
      - name: my-container
        image: catherinepope/my-web
```

`apiVersion` specifies the API group you want to use for creating your resource, along with its version. Kubernetes API are organised in groups, according to their purpose.

`kind` is the resource type you're creating. In this case, it's a `Deployment`. 

`metadata` is for applying labels to your resource. As you'll see in a moment, this is helpful for grouping together resources. I'm giving my Deployment the name `my-web`.

Within `spec`, you define what your Deployment will do. First, with `selector` you reuse that metadata to `matchLabels`. This means Kubernetes can easily link together resources with the same label of `my-web`.

In `template`, you provide a specification for any Pods created by this Deployment. Again, we're adding a `my-web` label to ensure these Pods are identifiable and linkable. Then in the `spec` field, we're defining the container. The `name` is used by Docker, and the `image` is the image you want to use.

Although this is a basic example and won't do anything exciting, we can still give it a try.

## Applying a Kubernetes manifest

If you have minikube running, you can apply the manifest file we just explored. 

Create a file called `my-deployment.yaml` and paste the code from above.

Making sure you're in the same directory as your `my-deployment.yaml` file, type the following command at the prompt:

```shell
kubectl apply -f my-deployment.yaml
```

Here, you're using kubectl to apply that YAML file. The `-f` stands for file.

You should see a message to say that your Deployment was created.

![Deployment created](/assets/images/deployment-created.png)

Open your minikube dashboard with the `minikube dashboard` command for proof that your Deployment lives. You'll find a solitary pod within your `my-web` Deployment.

![Deployment in minikube](/assets/images/minikube-deployment.png)

## Updating a Kubernetes manifest

You probably wouldn't bother with a Deployment for just one Pod. The advantage of a Deployment is that it's easier to manage multiple Pods. Let's scale up our Deployment and see what happens.

Open your `my-deployment.yaml` file and update the `spec` section. Above the `selector` field, add `replicas: 3`. It should look like this:

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-web
```

Now apply your manifest again with the same command as before:

```shell
kubectl apply -f my-deployment.yaml
```
You should see a message confirming that your deployment has been configured. Then two additional Pods will be visible in the minikube dashboard:

![Additional Pods](/assets/images/minikube-pods.png)

As you'll see, the Pod names all begin with `my-web`, so we can easily identify them. And they also share a label of `my-web`, which we applied through the `metadata` field.

## Deleting a Kubernetes Deployment

Once you're finished with experimenting, you can remove your Deployment with the following command:

```shell
kubectl delete -f my-deployment.yaml
```

All gone!

![Pods gone!](/assets/images/pods-gone.png)

## Conclusion

In this tutorial, you've seen how to create, update, and delete a simple Kubernetes manifest. Next time, we'll make it more sophisticated by adding a manifest for a Kubernetes Service. Then you'll have something more exciting to look at.

I hope you enjoy your Kubernetes adventures in the meantime.