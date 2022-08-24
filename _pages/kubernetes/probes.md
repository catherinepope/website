---
layout: single
title: Kubernetes Probes
permalink: /kubernetes/probes/
toc: true
---

Probes allow you to customize how the Kubernetes cluster determines the state of each container.

**Liveness Probes** check whether the container is healthy. For example:

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 3
      periodSeconds: 3
```

**Readiness Probes** check whether the container is ready to service user requests. For example:

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 3
      periodSeconds: 3
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 3
      periodSeconds: 3
```
Services use these probes to determine pod health and restart containers, where necessary.

A readiness probe is useful in the following scenarios:

- If your container needs to load a lot of data during startup.
- If you want to only send traffic to a Pod when a probe succeeds.
- If you want your container to be able to take itself down for maintenance.