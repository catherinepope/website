---
layout: single
title: Networking in Kubernetes
permalink: /kubernetes/networking/
toc: true
---

## Overview

### Kubernetes Network Model

A pod can reach any other pod using that pod's IP address. This creates a virtual network that allows pods to easily communicate with each other, regardless of which node they're on.

## Service Types

Each service has a type. The type determines the behavior of the service and what it can be used for:

- **ClusterIP** (the default) - exposes to pods *within the cluster* using a unique IP on the cluster's virtual network.
- **NodePort** - exposes the service *outside the cluster* on each Kubernetes node, using a static port.
- **LoadBalancer** - exposes the service *externally*, using a cloud provider's load balancing functionality.
- **ExternalName** - exposes an external resource *inside the cluster network* using DNS.

## Cluster DNS

Kubernetes includes a cluster DNS that helps containers locate Services using domain names. 

Pods *within the same namespace* as a service can simply use the service name as a domain name.

Pods in a different namespace must use the full domain name, which takes the form:

`my-svc.my-namespace.svc.cluster-domain.example`

The default is `.cluster.local`.