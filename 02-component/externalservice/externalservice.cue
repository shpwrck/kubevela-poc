externalservice: {
	alias: ""
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "networking.gloo.solo.io/v2"
		kind:       "ExternalService"
	}
	description: ""
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "networking.gloo.solo.io/v2"
		kind:       "ExternalService"
		metadata: {
			name:      context.name
			namespace: context.namespace
		}
		spec: {
			if parameter["addresses"] != _|_ {
				addresses: parameter.addresses
			}
			if parameter["hosts"] != _|_ {
				hosts: parameter.hosts
			}
			ports: parameter.ports
			selector: parameter.selector
		}
	}
	outputs: {}
	parameter: {
        hosts?: [...string]
		addresses?: [...string]
		ports: [
			{
				name: string
				number: int
				protocol: string
				targetPort ?: {
					name: string
					number: int
				}
			}
		]
		selector: {...}
	}
}