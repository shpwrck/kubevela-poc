# KUBEVELA & GLOO MESH

## Background

This repository displays how to leverage kubevela and gloo-mesh. By leveraging both tools, an application developer can create federated and resilient services with minimal configuration.

## Prerequisites

__Mandatory__: kubectl, helm, k3d, vela

__Optional__: istioctl, meshctl, k9s

## Steps

Setup:
```bash
# Takes approximately 4min on my 8by32 WSL2 instance
./00-setup/deploy.sh
```

Kubevela Install:
```bash
# Takes approximately 6min on my 8by32 WSL2 instance
./01-kubevela/deploy.sh
```

## Approaches

### Naive Approach

Apply Resource Wrappers
```bash
for dir in ./02-component/*/;
do 
  KUBECONFIG=~/.k3d/kubeconfig-mgmt.yaml kubectl apply -f ${dir}component.yaml
done
```

### Informed Approach

Add Example Service to Mesh
```bash
KUBECONFIG=~/.k3d/kubeconfig-mgmt.yaml kubectl apply -f ./02-resources/service-mesh-trait.yaml
KUBECONFIG=~/.k3d/kubeconfig-mgmt.yaml kubectl apply -f ./02-resources/application.yaml
```

## Sample Application

To deploy the example application with gloo mesh resources:
```bash
KUBECONFIG=~/.k3d/kubeconfig-mgmt.yaml kubectl apply -f sample/orig/mgmt/
KUBECONFIG=~/.k3d/kubeconfig-cluster1.yaml kubectl apply -f sample/orig/cluster1/
KUBECONFIG=~/.k3d/kubeconfig-cluster2.yaml kubectl apply -f sample/orig/cluster2/
```

You can test the application in a browser [here](http://localhost:8080)