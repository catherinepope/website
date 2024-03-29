---
layout: single
title: Networking in Docker
permalink: /docker/networking/
toc: true
---

## Overview

Docker networking is based on an open source pluggable architecture called the Container Network Model (CNM). 

`libnetwork` is Docker's real-world implementation of the CNM and it provides all Docker's core networking capabilities. Drivers plug into `libnetwork` to provide specific network topologies.

`libnetwork` provides a native service discovery and basic container load balancing solution.

At the highest level, Docker networking comprises three major components:

- The Container Network Model (CNM)
- `libnetwork`
- Drivers (to extend the model)

## The Container Network Model (CNM)

The Container Network Model (CNM) defines three major building blocks:

- Sandboxes
- Endpoints
- Networks

![Container Network Model](./../../assets/images/cnm.png)

A **sandbox** is an isolated network stack containing all the networking components associated with a single container. It includes ethernet interfaces, ports, routing tables, and DNS config. Sandboxes are placed inside containers to provide network connectivity.

**Endpoints** are virtual network interfaces (e.g. `veth`). In the CNM, it's the job of the endpoint to connect a sandbox to a network. Endpoints can only connect to a single network. If a container needs to connect to multiple networks, it needs multiple endpoints.

**Networks** are a software implementation of a switch. They group together and isolate a collection of endpoints that need to communicate.

- **Network Driver**: handles the actual implementation of CNM concepts.
- **IP Address Management (IPAM)**: automatically allocates subnets and IP addresses for networks and endpoints.

On Linux, Docker manipulates `iptables` rules to provide network isolation. 

## Drivers

Drivers implement the data plane. Connectivity, isolation, and network creation are all handled by drivers.

Docker ships with built-in drivers (also known as Native Network Drivers):

- Host
- Bridge
- overlay - when you initialize a swarm, Docker creates an ingress network that uses the overlay driver by default.
- MACVLAN (Swarm)
- None

Drivers are like a template for the network, featuring specific behaviours and features.

Each driver is in charge of the creation and management of all resources on the networks for which it's responsible.

`libnetwork` allows multiple network drivers to be active at the same time.

A container can join multiple networks.

When you install Docker, you get three default networks installed. You can see them using the `docker network ls` command:

- bridge
- host
- none

These built-in networks can't be removed.

### Host Networks

With the host network driver, containers use the host's networking resources directly.

![Host Network](./../../assets/images/host-network.png)

There are no sandboxes: all containers on the host share the same network namespace. No two containers can use the same port.

These restrictions mean host networks are suitable only for situations where you need to run one or two containers on a single host.

### Single-Host Bridge Networks

Docker creates single-host bridge networks with the built-in bridge driver. This is the simplest network type.

The bridge only exists on a single Docker host and can only connect containers on the same network on the same host.

![Bridge Network](./../../assets/images/bridge-network.png)

Every Docker host gets a default single-host bridge network called `bridge0`. This is the network to which all new containers are connected, unless you override it on the command line with the `--network` flag.

Only one sub-network can be created on the default bridge network.

A bridge network is suitable for isolated networking between containers on a single host.

The following command shows how to create a network with the bridge driver:

`docker network create --driver bridge my-bridge-net`

And now you can attach a container to it:

`docker run -d --name bridge_nginx --network my-bridge-net nginx`

You can reference other containers on the same bridge network simply by using their name. For example, here the `bridge_busybox` container is running a curl command on the `bridge_nginx` container on the same bridge network:

`docker run --name bridge_busybox --network my-bridge-net radial/busyboxplus:curl curl bridge_nginx:80`

You can use `EXPOSE` together with `--publish-all` to make containers on the bridge network accessible outside of the host.

### Multi-Host Overlay Networks

Overlay networks allow a single network to span multiple hosts so containers on different hosts can communicate directly. 

![Overlay Network](./../../assets/images/overlay-network.png)

An overlay network is created by default when you use Docker Swarm.

Overlay networks are first created on the manager nodes. They are created on worker nodes once a task is scheduled on that specific worker node.

The following command shows how to create a network with the overlay driver:

`docker network create --driver overlay my-overlay-net`

And now you can join a service to the network:

`docker service create --name overlay_nginx --network my-overlay-net nginx`

If you want to encrypt the data plan, you add the` -o encrypted` flag to the command.

By default, Docker overlay networks encrypt cluster management traffic, but not application traffic. You must explicitly enable encryption of application traffic.

Control plane traffic is *cluster management traffic*, whereas data plane traffic is *application traffic*.

You only see overlay networks on worker nodes when they are tasked with running a container on it. This reduces network gossip!

You need the following ports open to traffic to and from each Docker hots participating in an overlay network:

- TCP port 2377 for cluster management communications.
- TCP and UDP port 7946 for communication between nodes.
- UDP port 4789 for overlay network traffic.

#### Attaching a Service to an Overlay Network

To attach a service to a network, use:

`docker service create --name <service-name> --network <network-name> --replicas 2 <image-name>`

Standalone containers that are not part of a Swarm service cannot attach to overlay networks unless they have the attachable property. For example:

`docker network create -d overlay --attachable <network-name>`

### MACVLAN Networks

