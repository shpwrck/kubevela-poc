#!/usr/bin/env bash
set -Eeuo pipefail
MGMT=$(k3d kubeconfig write mgmt)
CLUSTER1=$(k3d kubeconfig write cluster1)
CLUSTER2=$(k3d kubeconfig write cluster2)

# Need to set default for some vela commands
echo "export KUBECONFIG=$KUBECONFIG"
export KUBECONFIG=$MGMT

for cluster in $CLUSTER1 $CLUSTER2
do
  KUBECONFIG=$cluster kubectl apply -f ./01-kubevela/crds/
done

KUBECONFIG=$MGMT vela install --set featureGates.preDispatchDryRun=false
KUBECONFIG=$MGMT kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.5.1" | kubectl apply -f -;

KUBECONFIG=$MGMT kubectl rollout status -n vela-system deployment/kubevela-cluster-gateway
KUBECONFIG=$MGMT kubectl rollout status -n vela-system deployment/kubevela-vela-core

KUBECONFIG=$MGMT vela addon enable cert-manager
KUBECONFIG=$MGMT vela addon enable ocm-hub-control-plane
KUBECONFIG=$MGMT vela addon enable ocm-gateway-manager-addon

MGMT_IP=$(docker inspect k3d-mgmt-server-0 -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
MGMT_B64=$(k3d kubeconfig get mgmt | sed -e "s/0.0.0.0:[0-9]*/$MGMT_IP:6443/g" | base64 -w0)

KUBECONFIG=$MGMT vela cluster join $CLUSTER1 -t ocm --name cluster1 > /dev/null 2> /dev/null &
until KUBECONFIG=$CLUSTER1 kubectl get secrets -n open-cluster-management-agent bootstrap-hub-kubeconfig;
do
  sleep 1
done
KUBECONFIG=$CLUSTER1 kubectl patch secret -n open-cluster-management-agent bootstrap-hub-kubeconfig --type='json' -p="[{\"op\" : \"replace\" ,\"path\" : \"/data/kubeconfig\" ,\"value\" : \"$MGMT_B64\"}]"
KUBECONFIG=$CLUSTER1 kubectl delete pods -n open-cluster-management-agent --all

KUBECONFIG=$MGMT vela cluster join $CLUSTER2 -t ocm --name cluster2 > /dev/null 2> /dev/null &
until KUBECONFIG=$CLUSTER2 kubectl get secrets -n open-cluster-management-agent bootstrap-hub-kubeconfig;
do
  sleep 1
done
KUBECONFIG=$CLUSTER2 kubectl patch secret -n open-cluster-management-agent bootstrap-hub-kubeconfig --type='json' -p="[{\"op\" : \"replace\" ,\"path\" : \"/data/kubeconfig\" ,\"value\" : \"$MGMT_B64\"}]"
KUBECONFIG=$CLUSTER2 kubectl delete pods -n open-cluster-management-agent --all

until KUBECONFIG=$MGMT kubectl get managedclusters cluster1 && KUBECONFIG=$MGMT kubectl get managedclusters cluster1
do
  sleep 1
done

KUBECONFIG=$MGMT vela cluster list