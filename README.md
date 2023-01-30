# KUBEVELA & GLOO MESH

## Background

This repository displays how to leverage kubevela and gloo-mesh. By leveraging both tools, an application developer can create federated and resilient services with minimal configuration.

# Prerequisites

__Mandatory__: kubectl, helm, k3d, vela

__Optional__: istioctl, meshctl, k9s

## Steps

Setup:
```bash
./00-setup/deploy.sh
```

Kubevela Install:
```bash
# Still incomplete
./01-kubevela/deploy.sh
```

Add Example Service to Mesh
```bash
KUBECONFIG=~/.k3d/kubeconfig-mgmt.yaml kubectl apply -f ./02-resources/service-mesh-trait.yaml
KUBECONFIG=~/.k3d/kubeconfig-mgmt.yaml kubectl apply -f ./02-resources/application.yaml
```
