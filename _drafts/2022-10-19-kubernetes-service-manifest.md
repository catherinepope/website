---
layout: single
title: Creating a Kubernetes Service Manifest
date: 2022-10-18
category: Kubernetes
author_profile: true
share: true
---



``` YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-web
spec:
  replicas: 1
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
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80

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