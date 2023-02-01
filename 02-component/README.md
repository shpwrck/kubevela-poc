How to create components:

1. export RESOURCE={{resource-name}}
1. Leverage vela cli and example to generate cue template:
    ```bash
    vela def init $RESOURCE \
      -t component \
      --template-yaml ./$RESOURCE/example.yaml \
      -o ./$RESOURCE/$RESOURCE.cue
    ```
1. Generalize template by replacing parameters
1. Validate the result:
    ```bash
    vela def vet ./$RESOURCE/$RESOURCE.cue
    ```
1. If the previous command was successful, then apply the template:
    ```bash
    vela def apply ./$RESOURCE/$RESOURCE.cue --namespace vela-system
    ```
1. Gather the component definition:
    ```bash
    KUBECONFIG=~/.k3d/kubeconfig-mgmt.yaml kubectl get componentdefinition -n vela-system $RESOURCE -o yaml > $RESOURCE/component.yaml
    ```
1. (Optional) Apply the relevant application example:
    ```bash
    KUBECONFIG=~/.k3d/kubeconfig-mgmt.yaml kubectl apply -f ./$RESOURCE/application.yaml
    ```