The built-in MACVLAN driver makes containers first-class citizens on existing physical networks by giving each one its own MAC address and IP address.

![MACVLAN](./../../assets/images/macvlan.png)

Due to the security requirements, MACVLAN is ideal for corporate data center networks, but probably wouldn't work in the public cloud. It mainly used where there's a need for extremely low latency.

When you create a MACVLAN network, it can be in:

- Bridge mode
- 802.1q trunk bridge mode.

### None Driver

`None` provides no networking implementation. The container is completely isolated from other containers and the host. Although `none` does create a separate networking namespace for each container, there are no interfaces or endpoints. If you want networking, you have to set up everything yourself. 

![None](./../../assets/images/none.png){: .align-center}

## Service Discovery

Service discovery (part of `libnetwork`) allows all containers and Swarm services to locate each other by name. The only requirement is that they are on the same network.

*The default bridge network doesn't support name resolution, only user-defined bridge networks.*

Every Swarm service and standalone container started with the `--name` flag registers its name and IP with the Docker DNS service.

Although containers on bridge networks can only communicate with other containers on the same network, you can get around this with port mappings.

Port mappings let you map a container to a port on the Docker host. Any traffic hitting the Docker host on the configured port is directed to the container.

You can find a container's port with the following command:

`docker container port <container-name>`

Only a single container can bind to any port on the host. This means no other containers on that host can bind to that specific port. This is one of the reasons why single-host bridge networks are only useful for local development and very small applications.

## Ingress Load Balancing

Docker Swarm supports two publishing modes that make services accessible outside of the cluster:

- **Ingress mode** (default) - accessible from any node in the Swarm, even nodes not running a service replica. Using a routing mesh, the published port listens on every node in the cluster and transparently directs incoming traffic to any task that is part of the service, on any node.
- **Host mode** - accessible only by hitting nodes running service replicas. Traffic to the published port on the node goes directly to the task running on that specific node. You can't have multiple replicas on the same node if you use a static port.
  
You need to use long-form syntax for host mode. For example:

`docker service create -d --name svc1 --publish published=5000,target=80,mode=host nginx`

`published=5000` makes the service available externally via port 5000.

`target=80` ensures external requests to the published port are mapped back to port 80 on the service replicas.

`mode=host` ensures external requests only reach the service if they come in via nodes running a service replica.

You'd normally use **ingress mode**. Behind the scenes, ingress mode uses a Layer 4 routing mesh.

## Configuring Docker to Use External DNS

You can change the default for the host with the `dns` setting in `etc/daemon.json`:

``` json
{
    "dns": ["8.8.8.8"]
}
```

Or use the following command to run a container with a custom external DNS:

`docker run --dns DNS_ADDRESS`

## Assigning a Static IP Address to a Container

*This is a random question that popped up in a test exam!*

A static IP address can be allocated only on a custom network. You would need to create that network first. For example:

``` sh
docker network create --subnet=172.18.0.0/16 my-net

docker run --net my-net --ip 172.18.0.22 -it ubuntu bash
```

## Network Commands

To list networks:

`docker network ls`

To inspect a network:

`docker network inspect <network-name>`

To create a network:

`docker network create -d <network-type> <network-name>`

Attach a new container to a network:

`docker container run -d --name c1 --network localnet alpine`

Attach an existing container to a network:

`docker network connect <network-name> <container-name>`

To remove a container from a network:

`docker network disconnect <network-name> <container-name>`

You can also create a network alias for a container. This means it can be referenced by a different name in the network to which you're connecting it:

`docker run --name disguise --network my-bridge --net-alias=undercover`

To remove a network:

`docker network rm <network-name>`

You can find a container's IP address with the following command:

{% raw %}

`docker container inspect --format "{{ .NetworkSettings.IPAddress}}" <container-name>`

{% endraw %}

## Using Network Aliases

You can use network aliases to assign additional names to containers. Multiple containers can share a network alias, which provides a very basic load balancing solution.

For example:

``` bash
$ docker network create my-net
$ docker container run -d net my-net --net-alias search elasticsearch: 2
$ docker container run -d net my-net --net-alias search elasticsearch: 2
```

The example above creates a network, then runs two containers on that network, both sharing the network alias `search`.

Now run another container on the same network to perform an nslookup on `search`:

`docker container run --rm --net my-net alpine:3.10 nslookup search`

You'll see both containers:

![nslookup on network alias](./../../assets/images/net-alias.png)

Now run another container to perform a curl command on `search`:

`docker container run --rm --net my-net centos curl -s search:9200`

And then run it again.

The first time it shows one container; the second time the other container:

![DNS round robin](./../../assets/images/round-robin.png)

It's flipping between the containers sharing the network alias `search`. This is entirely random, though - it's not a proper load balancer. 



## Network Troubleshooting

You can view the container logs:

`docker logs <container-name>`

Or the service logs:

`docker service logs <service-name>`

Or the Docker logs:

`journalctl -u docker`

Alternatively, Netshoot is an image that comes with a variety of network troubleshooting tools. You can insert it into another container with the following command:

`docker run --rm --network container:custom-net-nginx nicolaka/netshoot curl localhost:80`

With the command above, you're inserting a container into the sandbox of another container.