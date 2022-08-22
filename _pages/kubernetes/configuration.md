---
layout: single
title: Application Configuration in Kubernetes
permalink: /kubernetes/configuration/
toc: true
---

## Overview

Kubernetes uses ConfigMaps and Secrets to store configuration data and pass it to containers.

**ConfigMaps** allow you to store configuration data in a key/value format. 

**Secrets** are similar to ConfigMaps, but their data is encrypted at rest. Secrets are suitable for storing sensitive data, such as passwords and API tokens.

Configuration data stored in ConfigMaps or Secrets can be passed to containers in two ways:

- **Environment variables** - the values are then visible to the container process at runtime.
- **Volume mounts** - configuration data is mounted to the container file system, where it appears in the form of files.

This example shows a secret and a ConfigMap passed as environment variables:

``` yaml
apiVersion: v1
kind: Pod
metadata:
    name: my-pod
spec:
    containers:
    - name: busybox
      image: busybox
      env:
      - name: CONFIGMAPVAR
        valueFrom:
            configMapKeyRef:
                name: my-configmap
                key: key1
      - name: SECRETVAR
        valueFrom:
            secretKeyRef:
                name: my-secret
                key: username
```

And this example mounts a ConfigMap and a Secret as volumes:

``` yaml
    volumeMounts:
    - name: configmap-vol
      mountPath: /etc/configmap
    - name: secret-vol
      mountPath: /etc/secret
volumes:
- name: configmap-vol
  configMap:
    name: my-configmap
- name: secret-vol
  secret:
    secretName: my-secret
```