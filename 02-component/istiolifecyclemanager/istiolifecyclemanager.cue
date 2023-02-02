istiolifecyclemanager: {
	alias: ""
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "admin.gloo.solo.io/v2"
		kind:       "IstioLifecycleManager"
	}
	description: ""
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "admin.gloo.solo.io/v2"
		kind:       "IstioLifecycleManager"
		metadata: {
			name:      context.name
			namespace: "gloo-mesh"
		}
		spec: installations: [{
			clusters: parameter.installations.clusters
			istioOperatorSpec: parameter.installations.istioOperatorSpec
			revision: parameter.installations.revision
		}]
	}
	outputs: {}
	parameter: {
        installations: clusters: [...{
            name: string
            defaultRevision: *false | bool
        }]
        installations: istioOperatorSpec: profile: *"minimal" | string
        installations: istioOperatorSpec: hub: *"us-docker.pkg.dev/gloo-mesh/istio-workshops" | string
        installations: istioOperatorSpec: tag: string
        installations: istioOperatorSpec: namespace: *"istio-system" | string
        installations: istioOperatorSpec: meshConfig: *{
            accessLogFile: "/dev/stdout"
            accessLogEncoding: "JSON"
            enableTracing: "true"
            defaultConfig: { proxyMetadata: { ISTIO_META_DNS_CAPTURE: "true", ISTIO_META_DNS_AUTO_ALLOCATE: "true" } }
            outboundTrafficPolicy: { mode: "REGISTRY_ONLY"}
        } | {...}
        installations: istioOperatorSpec: values: *{
            global: { proxy: { privileged: "true" } }
        } | {...}
        installations: istioOperatorSpec: components: *{
            ingressGateways: [ { name: "istio-ingressgateway", enabled: false } ]
            pilot: { k8s: { env: [{name: "PILOT_ENABLE_K8S_SELECT_WORKLOAD_ENTRIES", value: "false"}]}}
        } | {...}
        installations: revision: string
    }
}