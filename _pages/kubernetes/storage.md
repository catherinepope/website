---
layout: single
title: Storage in Kubernetes
permalink: /kubernetes/storage/
toc: true
---

## Mounting Volumes to Pods

In this Pod specification, you specify the storage volumes available to the Pod. 

You then reference those volumes in the *container* spec and provide a `mountPath`, the location on the file system where the container process will access the volume data:

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-pod
spec:
  containers:
  - name: busybox
    image: busybox
    volumeMounts:
    - name: my-volume
      mountPath: /output
  volumes:
  - name: my-volume
    hostPath:
      path: /data
```

You can use `volumeMounts` to mount the same volume to multiple containers within the same Pod. The mount path doesn't need to be the same. This allows containers to interact with each other inside the Pod:

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-pod
spec:
  containers:
  - name: busybox1
    image: busybox
    volumeMounts:
    - name: my-volume
      mountPath: /output
  - name: busybox2
    image: busybox
    volumeMounts:
    - name: my-volume
      mountPath: /input
  volumes:
  - name: my-volume
    emptyDir: {} # no value is required here, but YAML doesn't link blanks.
```

### Volume Types

- **hostPath**: stores data in a specified directory on the Kubernetes node.
- **emptyDir**: stores data in a dynamically created location on the node. This directory exists only as long as the Pod exists on the node. When the Pod is removed, the directory and the data are removed. This volume type is good for simply sharing data between two containers in the same Pod.

## PersistentVolumes

**PersistentVolumes** allow you to abstract storage resources. You define a set of available storage resources as a Kubernetes object, then later *claim* those storage resources for use by your Pods.

A cluster administrator can create a set of PersistentVolumes, each containing the volume specification for the underlying storage system.

PersistentVolumes can also be created on demand.

A **PersistentVolumeReclaimPolicy** determines what happens when the associated claims are deleted:

- **Retain** - keeps the volume and data and allows manual reclaiming. An administrator is then responsible for cleaning up existing data.
- **Delete** - deletes both the PersistentVolume and its underlying storage infrastructure (e.g. a cloud storage object).
- **Recycle** - deletes the data so the volume can be reused.

``` yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0003
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: slow
  mountOptions:
    - hard
    - nfsvers=4.1
  nfs:
    path: /tmp
    server: 172.17.0.2
```

## PersistentVolumeClaims

Pods claim storage through a **PersistentVolumeClaim** (PVC). Kubernetes matches the PVC to a PersistentVolume.

The PVC specification includes an access mode, storage amount, and storage class. If no storage class is specified, Kubernetes tries to find an existing PersistentVolume that satisfies the requirements of the claim.

``` yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 8Gi
  storageClassName: localdisk
```

If there's a match, the PVC is bound to the PV. Once a PV is claimed, it is no longer available for any other PVCs to use.

If there's no matching PV when you create a PVC, the claim is still created, but it's not usable. The Pod remains pending until a PV is created that satisfies its requirements. A PVC needs to be bound before a Pod can use it.

Pods access storage by using the claim as a volume. The cluster finds the claim in the Pod's namespace and uses it to get the PersistentVolume backing the claim. The volume is then mounted to the host and into the Pod.

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: my-pvc
```


## Storage Classes

For scaling storage, Kubernetes offer another object called *storage classes (SC)*. Storage Classes allow Kubernetes administrators to specify the types of storage services available on their platform. Storage classes then create PVs dynamically. Therefore, we don't need to define the PV individually. In this dynamic provisioning workflow, you just create the `PersistentVolumeClaim`, and the required `PersistentVolume` is created on demand by the cluster.

Clusters can be configured with multiple storage classes that reflect the different volume capabilities on offer, as well as a default storage class.

You can expand a `PersistentVolumeClaim` by simply specifying a larger size in the manifest. For this to work, the **storage class** must support volume expansion: **allowVolumeExpansion** should be set to `true`. This can be done without interrupting the applications that are using them.

For example:

``` yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: localdisk
provisioner: kubernetes.io/glusterfs
allowVolumeExpansion: true
persistentVolumeReclaimPolicy: Recycle

```

`PersistentVolumeClaims` can specify a storage class. If none is specified, the default is used. If you specify a storage class that doesn't exist, it's created automatically for you (although it won't have `allowVolumeExpansion` set to `true`).