#!/usr/bin/env bash
set -Eeuo pipefail
MGMT=$(k3d kubeconfig write mgmt)
CLUSTER1=$(k3d kubeconfig write cluster1)
CLUSTER2=$(k3d kubeconfig write cluster2)

for cluster in $CLUSTER1 $CLUSTER2
do
  kubectl apply --kubeconfig $cluster -f ./01-kubevela/crds/
done

KUBECONFIG=$MGMT vela install --set featureGates.preDispatchDryRun=false
KUBECONFIG=$MGMT kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.5.1" | kubectl apply -f -;
KUBECONFIG=$MGMT vela addon enable cert-manager
KUBECONFIG=$MGMT vela addon enable ocm-hub-control-plane
KUBECONFIG=$MGMT vela addon enable ocm-gateway-manager-addon

# Due to the constraints of k3d-networking this will not work.
#   KUBECONFIG=~/.k3d/kubeconfig-mgmt.yaml vela cluster join $CLUSTER1 -t ocm --name cluster1
#   KUBECONFIG=~/.k3d/kubeconfig-mgmt.yaml vela cluster join $CLUSTER2 -t ocm --name cluster2
#   >> Upate bootstrap-hub-kubeconfig with ip address of management node and port 6443
#   >> Confirm it works with `vela cluster probe cluster1`