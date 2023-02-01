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
			exportTo: [{
				resources: parameter.exportTo.resources
				workspaces: parameter.exportTo.workspaces
			}]
			importFrom: [{
				resources: parameter.importFrom.resources
				workspaces: parameter.importFrom.workspaces
			}]
			options: {
				eastWestGateways: parameter.eastWestGateways
				federation: enabled: parameter.federation.enabled
				serviceIsolation: {
					enabled:         parameter.serviceIsolation.enabled
					trimProxyConfig: parameter.serviceIsolation.trimProxyConfig
				}
			}
		}
	}
	outputs: {}
	parameter: {
		exportTo:
			resources: [...]
			workspaces: [...]
		importFrom:
			resources: [...]
			workspaces: [...]
		eastWestGateways: [...]
		federation: 
			enabled: *false | bool
		serviceIsolation: 
			enabled: *true | bool
			trimProxyConfig: *true | bool
	}
}
