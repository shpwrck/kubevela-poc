virtualgateway: {
	alias: ""
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "networking.gloo.solo.io/v2"
		kind:       "VirtualGateway"
	}
	description: ""
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "networking.gloo.solo.io/v2"
		kind:       "VirtualGateway"
		metadata: {
			name:      context.name
			namespace: context.namespace
		}
		spec: {
			listeners: parameter.listeners
			workloads: parameter.workloads
		}
	}
	outputs: {}
	parameter: {
        listeners: [...]
        workloads: [...]
    }
}
