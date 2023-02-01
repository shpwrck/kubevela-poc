#!/usr/bin/env bash
set -Eeuo pipefail
GLOO_PLATFORM_VERSION=v2.2.1

# Cleanup any previous runs
k3d cluster delete --all
if [ "$(docker network ls | grep gloo-mesh-network)" ]; then
  docker network rm gloo-mesh-network
fi

# Create Infrastructure
docker network create gloo-mesh-network
k3d cluster create --config ./00-setup/infra/k3d-mgmt.yaml
k3d cluster create --config ./00-setup/infra/k3d-cluster1.yaml
k3d cluster create --config ./00-setup/infra/k3d-cluster2.yaml

# Write KUBECONFIGs
MGMT=$(k3d kubeconfig write mgmt)
CLUSTER1=$(k3d kubeconfig write cluster1)
CLUSTER2=$(k3d kubeconfig write cluster2)

# Rename Contexts
KUBECONFIG=$(k3d kubeconfig write mgmt) kubectl config rename-context k3d-mgmt mgmt
KUBECONFIG=$(k3d kubeconfig write cluster1) kubectl config rename-context k3d-cluster1 cluster1
KUBECONFIG=$(k3d kubeconfig write cluster2) kubectl config rename-context k3d-cluster2 cluster2

# Add Helm Repos
helm repo add gloo-mesh-enterprise https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-enterprise
helm repo add gloo-mesh-agent https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-agent
helm repo update

#Install Gloo Mesh Management Plane
helm upgrade --install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise \
  --version=${GLOO_PLATFORM_VERSION} \
  --set licenseKey=${GLOO_MESH_LICENSE_KEY} \
  --set global.cluster=mgmt \
  --set glooMeshUi.serviceType=LoadBalancer \
  --set glooMeshUi.serviceOverrides.spec.ports[0].name=console \
  --set glooMeshUi.serviceOverrides.spec.ports[0].port=80 \
  --set glooMeshUi.serviceOverrides.spec.ports[0].targetPort=8090 \
  --set legacyMetricsPipeline.enabled=false \
  --set metricsgateway.enabled=true \
  --kubeconfig ${MGMT} \
  --namespace gloo-mesh \
  --create-namespace \
  --wait

# Create Cluster Resources in Gloo Mesh Management Plane
kubectl apply --kubeconfig $MGMT -f- <<EOF
apiVersion: admin.gloo.solo.io/v2
kind: KubernetesCluster
metadata:
  name: cluster1
  namespace: gloo-mesh
spec:
  clusterDomain: cluster.local
---
apiVersion: admin.gloo.solo.io/v2
kind: KubernetesCluster
metadata:
  name: cluster2
  namespace: gloo-mesh
spec:
  clusterDomain: cluster.local
EOF

# Gather Gloo Mesh Management Plane Service Information
MGMT_SERVER_NETWORKING_DOMAIN=$(kubectl get svc -n gloo-mesh gloo-mesh-mgmt-server --kubeconfig ${MGMT} -o jsonpath='{.status.loadBalancer.ingress[0].*}')
MGMT_SERVER_NETWORKING_PORT=$(kubectl -n gloo-mesh get service gloo-mesh-mgmt-server --kubeconfig ${MGMT} -o jsonpath='{.spec.ports[?(@.name=="grpc")].port}')
MGMT_SERVER_NETWORKING_ADDRESS=${MGMT_SERVER_NETWORKING_DOMAIN}:${MGMT_SERVER_NETWORKING_PORT}
echo $MGMT_SERVER_NETWORKING_ADDRESS

# Create 
for cluster in $CLUSTER1 $CLUSTER2
do
  # Gather Connection Credentials
  kubectl create namespace gloo-mesh --kubeconfig $cluster
  kubectl get secret relay-root-tls-secret -n gloo-mesh --kubeconfig ${MGMT} -o jsonpath='{.data.ca\.crt}' | base64 -d > ./00-setup/ca.crt
  kubectl create secret generic relay-root-tls-secret -n gloo-mesh --kubeconfig $cluster --from-file ca.crt=./00-setup/ca.crt
  rm ./00-setup/ca.crt
  kubectl get secret relay-identity-token-secret -n gloo-mesh --kubeconfig ${MGMT} -o jsonpath='{.data.token}' | base64 -d > ./00-setup/token
  kubectl create secret generic relay-identity-token-secret -n gloo-mesh --kubeconfig $cluster --from-file token=./00-setup/token
  rm ./00-setup/token

  # Install Agent
  helm upgrade --install gloo-mesh-agent gloo-mesh-agent/gloo-mesh-agent \
    --kubeconfig=$cluster \
    --namespace gloo-mesh \
    --set relay.serverAddress=${MGMT_SERVER_NETWORKING_ADDRESS} \
    --set cluster=$(echo $cluster | grep -o 'cluster.') \
    --set relay.tokenSecret.name=relay-identity-token-secret \
    --set metricscollector.enabled=true \
    --set metricscollector.config.exporters.otlp.endpoint=172.19.0.3:4317 \
    --version ${GLOO_PLATFORM_VERSION} \
    --wait
done

# Install Istio and Gloo Mesh Resources
# kubectl --kubeconfig ${MGMT} apply -f ./00-setup/apps/

# PRINT KUBECONFIG COMMAND
echo "KUBECONFIG=$MGMT:$CLUSTER1:$CLUSTER2 k9s"
