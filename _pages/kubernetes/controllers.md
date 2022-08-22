---
layout: single
title: Kubernetes Controllers
permalink: /kubernetes/controllers/
toc: true
---

## Deployments

Deployments allow you to manage changes to a set of replica pods. They specify a desired state for those pods, and work to achieve and maintain that state, even if it's changed.

You can use deployments to perform rolling updates and scaling.

## DaemonSets

DaemonSets allow you to run a replica pod dynamically on each node in the cluster. They will also create replicas on new nodes as they are added.