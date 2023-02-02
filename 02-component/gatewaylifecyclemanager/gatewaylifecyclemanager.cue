gatewaylifecyclemanager: {
	alias: ""
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "admin.gloo.solo.io/v2"
		kind:       "GatewayLifecycleManager"
	}
	description: ""
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "admin.gloo.solo.io/v2"
		kind:       "GatewayLifecycleManager"
		metadata: {
			name:      context.name
			namespace: "gloo-mesh"
		}
		spec: installations: parameter.installations
	}
	outputs: {}
	parameter: {
		installations: [...{
			clusters: [...{ name: string, activeGateway: *false | bool }]
			gatewayRevision: string
			controlPlaneRevision: string
			istioOperatorSpec: {...}
		}]
	}
}
