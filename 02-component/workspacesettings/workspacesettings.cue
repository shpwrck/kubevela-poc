workspacesettings: {
	alias: ""
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "admin.gloo.solo.io/v2"
		kind:       "WorkspaceSettings"
	}
	description: ""
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "admin.gloo.solo.io/v2"
		kind:       "WorkspaceSettings"
		metadata: {
			name:      context.name
			namespace: context.namespace
		}
		spec: {
			exportTo: parameter.exportTo
			importFrom: parameter.importFrom
			options: parameter.options
		}
	}
	outputs: {}
	parameter: {
		exportTo: *[] | [...]
		importFrom: *[] | [...]
		eastWestGateways: *[] | [...]
		options: federation: enabled: *false | bool
		options: serviceIsolation: enabled: *true | bool
		options: serviceIsolation: trimProxyConfig: *true | bool
	}
}