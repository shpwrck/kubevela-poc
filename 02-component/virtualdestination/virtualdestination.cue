virtualdestination: {
	alias: ""
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "networking.gloo.solo.io/v2"
		kind:       "VirtualDestination"
	}
	description: ""
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "networking.gloo.solo.io/v2"
		kind:       "VirtualDestination"
		metadata: {
			name:      "checkout"
			namespace: "gloo-mesh"
		}
		spec: {
			hosts: parameter.hosts
			ports: parameter.ports
			services: parameter.services
		}
	}
	outputs: {}
	parameter: {
		clientMode?: {...}
		externalServices?: [...]
		hosts: [...string]
		ports:[...{}]
		services: [...{}]
	}
}
