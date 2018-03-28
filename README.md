# Docker Compose Deploy

A simple tool to deploy on multiple hosts using docker-compose
and Consul

## Requirements

* [docker-compose](https://docs.docker.com/compose)
* [consul](https://consul.io)

Optional but really usefull to have loadbalanced services and service discovery

* [registrator](https://gliderlabs.com/registrator/latest/user/quickstart/)
* [fabio](https://fabiolb.net/)

## When

You have Consul deployed on all your hosts and you are already using
it to perform service discovery and/or central configuration of your
applications. You don't need advanced features of a real cluster
orchestrator like [Nomad](https://nomadproject.io), [Kubernetes](kubernetes.io)
or [Swarm](https://docs.docker.com/engine/swarm/).

## This tool

The deploy tool is a bash script that act in client/server mode: the server has to
be run on each node where you want to deploy, the client is invoked
interactively from one of the nodes of the cluster (can be a specialized
node for testing or for deployments) or a remote node outside the cluster
(anywhere the consul API is reachable)

## Walkthrough

One-time-setup on the cluster of docker nodes with consul installed:
  - create the basic configuration for all the deployments:
  ```
  $ consul kv put deploy/config/path '/srv'
  $ consul kv put deploy/jobs/nodes/$HOSTNAME
  $ consul kv put deploy/jobs/nodes/everynode
  ```

To deploy to multiple nodes with a single client invocation (cluster deployment)
you need to have that all the nodes has a common prefix:
  ```
  $ consul kv put deploy/jobs/groups/<prefix>
  ```

On EC2 for example you can use a prefix like docker-<last-4-chars-of-instance-id>,
so your hosts has names like docker-4j7s docker-25d0 etc...
  ```
  $ consul kv put deploy/jobs/groups/docker
  ```

Run the script in server mode:
```
$ docker run -d \
    --restart=unless-stopped \
    --volume /var/run/docker.sock:/var/run/docker.sock:rw \
    docker-deploy:stable server
```


On your computer:
  - point to one of the consul nodes:
  ```
  $ export CONSUL_HTTP_ADDR http://1.2.3.4:8500
  ```

  - prepare a `docker-compose.yml` file: add a label SERVICE_NAME to at least
    one of the services, the first of them will be used to give a name to then
    app deployed.

  - from the same directory where the compose files resides
  ```
  $ deploy <node_name|cluster_name|everynode>
  ```
