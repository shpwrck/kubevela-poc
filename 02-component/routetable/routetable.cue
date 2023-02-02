routetable: {
	alias: ""
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "networking.gloo.solo.io/v2"
		kind:       "RouteTable"
	}
	description: ""
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "networking.gloo.solo.io/v2"
		kind:       "RouteTable"
		metadata: {
			name:      context.name
			namespace: context.namespace
		}
		spec: {
			http: parameter.http
			if parameter["defaultDestination"] != _|_ {
				defaultDestination: parameter.defaultDestination
			}
			if parameter["hosts"] != _|_ {
				hosts: parameter.hosts
			}
			if parameter["virtualGateways"] != _|_ {
				virtualGateways: parameter.virtualGateways
			}
			if parameter["weight"] != _|_ {
				weight: parameter.weight
			}
			if parameter["workloadSelectors"] != _|_ {
				workloadSelectors: parameter.workloadSelectors
			}
		}
	}
	outputs: {}
	parameter: {
		defaultDestination?: {...}
		hosts?: [...string]
		http: [...{...}]
		virtualGateways?: [...{...}]
		weight?: int
		workloadSelectors?: [...]
	}
}
