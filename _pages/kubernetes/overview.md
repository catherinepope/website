---
layout: single
title: Kubernetes Overview
permalink: /kubernetes/overview/
toc: true
---

Docker Kubernetes Service allows you to orchestrate container workloads in UCP using Kubernetes. Each UPC node has an **orchestrator type** which determines whether the node runs workloads managed by Docker Swarm or Kubernetes. There's also a **mixed** mode, which is not recommended for production use.

You can also run a single-node Kubernetes cluster through Docker Desktop.

## Kubernetes Components

- **kubectl** - CLI tool to configure and manage Kubernetes.
- **Node** - a single server in a Kubernetes cluster (sometimes referred to as a *worker*).
- **kubelet** - Kubernetes agent running on nodes.
- **Control Plane** - set of containers that manages the cluster. Includes API server, scheduler, controller manager, etcd, and CoreDNS.

## Kubernetes Concepts

- **Pod** - one or more containers running together on one Node. This is the basic unit of deployment. 
- **Controller** - used for creating/updating pods and other objects. Controllers include:
  - Deployment
  - ReplicaSet
  - StatefulSet
  - DaemonSet
- **Service** - network endpoint to connect to a pod.
- **Namespace** - filtered group of objects in a cluster.