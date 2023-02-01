kubernetescluster: {
	alias: ""
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "admin.gloo.solo.io/v2"
		kind:       "KubernetesCluster"
	}
	description: ""
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "admin.gloo.solo.io/v2"
		kind:       "KubernetesCluster"
		metadata: {
			name:      context.name
			namespace: "gloo-mesh"
		}
		spec: clusterDomain: "cluster.local"
	}
	outputs: {}
	parameter: {
		clusterDomain: *"cluster.local" | string
	}
}
