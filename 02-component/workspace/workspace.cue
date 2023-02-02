workspace: {
  alias: ""
  annotations: {}
  attributes: workload: definition: {
    apiVersion: "admin.gloo.solo.io/v2"
    kind:       "Workspace"
  }
  description: ""
  labels: {}
  type: "component"
}

template: {
  output: {
    apiVersion: "admin.gloo.solo.io/v2"
    kind:       "Workspace"
    metadata: {
      name:  context.name
      namespace: "gloo-mesh"
    }
    spec: workloadClusters: parameter.workloadClusters
  }
  outputs: {}
  parameter: {
    workloadClusters: [...{
      name: string
      namespace: [...{
        name: string
      }]
    }]
  }
}