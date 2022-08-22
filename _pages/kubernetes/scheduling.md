---
layout: single
title: Scheduling in Kubernetes
permalink: /kubernetes/scheduling/
toc: true
---

In Kubernetes, scheduling refers to selecting a node on which to run a workload. Scheduling is handled by the **Kubernetes Scheduler**.

## Node Taints

Node taints control which pods are allowed to run on which nodes. Pods can include tolerations, which override taints for that specific pod.

Each taint has an **effect**:

If a pod doesn't have the appropriate toleration, the **NoExecute** effect:

- Prevents new pods from being scheduled on the node.
- Evicts existing pods.

## Resource Requests

In the container spec, you can specify **resource requests** for resources such as memory and CPU.

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
  - name: frontend
    image: busybox
    resources:
      requests:
        memory: 64mi
        cpu: 250m
```
The scheduler then avoids scheduling pods on nodes that lack the necessary resources to satisfy the requests.