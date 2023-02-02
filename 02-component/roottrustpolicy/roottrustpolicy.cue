roottrustpolicy: {
	alias: ""
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "admin.gloo.solo.io/v2"
		kind:       "RootTrustPolicy"
	}
	description: ""
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "admin.gloo.solo.io/v2"
		kind:       "RootTrustPolicy"
		metadata: {
			name:      context.name
			namespace: "gloo-mesh"
		}
		spec:
			applytoMeshes: parameter.applyToMeshes
			config: {
				agentCa: parameter.config.agentCa
				autoRestartPods: parameter.config.autoRestartPods
				mgmtServerCa: parameter.mgmtServerCA
				intermediateCertOptions: parameter.intermediateCertOptions
			}
	}
	outputs: {}
	parameter: {
		applyToMeshes?: [...]
		config:
			agentCa?: {...}
			autoRestartPods: *true | bool
			mgmtServerCA:
				generated: {...}
				secretRef?: {...}
			intermediateCertOptions: {...}

	}
}