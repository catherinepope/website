---
layout: single
title: Docker and Kubernetes
permalink: /docker/kubernetes/
toc: true
---

## Overview

Kubernetes is an increasingly popular choice over [Docker Swarm](./../docker-swarm/). It's offered as a managed service by all the major public clouds. They take care of initializing the cluster (which is more complicated than in Docker Swarm) and managing the virtual machines that comprise the nodes. Kubernetes is easily extensible, so the cloud providers can integrate it with their other products, like load balancers and storage, which make it easy to deploy full-featured applications.

Kubernetes also offers more sophisticated options, including blue/green deployments and automatic service scaling.

Docker Swarm doesn’t exist as a managed service from the cloud providers. If you want to run a Docker Swarm cluster in the cloud, you’d need to provision the VMs and initialize the Swarm yourself. Although it could be automated, it’s not as simple as using a managed service.

If you’re deploying to the cloud, Kubernetes is a simpler option, but if you’re in the datacenter, Swarm is far easier to manage.

In the UCP, you can choose Swarm, Kubernetes, or Mixed. By default, the UCP uses Calico as the network for Kubernetes.

The TCP 179 ports is generally used for Kubernetes networking in UCP.

The primary modes for service discovery in Kubernetes are:

- DNS (the most common method).
- Environment variables injected by the kubelet when the pods are created.

## Creating Kubernetes manifests

1.  **apiversion:** - the version of the manifest file.
    
2. **kind:** - specifies the object type, for example, `pod`, `deployment`, `service`, `namespace`, `persistent volume`, `persistent volume claim`, or `storage class`.
    
3. **metadata:** - defines the label, for example, the name of the app. You can define more than one label for the object. Also, in metadata, you define the namespace name. A Kubernetes service uses labels as nametags to identify pods and it can query these labels for service discovering and load-balancing. 
    
4. **spec:** This is where the action is. In this top key, we define the replicas, the selector, and the template. Inside the template, we can define the image where the container will be crafted from, ports, and any other specifications to run the application correctly.

## Networking in Kubernetes
### Kubernetes Network Model

Every Pod in a cluster gets its own unique cluster-wide IP address. This means you do not need to explicitly create links between Pods and you almost never need to deal with mapping container ports to host ports. This creates a clean, backwards-compatible model where Pods can be treated much like VMs or physical hosts from the perspectives of port allocation, naming, service discovery, load balancing, application configuration, and migration.

## Security in Kubernetes

### ConfigMaps

You can write a Pod spec that refers to a ConfigMap and configures the container(s) in that Pod based on the data in the ConfigMap. The Pod and the ConfigMap must be in the same namespace.

Here's an example ConfigMap:

``` yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: game-demo
data:
  # property-like keys; each key maps to a simple value
  player_initial_lives: "3"
  ui_properties_file_name: "user-interface.properties"

  # file-like keys
  game.properties: |
    enemy.types=aliens,monsters
    player.maximum-lives=5    
  user-interface.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true    

```

There are four different ways that you can use a ConfigMap to configure a container inside a Pod:

- Inside a container command and args
- Environment variables for a container
- Add a file in read-only volume, for the application to read
- Write code to run inside the Pod that uses the Kubernetes API to read a ConfigMap

Here's an example of a Pod that mounts a ConfigMap in a volume:

``` yaml

apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: boo
      mountPath: "/etc/boo"
      readOnly: true
  volumes:
  - name: boo
    configMap:
      name: myconfigmap

```

### Secrets

A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. Such information might otherwise be put in a Pod specification or in a container image. Using a Secret means that you don't need to include confidential data in your application code.

Because Secrets can be created independently of the Pods that use them, there is less risk of the Secret (and its data) being exposed during the workflow of creating, viewing, and editing Pods. Kubernetes, and applications that run in your cluster, can also take additional precautions with Secrets, such as avoiding writing secret data to nonvolatile storage.

Secrets are similar to ConfigMaps but are specifically intended to hold confidential data.

Here's an example of a Secret:

``` yaml
apiVersion: v1
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: { ... }
  creationTimestamp: 2020-01-22T18:41:56Z
  name: mysecret
  namespace: default
  resourceVersion: "164619"
  uid: cfee02d6-c137-11e5-8d73-42010af00002
type: Opaque
```

And here's how you'd mount it in a Pod manifest:

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
  - name: foo
    secret:
      secretName: mysecret
      optional: false # default setting; "mysecret" must exist
```

Docker and Kubernetes can share secrets.

## Storage in Kubernetes

This is covered in [my Kubernetes notes](./../../kubernetes/storage/).